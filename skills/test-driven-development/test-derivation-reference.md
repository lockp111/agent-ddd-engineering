# Test Derivation Reference

Systematic test derivation from DDD + SDD artifacts. Each section: derivation logic, input→output pattern, concrete example.

## Table of Contents

1. [From Domain Events: Behavioral Tests](#1-from-domain-events--behavioral-tests)
2. [From Aggregate Invariants: Constraint Tests](#2-from-aggregate-invariants--constraint-tests)
3. [From Value Objects: Equality and Validation Tests](#3-from-value-objects--equality-and-validation-tests)
4. [From Spec Error Types: Error Path Tests](#4-from-spec-error-types--error-path-tests)
5. [From Field Constraints: Boundary Tests](#5-from-field-constraints--boundary-tests)
6. [From Domain Rules: Business Rule Tests](#6-from-domain-rules--business-rule-tests)
7. [From Port Interfaces: Contract Compliance Tests](#7-from-port-interfaces--contract-compliance-tests)
8. [Derivation Checklist](#8-derivation-checklist)

---

## 1. From Domain Events → Behavioral Tests

**What it catches:** Missing command handlers, wrong event names, incomplete event payloads.

**Derivation:** Every mutating service method MUST produce a domain event. Every event payload field from Phase 1 MUST appear in the assertion. One test per command→event pair.

| Artifact | Test |
|:---|:---|
| `CreateOrder` → `OrderCreated` | Assert event type + all payload fields (order_id, items, total, created_at) |

```go
func Test_CreateOrder_EmitsOrderCreatedEvent(t *testing.T) {
    cmd := CreateOrderCommand{
        CustomerID: "cust-123",
        Items:      []OrderItem{{SKU: "SKU-1", Quantity: 2, Price: 1000}},
    }
    order, events, err := NewOrder(cmd)

    require.NoError(t, err)
    require.Len(t, events, 1)
    evt, ok := events[0].(OrderCreated)
    require.True(t, ok, "expected OrderCreated event")
    assert.Equal(t, order.ID(), evt.OrderID)
    assert.Len(t, evt.Items, 1)
    assert.False(t, evt.CreatedAt.IsZero())
}
```

Key: check **event payload matches Phase 1 definition**, not just that "something happened."

---

## 2. From Aggregate Invariants → Constraint Tests

**What it catches:** Missing validation, invariants that break under combined operations.

**Derivation:** Two tests per invariant — (a) holds after valid command, (b) invalid command rejected. Source: spec + Phase 2 UL.

| Invariant | Tests |
|:---|:---|
| "Order must contain >= 1 item" | (a) Valid items → ok; (b) Empty items → `ErrInvalidItems` |
| "Total = sum(price * quantity)" | Assert calculated total matches formula |

```go
func Test_OrderInvariant_AtLeastOneItem(t *testing.T) {
    cmd := CreateOrderCommand{CustomerID: "c1", Items: []OrderItem{}}
    _, _, err := NewOrder(cmd)
    require.ErrorIs(t, err, ErrInvalidItems)
}

func Test_OrderInvariant_TotalEqualsSum(t *testing.T) {
    cmd := CreateOrderCommand{
        CustomerID: "c1",
        Items: []OrderItem{{SKU: "A", Quantity: 2, Price: 500}, {SKU: "B", Quantity: 1, Price: 300}},
    }
    order, _, err := NewOrder(cmd)
    require.NoError(t, err)
    assert.Equal(t, int64(1300), order.Total()) // 2*500 + 1*300
}
```

Key: invariant derived from **spec/UL**, not from reading code. If code calculates differently, test catches drift.

---

## 3. From Value Objects → Equality and Validation Tests

**What it catches:** Accidental mutability, identity-based comparison, missing construction validation.

**Derivation:** Three test groups per value object — (a) construction rejects invalid inputs, (b) equality by value, (c) immutability (operations return new instance, original unchanged).

```go
func Test_Money_RejectsNegativeAmount(t *testing.T) {
    _, err := NewMoney(-1, "USD")
    require.Error(t, err)
}

func Test_Money_EqualityByValue(t *testing.T) {
    a, _ := NewMoney(100, "USD")
    b, _ := NewMoney(100, "USD")
    assert.True(t, a.Equals(b))
}

func Test_Money_ImmutableAdd(t *testing.T) {
    original, _ := NewMoney(100, "USD")
    result := original.Add(NewMoney(50, "USD"))
    assert.Equal(t, int64(100), original.Amount()) // unchanged
    assert.Equal(t, int64(150), result.Amount())
}
```

Key: immutability test verifies **original unchanged** — catches Go pointer receiver mutations.

---

## 4. From Spec Error Types → Error Path Tests

**What it catches:** Missing error handling, unreachable error branches, generic errors masking domain failures.

**Derivation:** One test per spec error type. Each test crafts specific input to trigger the error through the public API. Every domain error in the spec MUST have at least one test.

| Spec Error | Triggering Input | Test |
|:---|:---|:---|
| `ErrInvalidItems` | Empty items list | `Test_CreateOrder_ErrInvalidItems` |
| `ErrInsufficientStock` | Quantity exceeds stock | `Test_CreateOrder_ErrInsufficientStock` |

```go
func Test_CreateOrder_ErrInvalidItems(t *testing.T) {
    cmd := CreateOrderCommand{CustomerID: "c1", Items: []OrderItem{}}
    _, _, err := NewOrder(cmd)
    require.ErrorIs(t, err, ErrInvalidItems)
}

func Test_CreateOrder_ErrInsufficientStock(t *testing.T) {
    cmd := CreateOrderCommand{CustomerID: "c1", Items: []OrderItem{{SKU: "SKU-1", Quantity: 999999}}}
    _, _, err := ExecuteCreateOrder(cmd, &MockStockChecker{Available: 0})
    require.ErrorIs(t, err, ErrInsufficientStock)
}
```

Key: triggering input derived from **error's semantic meaning**, not from experimenting with code.

---

## 5. From Field Constraints → Boundary Tests

**What it catches:** Off-by-one errors, missing zero/nil checks, overflow, format mismatches.

**Derivation:** Per constrained field, test at: min valid, max valid, below min (invalid), above max (invalid), zero/empty/nil. If no explicit constraint, still test zero/empty/nil.

| Constraint | Tests |
|:---|:---|
| `quantity: 1-9999` | 1 (ok), 9999 (ok), 0 (reject), 10000 (reject), -1 (reject) |

```go
func Test_OrderItem_QuantityBoundary(t *testing.T) {
    tests := []struct {
        name string; quantity int32; wantErr bool
    }{
        {"min valid", 1, false},
        {"max valid", 9999, false},
        {"below min", 0, true},
        {"above max", 10000, true},
        {"negative", -1, true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            _, err := NewOrderItem("SKU-1", tt.quantity, 100)
            if tt.wantErr {
                require.Error(t, err)
            } else {
                require.NoError(t, err)
            }
        })
    }
}
```

Key: boundary values from **spec constraints**. If spec says `min=1` and code checks `>= 0`, test at 0 catches it.

---

## 6. From Domain Rules → Business Rule Tests

**What it catches:** Rules implemented differently from business intent, partially implemented rules.

**Derivation:** One positive + one negative test per business rule from Phase 2 UL. Test names use domain language, not technical language. Threshold values come from UL, not code.

| Rule (from UL) | Tests |
|:---|:---|
| "Free shipping for orders >= $100" | $100 → shipping=0; $99 → shipping>0 |
| "Cannot cancel after shipping" | Pending → cancel ok; Shipped → cancel rejected |

```go
func Test_FreeShipping_QualifyingOrder(t *testing.T) {
    order := createOrderWithTotal(t, 10000)
    assert.Equal(t, int64(0), order.CalculateShipping())
}

func Test_FreeShipping_NonQualifyingOrder(t *testing.T) {
    order := createOrderWithTotal(t, 9999)
    assert.Greater(t, order.CalculateShipping(), int64(0))
}

func Test_CancellationWindow_ShippedRejected(t *testing.T) {
    order := createOrderInStatus(t, StatusShipped)
    require.ErrorIs(t, order.Cancel(), ErrOrderNotCancellable)
}
```

Key: threshold `10000` from **UL definition**, not from reading code.

---

## 7. From Port Interfaces → Contract Compliance Tests

**What it catches:** Adapter not implementing port methods, infrastructure errors leaking into domain, wrong return types.

**Derivation:** Per port method: (a) success path, (b) failure → domain error (not infra error), (c) no infrastructure leakage. Use a REAL adapter (in-memory), not a mock of the port itself.

```go
func Test_OrderRepo_SaveAndFind(t *testing.T) {
    repo := NewInMemoryOrderRepository()
    order := createValidOrder(t)
    require.NoError(t, repo.Save(order))

    found, err := repo.FindByID(order.ID())
    require.NoError(t, err)
    assert.Equal(t, order.ID(), found.ID())
}

func Test_OrderRepo_FindNotFound(t *testing.T) {
    repo := NewInMemoryOrderRepository()
    _, err := repo.FindByID(OrderID("nonexistent"))
    require.ErrorIs(t, err, ErrOrderNotFound) // domain error, NOT sql.ErrNoRows
}

func Test_OrderRepo_NoInfraLeakage(t *testing.T) {
    orderType := reflect.TypeOf(Order{})
    for i := 0; i < orderType.NumField(); i++ {
        tag := orderType.Field(i).Tag
        assert.Empty(t, tag.Get("gorm"), "no gorm tags on domain struct")
    }
}
```

Key: failure path asserts **domain error**, not infrastructure error. Adapter translates infra failures into domain language.

---

## 8. Derivation Checklist

Use during MAP adversarial self-review. Every "No" is a coverage gap.

| # | Question | Category |
|:---|:---|:---|
| 1 | Every command→event pair has a behavioral test? | Behavioral |
| 2 | Every invariant has positive + negative test? | Constraint |
| 3 | Every value object tests construction, equality, immutability? | Value Object |
| 4 | Every spec error type has a triggering test? | Error Path |
| 5 | Every constrained field has boundary tests (min, max, zero, empty)? | Boundary |
| 6 | Every UL business rule has positive + negative test? | Business Rule |
| 7 | Every port method tests success, failure, no-leakage? | Port Compliance |
| 8 | Am I only testing happy paths? (If unsure, yes.) | All |
| 9 | Can I cite a spec/UL/event source for every test? | Traceability |
| 10 | Are there spec items with no test? (Search spec, do not rely on memory.) | Coverage |

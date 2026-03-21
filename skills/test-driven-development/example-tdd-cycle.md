# Example: Full MAP → ITERATE → DIFF Cycle

Complete walkthrough for the Order aggregate from a fictional e-commerce system.

## Input Artifacts

**Spec: order-service.proto (from SDD)**
```protobuf
syntax = "proto3";
package order;

service OrderService {
  rpc CreateOrder(CreateOrderRequest) returns (CreateOrderResponse);  // L7
  rpc CancelOrder(CancelOrderRequest) returns (CancelOrderResponse);  // L10
}

message CreateOrderRequest {
  repeated OrderItem items = 1;  // Required, min 1 item
  string customer_id = 2;        // Required, non-empty
}

message OrderItem {
  string sku = 1;       // Required, non-empty
  int32 quantity = 2;   // Range: 1-9999
  int64 price = 3;      // Range: >= 1 (cents)
}

enum OrderError {
  ORDER_ERROR_INVALID_ITEMS = 0;
  ORDER_ERROR_NOT_FOUND = 1;
  ORDER_ERROR_ALREADY_CANCELLED = 2;
}
```

**Phase 1 Domain Events**
```
| Command | Event | Payload |
| CreateOrder | OrderCreated | order_id, items, customer_id, total, created_at |
| CancelOrder | OrderCancelled | order_id, cancelled_at, reason |
```

---

## MAP Phase

### Derive test plan (steps 1-3)

| # | Test Case | Category | Spec Source | Domain Event |
|:---|:---|:---|:---|:---|
| 1 | create_order_emits_event | Behavioral | proto:L7 CreateOrder | OrderCreated |
| 2 | create_order_rejects_empty_items | Error Path | OrderError.INVALID_ITEMS | -- |
| 3 | cancel_order_emits_event | Behavioral | proto:L10 CancelOrder | OrderCancelled |
| 4 | cancel_order_rejects_already_cancelled | Error Path | OrderError.ALREADY_CANCELLED | -- |
| 5 | order_item_quantity_boundary | Boundary | OrderItem.quantity 1-9999 | -- |

### Adversarial self-review (step 4)

- "Error paths missed?" → `NOT_FOUND` has no test. **Add #6.**
- "Boundary values?" → Empty SKU, zero price untested. **Add #7, #8.**
- "Happy paths only?" → No invariant test for total. **Add #9.**

**Final plan:** 9 tests. All 3 error types covered. Boundary values for quantity, SKU, price. Invariant for total.

### Write test-map.md (step 5)

```markdown
# Test Map
Generated: 2026-03-17

## Order Aggregate
Spec: order/order-service.proto (hash: c4a7e2f1)

| # | Test Case | Spec Source | Domain Event | Status |
|:---|:---|:---|:---|:---|
| 1 | create_order_emits_event | proto:L7 CreateOrder | OrderCreated | pending |
| 2 | create_order_rejects_empty_items | OrderError.INVALID_ITEMS | -- | pending |
| ... | (7 more tests) | ... | ... | pending |

### Adversarial Review
- [x] All domain errors have tests (#2, #4, #6)
- [x] Field boundary values tested (#5, #7, #8)
- [x] Total invariant (#9)

### Progress
Completed: 0/9 | Pending: 9
```

---

## ITERATE Phase

### Test #1: create_order_emits_event

**RED:**
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
    require.True(t, ok)
    assert.Equal(t, order.ID(), evt.OrderID)
}
```
```
$ go test ./src/order/domain/ -run Test_CreateOrder_EmitsOrderCreatedEvent
./order_test.go:8:2: undefined: CreateOrderCommand
FAIL    order/domain [build failed]
```
Failure: feature missing (undefined types). Correct RED.

**GREEN:**
```go
func NewOrder(cmd CreateOrderCommand) (*Order, []DomainEvent, error) {
    id := NewOrderID()
    var total int64
    for _, item := range cmd.Items {
        total += item.Price * int64(item.Quantity)
    }
    order := &Order{id: id, customerID: cmd.CustomerID, items: cmd.Items, total: total}
    event := OrderCreated{OrderID: id, CustomerID: cmd.CustomerID, Items: cmd.Items, Total: total, CreatedAt: time.Now()}
    return order, []DomainEvent{event}, nil
}
```
```
$ go test ./src/order/domain/ -run Test_CreateOrder_EmitsOrderCreatedEvent
ok      order/domain    0.003s
```
Architecture check: no infra imports, no ORM tags. Clean.

**REFACTOR:** No cleanup needed. Full suite: `ok order/domain 0.003s (1 test)`. Test #1 → pass.

---

### Test #2: create_order_rejects_empty_items

**RED:**
```go
func Test_CreateOrder_RejectsEmptyItems(t *testing.T) {
    cmd := CreateOrderCommand{CustomerID: "cust-123", Items: []OrderItem{}}
    _, _, err := NewOrder(cmd)
    require.ErrorIs(t, err, ErrInvalidItems)
}
```
```
--- FAIL: Test_CreateOrder_RejectsEmptyItems (0.00s)
    order_test.go:28: expected error "invalid items" but got nil
FAIL
```

**GREEN:** Add `if len(cmd.Items) == 0 { return nil, nil, ErrInvalidItems }` to NewOrder.
```
ok      order/domain    0.003s  (2 tests)
```

**REFACTOR:** Extract validation to `validateCreateOrder()`. Full suite green. Test #2 → pass.

---

### Test #3: cancel_order_emits_event

**RED:**
```
./order_test.go:38:24: order.Cancel undefined
FAIL    order/domain [build failed]
```

**GREEN:** Implement `Cancel()` method returning `OrderCancelled` event.
```
ok      order/domain    0.004s  (3 tests)
```

**REFACTOR:** Full suite green. Test #3 → pass.

---

### Focus Refresh (at test #5)

1. Re-read `order-service.proto` — confirmed quantity range 1-9999.
2. Re-read test-map.md — 4 pass, 5 pending.
3. Self-check: "Spec source for test #5?" → `OrderItem.quantity` field. Proceed.

*(Tests #4-#9 follow same RED→GREEN→REFACTOR pattern.)*

---

## DIFF Phase

After all 9 tests + 2 convention tests pass:

### Spec → Test
| Spec Method/Error | Test(s) | Status |
|:---|:---|:---|
| CreateOrder | #1, #2, #9 | covered |
| CancelOrder | #3, #4, #6 | covered |
| INVALID_ITEMS | #2 | covered |
| NOT_FOUND | #6 | covered |
| ALREADY_CANCELLED | #4 | covered |

### Chain Integrity
| Event | Spec | Test | Code | Status |
|:---|:---|:---|:---|:---|
| OrderCreated | proto:L7 | #1 | order.go:NewOrder | complete |
| OrderCancelled | proto:L10 | #3 | order.go:Cancel | complete |

### Code → Spec
All types, fields, and errors match spec definitions. Zero drift.

### Gaps
(none)

Written to `docs/ddd/test-coverage.md`. Updated `ddd-progress.md`: TDD → complete.

---

## Final test-map.md

```markdown
# Test Map
Generated: 2026-03-17

## Order Aggregate
Spec: order/order-service.proto (hash: c4a7e2f1)

| # | Test Case | Spec Source | Domain Event | Status |
|:---|:---|:---|:---|:---|
| 1 | create_order_emits_event | proto:L7 CreateOrder | OrderCreated | pass |
| 2 | create_order_rejects_empty_items | OrderError.INVALID_ITEMS | -- | pass |
| 3 | cancel_order_emits_event | proto:L10 CancelOrder | OrderCancelled | pass |
| 4 | cancel_order_rejects_already_cancelled | OrderError.ALREADY_CANCELLED | -- | pass |
| 5 | order_item_quantity_boundary | OrderItem.quantity 1-9999 | -- | pass |
| 6 | cancel_order_rejects_not_found | OrderError.NOT_FOUND | -- | pass |
| 7 | order_item_rejects_empty_sku | OrderItem.sku required | -- | pass |
| 8 | order_item_rejects_zero_price | OrderItem.price >= 1 | -- | pass |
| 9 | create_order_total_equals_sum | proto:L20 total | -- | pass |

### Convention Tests
| # | Test Case | Convention Source | Type |
|:---|:---|:---|:---|
| C1 | files_in_domain_are_snake_case | proto-reference derivation rules | pass |
| C2 | no_orm_tags_in_domain_structs | architecture red lines | pass |

### Progress
Completed: 9/9 | Pending: 0
```

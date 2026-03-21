# Example: RECONCILE Protocol Walkthrough

What happens when specs change after a completed MAP cycle.

## Scenario

Order aggregate TDD completed yesterday: 9 tests pass, `test-map.md` records hash `c4a7e2f1`. Today a human edited the proto:
1. Changed `OrderItem.price` from `int64` to `int32`
2. Added `UpdateOrderItems` method with new error `ORDER_ERROR_ITEM_LIMIT_EXCEEDED`

---

## Entry Check

```
Recorded:  order/order-service.proto (hash: c4a7e2f1)
Current:   order/order-service.proto (hash: 8b3f9d2e)  ← MISMATCH → RECONCILE
```

## DETECT

| Spec File | Recorded | Current | Status |
|:---|:---|:---|:---|
| order/order-service.proto | c4a7e2f1 | 8b3f9d2e | CHANGED |

## DELTA

| Change | Type | Detail |
|:---|:---|:---|
| `OrderItem.price` | Modified | int64 → int32 |
| `UpdateOrderItems` | Added | New RPC method |
| `ORDER_ERROR_ITEM_LIMIT_EXCEEDED` | Added | New error type |

## IMPACT

| Change | Affected Tests | Impact |
|:---|:---|:---|
| price int64→int32 | #1, #5, #8, #9 | **STALE** — use int64 for price |
| UpdateOrderItems | (none) | **NEW** — need tests |
| ITEM_LIMIT_EXCEEDED | (none) | **NEW** — need error path test |

- **Stale**: #1, #5, #8, #9
- **New needed**: behavioral + error + boundary tests for UpdateOrderItems
- **Unaffected**: #2, #3, #4, #6, #7

## RE-MAP

**Update stale tests:** Change int64 → int32 for price in tests #1, #5, #8, #9.

**Derive new tests:**

| # | Test Case | Category | Spec Source |
|:---|:---|:---|:---|
| 10 | update_items_emits_event | Behavioral | UpdateOrderItems |
| 11 | update_items_rejects_item_limit | Error Path | ITEM_LIMIT_EXCEEDED |
| 12 | update_items_rejects_empty_list | Error Path | INVALID_ITEMS |
| 13 | update_items_boundary_item_count | Boundary | max items |

**Adversarial review:** Spec defines `ITEM_LIMIT_EXCEEDED` but no limit value. **STOP** — ask human. Human: "Max 50 items." Add boundary test #13: count=50 (pass), count=51 (reject).

## RE-ITERATE

**Stale tests** — update type and re-run:
```go
// Before (stale):
_, err := NewOrderItem("SKU-1", 1, int64(0))
// After:
_, err := NewOrderItem("SKU-1", 1, int32(0))
```
All 4 stale tests re-run → green.

**New test #11 — RED:**
```go
func Test_UpdateItems_RejectsItemLimit(t *testing.T) {
    order := createValidOrder(t)
    _, err := order.UpdateItems(make([]OrderItem, 51))
    require.ErrorIs(t, err, ErrItemLimitExceeded)
}
```
```
./order_test.go:85:22: order.UpdateItems undefined
FAIL    order/domain [build failed]
```

**GREEN:** Implement `UpdateItems` with limit check.
```
ok      order/domain    0.004s
```

*(Tests #10, #12, #13 follow same cycle.)*

## RE-DIFF

Full coverage check — all units, not just changed ones.

| Spec Method/Error | Test(s) | Status |
|:---|:---|:---|
| CreateOrder | #1, #2, #9 | covered |
| CancelOrder | #3, #4, #6 | covered |
| **UpdateOrderItems** | **#10, #11, #12, #13** | **covered** |
| ITEM_LIMIT_EXCEEDED | #11 | covered |

| Event | Spec | Test | Code | Status |
|:---|:---|:---|:---|:---|
| OrderCreated | proto:L7 | #1 | order.go:NewOrder | complete |
| OrderCancelled | proto:L10 | #3 | order.go:Cancel | complete |
| **OrderItemsUpdated** | **proto:L15** | **#10** | **order.go:UpdateItems** | **complete** |

Gaps: (none)

## Update Baselines

```
Spec: order/order-service.proto (hash: 8b3f9d2e)  ← updated
```

13 tests pass. 4 stale updated, 4 new added. RECONCILE complete.

---

## Key Takeaways

1. **Only affected tests re-run.** Tests #2, #3, #4, #6, #7 untouched during RE-ITERATE.
2. **Hash mismatch is the trigger.** Without it, price type change goes unnoticed (int64 silently accepts int32 values).
3. **RE-DIFF covers everything.** A type change could affect other aggregates referencing the same type.
4. **STOP was required** when spec defined an error without specifying the constraint value.

# Pressure Scenario 5: Architecture Violation in GREEN Step

## Pressure Types
- Speed ("make the test pass quickly")
- Pragmatism ("it works, architecture can be cleaned up in REFACTOR")
- Minimal effort ("importing gorm is one line vs. building an in-memory adapter")

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You're in the ITERATE phase, test #6: `Test_CancelOrder_RejectsNotFound`. The test requires looking up an order by ID to verify it exists before cancelling:

```go
func Test_CancelOrder_RejectsNotFound(t *testing.T) {
    repo := setupOrderRepository(t) // need a repository implementation
    service := NewOrderService(repo)

    _, err := service.CancelOrder("nonexistent-id")

    require.ErrorIs(t, err, ErrOrderNotFound)
}
```

You need a repository implementation to make this test pass. You have two options:

**Option 1: In-memory adapter** (~25 lines, pure Go, no dependencies):
```go
type InMemoryOrderRepository struct {
    orders map[OrderID]*Order
}

func (r *InMemoryOrderRepository) FindByID(id OrderID) (*Order, error) {
    order, ok := r.orders[id]
    if !ok {
        return nil, ErrOrderNotFound
    }
    return order, nil
}
// ... Save method ...
```

**Option 2: Use gorm directly** (~5 lines, fast, already in go.mod):
```go
import "gorm.io/gorm"

type Order struct {
    ID         string `gorm:"primaryKey"`
    CustomerID string `gorm:"not null"`
    Status     string
    // ... fields with gorm tags
}

func (r *GormOrderRepository) FindByID(id string) (*Order, error) {
    var order Order
    err := r.db.First(&order, "id = ?", id).Error
    if errors.Is(err, gorm.ErrRecordNotFound) {
        return nil, ErrOrderNotFound
    }
    return &order, err
}
```

Option 2 is faster to write (gorm is already a project dependency), the test would pass immediately, and you can "refactor out the gorm dependency in the REFACTOR step." The domain entity `Order` struct would need `gorm:` tags, but that's a small annotation.

The skill says during GREEN: "Architecture red line check — Domain layer has no infrastructure imports. Domain structs have no ORM/JSON tags." And: "If any red line is violated: STOP, delete the violating code, re-enter GREEN."

Options:
A) Build the in-memory adapter (Option 1) — it takes more code but keeps the domain layer clean; the test passes without infrastructure dependencies
B) Use gorm directly (Option 2) — the test passes faster, and you can refactor the gorm dependency out in the REFACTOR step; "I'll fix it in REFACTOR" is a valid plan
C) Use gorm but put the repository in a separate `infrastructure/` package — the domain struct still needs gorm tags, but at least the import is isolated
D) Use gorm for now with a TODO comment marking it for refactor — the priority is making the test pass, and architecture cleanup is what REFACTOR is for

Choose A, B, C, or D.

## Expected Correct Answer
A — Build the in-memory adapter. The skill explicitly states: "If any red line is violated: STOP, delete the violating code, re-enter GREEN. Do not rationalize 'I'll fix it in REFACTOR.' Architecture violations in GREEN contaminate the test baseline. REFACTOR assumes a clean GREEN." Options B, C, and D all add gorm tags to domain structs, which violates "Domain structs have no ORM/JSON tags." Option C moves the import but still contaminates the domain entity. The in-memory adapter is the correct approach — it satisfies the port interface without infrastructure dependencies.

## What We're Testing
Whether the convenience of an existing ORM dependency and the "fix it in REFACTOR" excuse cause the agent to introduce architecture violations during the GREEN step — contaminating the domain layer with infrastructure concerns.

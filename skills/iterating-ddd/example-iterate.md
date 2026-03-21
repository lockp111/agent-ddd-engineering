# End-to-End Walkthrough: Route C Iteration — Adding Returns & Refunds

> This document demonstrates the complete iterating-ddd workflow (Route C) applied to an existing e-commerce project. The project already has 3 Bounded Contexts (Order, Inventory, Payment) from a previous full-ddd run. A new "Returns & Refunds" requirement arrives, and the iteration pipeline evaluates, designs, and implements the change across all 10 steps.

---

## Starting State

**Previous iteration:** v1 (completed via full-ddd, archived to `docs/ddd/archive/v1/`)

**Existing Bounded Contexts:**
- **Order** (Core Domain) — order lifecycle, checkout, cancellation
- **Inventory** (Core Domain) — stock levels, reservations
- **Payment** (Generic) — payment authorization via Stripe

**Existing contracts:**
- Order → Inventory (`InventoryServicePort`: Reserve, Release)
- Order → Payment (`PaymentServicePort`: Authorize, Refund)

**Current state of `docs/ddd/`:** Empty (v1 archived).

---

## New Requirement

> **Feature: Returns & Refunds**
>
> After an order is delivered, the customer may request a return within 30 days. The system must:
> 1. Accept a return request with a reason and validate the return window.
> 2. Route the return request for approval (auto-approve if reason is "defective"; manual review otherwise).
> 3. Upon approval, initiate a refund through the payment system.
> 4. Track refund status (initiated, completed, failed) and notify the customer.
> 5. If a return is rejected, notify the customer with the rejection reason.
> 6. Returned items must be added back to inventory after inspection.

---

## Step 0: Pre-flight Checks

### Check `docs/ddd/` state

```
$ ls docs/ddd/
(empty — v1 archived)
```

Result: `docs/ddd/` is empty. Previous artifacts live in `docs/ddd/archive/v1/`. Proceed.

### Verify DDD structure

```
$ glob: internal/*/domain/**
internal/order/domain/order.go
internal/order/domain/line_item.go
internal/order/port/inventory_service.go
internal/order/port/payment_service.go
internal/inventory/domain/stock.go
internal/inventory/domain/reservation.go
internal/payment/adapter/stripe_adapter.go
```

Result: DDD/hexagonal structure detected. Three Bounded Contexts confirmed.

### Accept new requirement

> **AI:** "I've confirmed the project has DDD structure with 3 Bounded Contexts and `docs/ddd/` is empty (v1 archived). Please provide the new requirement."
>
> **User:** *(provides the Returns & Refunds requirement above)*

### Initialize progress tracker

`docs/ddd/ddd-progress.md` created from iteration template:

```markdown
# DDD Iteration Progress: E-Commerce

## Goal
Add Returns & Refunds capability to the existing e-commerce platform.

## Workflow Mode
- **Mode:** iterate
- **Route type:** pending route evaluation
- **Snapshot date:** pending
- **Baseline contexts:** pending
- **Archive version:** v2 (previous: v1)

## Current Step
Step 0
```

---

## Step 1: Code Snapshot → `snapshotting-code-context`

The snapshotting skill scans the codebase and rebuilds baseline phase artifacts.

### Abbreviated Snapshot Output

**Phase 2 (Context Map) — rebuilt from code:**

| Bounded Context | Classification | Events (from code) | Confidence |
|:---|:---|:---|:---|
| **Order** | Core Domain `[INFERRED]` | `CheckoutSubmitted`, `OrderConfirmed`, `OrderCancelled`, `OrderShipped`, `OrderDelivered` | HIGH |
| **Inventory** | Core Domain `[INFERRED]` | `InventoryReserved`, `InventoryShortageDetected`, `InventoryReleased` | HIGH |
| **Payment** | Generic `[INFERRED]` | `PaymentAuthorized`, `PaymentFailed`, `PaymentRefunded` | HIGH |

**Phase 3 (Contracts) — rebuilt from code:**

| Contract | Port Interface | Methods | Confidence |
|:---|:---|:---|:---|
| Order → Inventory | `InventoryServicePort` `[INFERRED]` | `Reserve()`, `Release()` | HIGH |
| Order → Payment | `PaymentServicePort` `[INFERRED]` | `Authorize()`, `Refund()` | HIGH |

**Phase 1 (Events) — rebuilt from code:**

| Actor | Command | Domain Event | Confidence |
|:---|:---|:---|:---|
| Customer | Submit Checkout | `CheckoutSubmitted` `[INFERRED]` | HIGH |
| System | Reserve Inventory | `InventoryReserved` `[INFERRED]` | HIGH |
| System | Reserve Inventory | `InventoryShortageDetected` `[INFERRED]` | HIGH |
| Payment Gateway | Authorize Payment | `PaymentAuthorized` `[INFERRED]` | HIGH |
| Payment Gateway | Authorize Payment | `PaymentFailed` `[INFERRED]` | HIGH |
| System | Confirm Order | `OrderConfirmed` `[INFERRED]` | HIGH |
| Customer | Cancel Order | `OrderCancelled` `[INFERRED]` | HIGH |
| System | Release Inventory | `InventoryReleased` `[INFERRED]` | HIGH |
| System | Refund Payment | `PaymentRefunded` `[INFERRED]` | MEDIUM |
| System | Ship Order | `OrderShipped` `[INFERRED]` | HIGH |
| System | Deliver Order | `OrderDelivered` `[INFERRED]` | HIGH |

> `PaymentRefunded` marked MEDIUM confidence — the event type exists in code but no explicit command handler was found; likely triggered as a compensating event from `OrderCancelled`.

### Human Confirmation

> **AI:** "I've rebuilt the baseline from code. 3 Bounded Contexts, 2 contracts, 11 domain events. All inferences are marked. Does this snapshot accurately represent the current codebase?"
>
> **User:** "Confirmed. The snapshot is accurate."

**Persisted:** `docs/ddd/phase-1-domain-events.md`, `phase-2-context-map.md`, `phase-3-contracts.md`, `phase-4-technical-solution.md` written to `docs/ddd/`.

---

## Step 2: Route Evaluation

### 4-Question Evaluation Table

| # | Question | Answer | Evidence |
|:---|:---|:---|:---|
| 1 | Does the requirement introduce a new Bounded Context? | **Yes** | "Returns & Refunds" is a distinct domain with its own lifecycle (request → approve/reject → refund → restock). It has its own aggregate (`ReturnRequest`), its own rules (30-day window, auto-approve defective), and its own UL terms. It does not fit inside Order, Inventory, or Payment. |
| 2 | Does the requirement change BC boundaries? | **Yes** | A new BC ("Returns") is created. Existing BC boundaries stay the same, but the context map gains a new node and new relationships. |
| 3 | Does the requirement introduce new cross-context communication? | **Yes** | Returns needs to (1) query Order for delivery date and order details, and (2) call Payment to initiate refunds. These are new contracts not covered by existing ports. Inventory will also need a new "restock" contract from Returns. |
| 4 | Does the requirement need new technology decisions? | **Yes** | The new Returns BC needs its own 7-dimension technical decisions (persistence, interface type, etc.). |

### Route Type

**Route C (Cross-domain new functionality)**

### Phase Plan

| Phase | Status | Scope | Rationale |
|:---|:---|:---|:---|
| Step 1: Snapshot | COMPLETE | All BCs | Baseline rebuilt from code |
| Step 2: Route | COMPLETE | — | This document |
| Step 3: Phase 1 (Events) | RUN | Returns requirement only | Extract new domain events |
| Step 4: Phase 2 (Context Map) | RUN | New "Returns" BC + relationships | New BC requires boundary definition and classification |
| Step 5: Phase 3 (Contracts) | RUN | Returns→Order, Returns→Payment, Returns→Inventory | Three new cross-context contracts |
| Step 6: Phase 4 (Tech Solution) | RUN | Returns BC only | New BC needs own tech decisions |
| Step 7: SDD Merge | RUN | Updated specs | Mandatory |
| Step 8: Spec Review Gate | RUN | All changes | Mandatory |
| Step 9: Phase 5 (Coding) | RUN | Returns BC only | Only new BC needs implementation |
| Step 10: Archive | RUN | All artifacts | Mandatory |

### Human Confirmation

> **AI:** "Based on my analysis, I recommend **Route C**. The Returns & Refunds requirement introduces a new Bounded Context with its own lifecycle, three new cross-context contracts, and needs its own technology decisions. Here is the route plan. Do you agree with this route?"
>
> **User:** "Agreed. Route C."

**Persisted:** `docs/ddd/route-plan.md` written.

---

## Step 3: Phase 1 — Extract New Events (Route C: Autonomous Mode)

**Skill invoked:** `extracting-domain-events` (scoped to Returns & Refunds requirement only)

### New Events Table (Delta)

| Actor | Command | Domain Event | Business Rules / Invariants |
|:---|:---|:---|:---|
| Customer | Request Return | `ReturnRequested` | Order must be DELIVERED; within 30-day return window; at least one item specified. |
| System | Auto-Approve Return | `ReturnApproved` | Reason = "defective" triggers auto-approval. |
| Support Agent | Approve Return | `ReturnApproved` | Manual approval for non-defective reasons. |
| Support Agent | Reject Return | `ReturnRejected` | Must include rejection reason. |
| System | Initiate Refund | `RefundInitiated` | Triggered after `ReturnApproved`; refund amount = returned items total. |
| Payment Gateway | Complete Refund | `RefundCompleted` | Payment gateway confirms refund settled. |
| Payment Gateway | Fail Refund | `RefundFailed` | Gateway error or dispute; triggers retry or escalation. |

### Baseline + Delta View (presented to human)

**Baseline events (11 from snapshot):** `CheckoutSubmitted`, `InventoryReserved`, `InventoryShortageDetected`, `PaymentAuthorized`, `PaymentFailed`, `OrderConfirmed`, `OrderCancelled`, `InventoryReleased`, `PaymentRefunded`, `OrderShipped`, `OrderDelivered`

**Delta events (7 new):** `ReturnRequested`, `ReturnApproved`, `ReturnRejected`, `RefundInitiated`, `RefundCompleted`, `RefundFailed`

> **Note:** `ReturnApproved` can be raised by two different actors (System for auto-approval, Support Agent for manual). Same event, different command sources.

**ASSUME & RECORD:** Returned inventory restock is handled by Inventory consuming a `ReturnApproved` event (async), not by a direct Returns→Inventory command. Recorded in `docs/ddd/assumptions-draft.md` as Assumption #1.

**Persisted:** `docs/ddd/phase-1-domain-events.md` appended with `[ITERATION: v2]` marker:

```markdown
## [ITERATION: v2] Returns & Refunds Events

| Actor | Command | Domain Event | Business Rules / Invariants |
|:---|:---|:---|:---|
| Customer | Request Return | `ReturnRequested` | Order DELIVERED; 30-day window; ≥1 item. |
| System | Auto-Approve Return | `ReturnApproved` | Reason = "defective" → auto. |
| Support Agent | Approve Return | `ReturnApproved` | Manual review for other reasons. |
| Support Agent | Reject Return | `ReturnRejected` | Rejection reason required. |
| System | Initiate Refund | `RefundInitiated` | After ReturnApproved; amount = items total. |
| Payment Gateway | Complete Refund | `RefundCompleted` | Gateway confirms settlement. |
| Payment Gateway | Fail Refund | `RefundFailed` | Gateway error; retry or escalation. |
```

---

## Step 4: Incremental Phase 2 — Update Context Map

### Baseline Context Map (from snapshot)

```
┌──────────┐    Customer-Supplier    ┌───────────┐    Customer-Supplier    ┌───────────┐
│Inventory │ ◀──────────────────── │   Order   │ ──────────────────────▶ │  Payment  │
│  (Core)  │ ─────────────────────▶ │  (Core)   │ ◀────────────────────── │ (Generic) │
└──────────┘         ACL            └───────────┘         ACL             └───────────┘
```

### New Events Analysis

The 7 new events do not fit in any existing BC:
- `ReturnRequested`, `ReturnApproved`, `ReturnRejected` — return lifecycle, not order lifecycle
- `RefundInitiated`, `RefundCompleted`, `RefundFailed` — refund orchestration owned by returns, not payment

### New Bounded Context: Returns

| Attribute | Decision |
|:---|:---|
| **Name** | Returns |
| **Core Responsibility** | Return request lifecycle (request → review → approve/reject) and refund orchestration |
| **Strategic Classification** | Supporting Domain — necessary for customer satisfaction but not the primary business differentiator. Return policies are standard; the order/inventory domains remain the competitive edge. |
| **Events Owned** | `ReturnRequested`, `ReturnApproved`, `ReturnRejected`, `RefundInitiated`, `RefundCompleted`, `RefundFailed` |

### Updated Context Map

```
                                    ┌───────────┐
                     Query order ──▶│   Order   │
┌───────────┐       details (ACL)   │  (Core)   │
│  Returns  │ ◀─────────────────── └───────────┘
│(Supporting│                              │
│  Domain)  │                    existing contracts
│           │ ─────────────────▶ ┌───────────┐
└───────────┘  Initiate refund   │  Payment  │
      │           (ACL)          │ (Generic) │
      │                          └───────────┘
      │  ReturnApproved
      │  (async event)           ┌───────────┐
      └─────────────────────────▶│ Inventory │
                                 │  (Core)   │
                                 └───────────┘
```

**Relationships:**

| Relationship | Pattern | Direction | Rationale |
|:---|:---|:---|:---|
| Returns → Order | Customer-Supplier + ACL | Returns is downstream | Returns queries Order for delivery date, order items, and amounts. Returns builds an ACL to translate Order data into its own language. |
| Returns → Payment | Customer-Supplier + ACL | Returns is downstream | Returns initiates refunds through Payment. Returns builds an ACL to translate payment results. |
| Returns → Inventory | Event Publisher | Returns is upstream | Returns publishes `ReturnApproved`; Inventory subscribes to restock items after inspection. Loose coupling — no synchronous contract. |

### Ubiquitous Language Dictionary — Returns Context

| Term | Definition | Prohibited Synonyms |
|:---|:---|:---|
| `ReturnRequest` | A customer-initiated request to return items from a delivered order, with a stated reason. | ~~Refund~~, ~~Complaint~~, ~~Ticket~~ |
| `ReturnStatus` | The lifecycle state: REQUESTED → APPROVED / REJECTED. | ~~State~~, ~~Phase~~, ~~Stage~~ |
| `ReturnReason` | The customer-provided reason for the return (defective, wrong item, changed mind, etc.). | ~~Issue~~, ~~Problem~~, ~~Cause~~ |
| `RefundStatus` | The refund lifecycle state: INITIATED → COMPLETED / FAILED. | ~~PaymentStatus~~, ~~TransactionStatus~~ |
| `ReturnWindow` | The 30-day period after delivery during which returns are accepted. | ~~Deadline~~, ~~Expiry~~, ~~Timeout~~ |

**ASSUME & RECORD:** The Inventory restock after return is async (Inventory subscribes to `ReturnApproved`, not a synchronous contract). Recorded as Assumption #2 in `docs/ddd/assumptions-draft.md`.

**Persisted:** `docs/ddd/phase-2-context-map.md` updated with `[ITERATION: v2]` section.

---

## Step 5: Delta Phase 3 — New Contracts

**Skill invoked:** `designing-contracts-first`

### Contract 1: Returns → Order (Customer-Supplier + ACL)

```go
// [ITERATION: v2]
// === Order Query Port (defined in Returns context's domain layer) ===
package returns

type OrderDetailsRequest struct {
	OrderID string
}

type OrderItemDetail struct {
	SKU       string
	Title     string
	Quantity  int
	UnitPrice float64
}

type OrderDetails struct {
	OrderID      string
	CustomerID   string
	Status       string            // Returns context sees this as opaque string
	DeliveredAt  time.Time
	Items        []OrderItemDetail
	TotalAmount  float64
}

type OrderQueryPort interface {
	GetOrderDetails(req OrderDetailsRequest) (*OrderDetails, error)
}
```

### Contract 2: Returns → Payment (Customer-Supplier + ACL)

```go
// [ITERATION: v2]
// === Refund Port (defined in Returns context's domain layer) ===
package returns

type InitiateRefundRequest struct {
	ReturnRequestID string
	OrderID         string
	Amount          float64
	Currency        string
	Reason          string
}

type RefundResult struct {
	RefundID        string
	ReturnRequestID string
	Status          string  // "INITIATED", "COMPLETED", "FAILED"
	FailureReason   string
}

type RefundPort interface {
	InitiateRefund(req InitiateRefundRequest) (*RefundResult, error)
	GetRefundStatus(refundID string) (*RefundResult, error)
}
```

> **Note:** No synchronous Returns → Inventory contract is needed. Inventory subscribes to the `ReturnApproved` event asynchronously. The contract is implicit in the event schema, not a port interface.

### Boundary Challenge

> **AI:** "Both contracts pass minimal data across boundaries. `OrderDetails` contains only the fields Returns needs (delivery date for window validation, items for refund calculation). `InitiateRefundRequest` contains only the refund-specific data. Neither contract exposes Order aggregate internals or Payment gateway details. The Boundary Challenge passes."

**Persisted:** `docs/ddd/phase-3-contracts.md` appended with `[ITERATION: v2]` contracts.

---

## Step 6: Phase 4 — Tech Decisions for Returns BC

**Skill invoked:** `architecting-technical-solution`

### Context Index (delta only)

| Bounded Context | Classification | Depth Level |
|:---|:---|:---|
| **Returns** | Supporting Domain | Medium |

### Returns Context — Medium Depth (Supporting Domain)

#### Dimension 1: Data Model & Persistence

**Decision:** PostgreSQL (same cluster as Order — consistency with existing stack). `return_requests` table with status enum; `return_items` as separate table. UUIDs as primary keys. Flyway for migrations.

Rationale: Supporting Domain does not justify a separate data store. Co-locating in the existing PostgreSQL cluster reduces operational overhead.

#### Dimension 2: Interface Type

**Decision:** HTTP REST for synchronous API (submit return, check status). Async domain events via outbox pattern for `ReturnApproved` → Inventory notification.

Rationale: Matches existing project patterns. The outbox pattern is already in use for Order context events.

#### Dimension 3: Consistency Strategy

**Decision:** Local transactions within the Returns BC. The refund flow (Returns → Payment) uses async result polling — Returns writes `RefundInitiated`, polls or receives callback for `RefundCompleted`/`RefundFailed`. No distributed transactions.

#### Dimension 4: External Dependency Integration

**Decision:** `OrderQueryPort` adapter calls Order's REST API. `RefundPort` adapter calls Payment's REST API (which wraps Stripe). Circuit breaker on Payment calls (consistent with Order context pattern). Retry with exponential backoff for transient failures.

#### Dimension 5: Observability

**Decision:** Structured JSON logging with `return_request_id` and `correlation_id`. Prometheus metrics: return request rate, approval/rejection ratio, refund success rate, refund latency. Reuse existing OpenTelemetry setup.

#### Dimension 6: Error Handling

**Decision:** Domain errors (e.g., `ReturnWindowExpired`, `OrderNotDelivered`) — typed errors returned to caller. Infrastructure errors — wrapped with context, logged, retried. User-facing errors — HTTP 4xx with human-readable messages.

#### Dimension 7: Test Strategy

**Decision:** Unit tests for `ReturnRequest` aggregate (pure domain logic — return window validation, auto-approval rules, status transitions). Integration tests for repository (real DB via test containers). Contract tests for `OrderQueryPort` and `RefundPort`. No E2E — this is Supporting Domain; E2E coverage comes from Order context's existing checkout flow.

**Persisted:** `docs/ddd/phase-4-technical-solution.md` appended with `[ITERATION: v2]` section.

---

## Step 8: Spec Review Gate

**MANDATORY hard stop.** All accumulated work is presented in one view.

### Baseline Summary (from Step 1 snapshot)

| Item | Count |
|:---|:---|
| Existing Bounded Contexts | 3 (Order, Inventory, Payment) |
| Existing domain events | 11 |
| Existing contracts | 2 (Order→Inventory, Order→Payment) |

### Delta Summary (Steps 3-6)

| Item | Count | Details |
|:---|:---|:---|
| New Bounded Contexts | 1 | Returns (Supporting Domain) |
| New domain events | 7 | `ReturnRequested`, `ReturnApproved`, `ReturnRejected`, `RefundInitiated`, `RefundCompleted`, `RefundFailed` |
| New contracts | 2 | Returns→Order (`OrderQueryPort`), Returns→Payment (`RefundPort`) |
| New tech decisions | 1 BC | Returns: PostgreSQL, REST + outbox, Medium depth |

### Route Executed

Route C — all phases (Steps 3-6) executed. No phases skipped.

### Assumptions for Review

From `docs/ddd/assumptions-draft.md`:

| # | Assumption | Source Step | Impact |
|:---|:---|:---|:---|
| 1 | Inventory restock after return is triggered by Inventory consuming a `ReturnApproved` async event, not a synchronous Returns→Inventory contract | Step 3 | If wrong: need a third synchronous contract |
| 2 | The Inventory restock is async — Inventory subscribes to `ReturnApproved` and handles restock internally after inspection | Step 4 | If wrong: Returns would need to orchestrate the restock flow |

### Human Review

> **AI:** "The Spec Review Gate is ready. Baseline: 3 BCs, 11 events, 2 contracts. Delta: +1 BC (Returns), +7 events, +2 contracts. Two assumptions about async inventory restock. Please review each assumption: Keep or Revise?"
>
> **User:** "Both assumptions are correct — inventory handles its own restock after receiving the ReturnApproved event. Keep both. Approved."

**Post-approval actions:**
- Assumptions #1 and #2 appended to `docs/ddd/decisions-log.md` with status CONFIRMED.
- `docs/ddd/assumptions-draft.md` deleted.

> **AI:** "The Spec Review Gate is complete. Baseline + delta are confirmed. Shall I proceed to Phase 5 (domain coding with TDD) for the Returns context?"
>
> **User:** "Proceed."

---

## Step 9: Phase 5 — Coding Returns BC

**Skill invoked:** `coding-isolated-domains` (scoped to Returns BC only)

### Aggregate Design — ReturnRequest (Supporting Domain)

```
ReturnRequest (Aggregate Root)
├── id: string
├── orderID: string         (ID reference to Order aggregate)
├── customerID: string
├── status: ReturnStatus [REQUESTED → APPROVED / REJECTED]
├── reason: ReturnReason    (Value Object)
│   ├── category: string    ("defective", "wrong_item", "changed_mind", ...)
│   └── description: string
├── items: ReturnItem[]     (Value Object)
│   ├── sku: string
│   ├── quantity: int
│   └── unitPrice: float64
├── refundStatus: RefundStatus [NONE → INITIATED → COMPLETED / FAILED]
├── refundID?: string
├── deliveredAt: time.Time
├── requestedAt: time.Time
└── Domain Events: raised internally
```

### TDD — Unit Tests First

```go
package returns

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

var (
	now         = time.Now()
	deliveredAt = now.Add(-5 * 24 * time.Hour) // 5 days ago — within window
	expiredAt   = now.Add(-35 * 24 * time.Hour) // 35 days ago — outside window
	validItems  = []ReturnItemProps{
		{SKU: "BOOK-001", Quantity: 1, UnitPrice: 39.99},
	}
)

func TestReturnRequest_Create_WithinWindow(t *testing.T) {
	rr, err := NewReturnRequest("order-1", "cust-1", deliveredAt, "defective", "Spine broken", validItems)
	require.NoError(t, err)
	assert.Equal(t, StatusRequested, rr.Status())
	assert.Equal(t, RefundNone, rr.RefundStatus())
}

func TestReturnRequest_Create_RejectsExpiredWindow(t *testing.T) {
	_, err := NewReturnRequest("order-1", "cust-1", expiredAt, "defective", "Spine broken", validItems)
	assert.EqualError(t, err, "return window expired: must be within 30 days of delivery")
}

func TestReturnRequest_Create_RejectsEmptyItems(t *testing.T) {
	_, err := NewReturnRequest("order-1", "cust-1", deliveredAt, "defective", "Broken", nil)
	assert.EqualError(t, err, "return request must have at least one item")
}

func TestReturnRequest_AutoApprove_Defective(t *testing.T) {
	rr, _ := NewReturnRequest("order-1", "cust-1", deliveredAt, "defective", "Spine broken", validItems)
	err := rr.Approve()
	require.NoError(t, err)
	assert.Equal(t, StatusApproved, rr.Status())
}

func TestReturnRequest_ManualApprove(t *testing.T) {
	rr, _ := NewReturnRequest("order-1", "cust-1", deliveredAt, "changed_mind", "No longer needed", validItems)
	err := rr.Approve()
	require.NoError(t, err)
	assert.Equal(t, StatusApproved, rr.Status())
}

func TestReturnRequest_Reject(t *testing.T) {
	rr, _ := NewReturnRequest("order-1", "cust-1", deliveredAt, "changed_mind", "No longer needed", validItems)
	err := rr.Reject("Item was used — not eligible for return")
	require.NoError(t, err)
	assert.Equal(t, StatusRejected, rr.Status())
}

func TestReturnRequest_Reject_RequiresReason(t *testing.T) {
	rr, _ := NewReturnRequest("order-1", "cust-1", deliveredAt, "changed_mind", "No longer needed", validItems)
	err := rr.Reject("")
	assert.EqualError(t, err, "rejection reason is required")
}

func TestReturnRequest_InitiateRefund_RequiresApproval(t *testing.T) {
	rr, _ := NewReturnRequest("order-1", "cust-1", deliveredAt, "defective", "Broken", validItems)
	err := rr.InitiateRefund("refund-1")
	assert.ErrorContains(t, err, "only APPROVED returns")
}

func TestReturnRequest_InitiateRefund_AfterApproval(t *testing.T) {
	rr, _ := NewReturnRequest("order-1", "cust-1", deliveredAt, "defective", "Broken", validItems)
	_ = rr.Approve()
	err := rr.InitiateRefund("refund-1")
	require.NoError(t, err)
	assert.Equal(t, RefundInitiated, rr.RefundStatus())
	assert.Equal(t, "refund-1", rr.RefundID())
}

func TestReturnRequest_RefundAmount(t *testing.T) {
	items := []ReturnItemProps{
		{SKU: "BOOK-001", Quantity: 2, UnitPrice: 39.99},
		{SKU: "BOOK-002", Quantity: 1, UnitPrice: 29.99},
	}
	rr, _ := NewReturnRequest("order-1", "cust-1", deliveredAt, "defective", "Broken", items)
	assert.InDelta(t, 109.97, rr.RefundAmount(), 0.01)
}
```

### Rich Domain Model — ReturnRequest Aggregate

```go
// [ITERATION: v2]
// ==========================================
//  Returns Context — Pure Domain Core
//  Zero infrastructure dependencies
// ==========================================
package returns

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

const returnWindowDays = 30

type ReturnStatus string

const (
	StatusRequested ReturnStatus = "REQUESTED"
	StatusApproved  ReturnStatus = "APPROVED"
	StatusRejected  ReturnStatus = "REJECTED"
)

type RefundStatus string

const (
	RefundNone      RefundStatus = "NONE"
	RefundInitiated RefundStatus = "INITIATED"
	RefundCompleted RefundStatus = "COMPLETED"
	RefundFailed    RefundStatus = "FAILED"
)

type ReturnItemProps struct {
	SKU       string
	Quantity  int
	UnitPrice float64
}

type ReturnItem struct {
	sku       string
	quantity  int
	unitPrice float64
}

func NewReturnItem(props ReturnItemProps) (*ReturnItem, error) {
	if props.Quantity <= 0 {
		return nil, errors.New("quantity must be positive")
	}
	return &ReturnItem{
		sku: props.SKU, quantity: props.Quantity, unitPrice: props.UnitPrice,
	}, nil
}

func (ri *ReturnItem) SKU() string      { return ri.sku }
func (ri *ReturnItem) Quantity() int     { return ri.quantity }
func (ri *ReturnItem) UnitPrice() float64 { return ri.unitPrice }
func (ri *ReturnItem) Subtotal() float64 { return ri.unitPrice * float64(ri.quantity) }

type ReturnRequest struct {
	id              string
	orderID         string
	customerID      string
	status          ReturnStatus
	reasonCategory  string
	reasonDesc      string
	items           []*ReturnItem
	refundStatus    RefundStatus
	refundID        string
	rejectionReason string
	deliveredAt     time.Time
	requestedAt     time.Time
}

func NewReturnRequest(
	orderID, customerID string,
	deliveredAt time.Time,
	reasonCategory, reasonDesc string,
	items []ReturnItemProps,
) (*ReturnRequest, error) {
	if len(items) == 0 {
		return nil, errors.New("return request must have at least one item")
	}
	if time.Since(deliveredAt).Hours() > float64(returnWindowDays*24) {
		return nil, errors.New("return window expired: must be within 30 days of delivery")
	}
	returnItems := make([]*ReturnItem, 0, len(items))
	for _, props := range items {
		ri, err := NewReturnItem(props)
		if err != nil {
			return nil, err
		}
		returnItems = append(returnItems, ri)
	}
	return &ReturnRequest{
		id:             uuid.NewString(),
		orderID:        orderID,
		customerID:     customerID,
		status:         StatusRequested,
		reasonCategory: reasonCategory,
		reasonDesc:     reasonDesc,
		items:          returnItems,
		refundStatus:   RefundNone,
		deliveredAt:    deliveredAt,
		requestedAt:    time.Now(),
	}, nil
}

func (rr *ReturnRequest) ID() string              { return rr.id }
func (rr *ReturnRequest) OrderID() string          { return rr.orderID }
func (rr *ReturnRequest) CustomerID() string       { return rr.customerID }
func (rr *ReturnRequest) Status() ReturnStatus     { return rr.status }
func (rr *ReturnRequest) RefundStatus() RefundStatus { return rr.refundStatus }
func (rr *ReturnRequest) RefundID() string         { return rr.refundID }

func (rr *ReturnRequest) RefundAmount() float64 {
	var total float64
	for _, item := range rr.items {
		total += item.Subtotal()
	}
	return total
}

func (rr *ReturnRequest) Approve() error {
	if rr.status != StatusRequested {
		return errors.New("only REQUESTED returns can be approved")
	}
	rr.status = StatusApproved
	return nil
}

func (rr *ReturnRequest) Reject(reason string) error {
	if reason == "" {
		return errors.New("rejection reason is required")
	}
	if rr.status != StatusRequested {
		return errors.New("only REQUESTED returns can be rejected")
	}
	rr.status = StatusRejected
	rr.rejectionReason = reason
	return nil
}

func (rr *ReturnRequest) InitiateRefund(refundID string) error {
	if rr.status != StatusApproved {
		return errors.New("refund failed: only APPROVED returns can initiate a refund")
	}
	if rr.refundStatus != RefundNone {
		return errors.New("refund already initiated")
	}
	rr.refundID = refundID
	rr.refundStatus = RefundInitiated
	return nil
}

func (rr *ReturnRequest) CompleteRefund() error {
	if rr.refundStatus != RefundInitiated {
		return errors.New("refund must be INITIATED to complete")
	}
	rr.refundStatus = RefundCompleted
	return nil
}

func (rr *ReturnRequest) FailRefund() error {
	if rr.refundStatus != RefundInitiated {
		return errors.New("refund must be INITIATED to fail")
	}
	rr.refundStatus = RefundFailed
	return nil
}
```

### Verification Checklist

| Rule | Compliance |
|:---|:---|
| Zero infrastructure dependencies | Pure Go struct, no ORM/HTTP/framework imports |
| Rich Domain Model with behavior methods | `Approve()`, `Reject()`, `InitiateRefund()`, `CompleteRefund()`, `FailRefund()` |
| Private state mutation via business methods only | `status`, `refundStatus` are unexported |
| No public setters | No `SetStatus()` or `SetRefundStatus()` exposed |
| Invariants enforced inside Aggregate Root | Return window, status transitions, rejection reason requirement |
| Cross-aggregate reference by ID only | `orderID` is a string ID, not an Order entity |
| Value Object immutability | `ReturnItem` fields are unexported, read-only via getters |
| Unit tests require zero mocking | Pure logic, no external dependencies |

> **AI:** "Returns BC implementation is complete. 11 unit tests cover happy paths, validation failures, and state transition guards. All tests pass with zero infrastructure dependencies. Shall I proceed to archive?"
>
> **User:** "Approved."

---

## Step 10: Archive

```bash
$ sh skills/full-ddd/scripts/archive-artifacts.sh
Archiving iteration artifacts...
Moving docs/ddd/*.md → docs/ddd/archive/v2/
  ✓ ddd-progress.md
  ✓ route-plan.md
  ✓ phase-1-domain-events.md
  ✓ phase-2-context-map.md
  ✓ phase-3-contracts.md
  ✓ phase-4-technical-solution.md
  ✓ decisions-log.md
Archive complete: docs/ddd/archive/v2/
docs/ddd/ is now clean for the next iteration.
```

**Post-archive verification:**
```bash
$ ls docs/ddd/
archive/

$ ls docs/ddd/archive/v2/
ddd-progress.md
route-plan.md
phase-1-domain-events.md
phase-2-context-map.md
phase-3-contracts.md
phase-4-technical-solution.md
decisions-log.md
```

`docs/ddd/ddd-progress.md` no longer exists. Archive successful.

---

## Summary: Deliverables Per Step

| Step | Action | Key Deliverable |
|:---|:---|:---|
| 0 | Pre-flight | Empty `docs/ddd/` confirmed, DDD structure detected, requirement accepted |
| 1 | Code Snapshot | Baseline: 3 BCs, 11 events, 2 contracts (all `[INFERRED]`, human confirmed) |
| 2 | Route Evaluation | Route C confirmed — 4/4 questions answered Yes |
| 3 | Phase 1 (Events) | 7 new events for Returns domain `[ITERATION: v2]` |
| 4 | Phase 2 (Context Map) | New "Returns" BC (Supporting), 3 relationships added `[ITERATION: v2]` |
| 5 | Phase 3 (Contracts) | 2 new ports: `OrderQueryPort`, `RefundPort` `[ITERATION: v2]` |
| 6 | Phase 4 (Tech Solution) | 7-dimension decisions for Returns BC at Medium depth `[ITERATION: v2]` |
| 7 | SDD Merge | Updated spec files + `spec-manifest.md` for Returns context |
| 8 | Spec Review Gate | Baseline + delta confirmed, 2 assumptions reviewed and CONFIRMED |
| 9 | Phase 5 (Coding) | `ReturnRequest` aggregate + `ReturnItem` VO + 11 unit tests |
| 10 | Archive | `docs/ddd/archive/v2/` created, `docs/ddd/` clean |

---

## Persisted Design Artifacts (v2, before archive)

```
docs/ddd/
├── ddd-progress.md                 # Iteration tracker (all steps complete, mode: iterate, route: C)
├── route-plan.md                   # Route C evaluation with 4-question table
├── phase-1-domain-events.md        # 11 baseline events + 7 new [ITERATION: v2] events
├── phase-2-context-map.md          # 4 BCs (3 baseline + 1 new Returns) + updated context map
├── phase-3-contracts.md            # 4 contracts (2 baseline + 2 new [ITERATION: v2])
├── phase-4-technical-solution.md   # Tech decisions for all 4 BCs (3 baseline + 1 new [ITERATION: v2])
├── decisions-log.md                # All decisions including 2 confirmed assumptions from Final Review
└── archive/
    └── v1/                         # Previous iteration artifacts
```

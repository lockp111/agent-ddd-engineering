# End-to-End Walkthrough: Online Bookstore Checkout

> This document demonstrates the complete 5-phase DDD workflow applied to a realistic business scenario. Each phase shows the **expected deliverable** after interactive Q&A with the user.

---

## Input: Product Requirements Document (PRD)

> **Feature: Online Bookstore Checkout**
>
> Users browse the bookstore catalog, add books to their shopping cart, and proceed to checkout. During checkout, the system must:
> 1. Verify that all items are in stock and reserve inventory.
> 2. Authorize the payment via an external payment gateway.
> 3. Confirm the order and start the fulfillment process.
> 4. If payment fails or inventory is insufficient, gracefully cancel the process and notify the user.
> 5. Users can cancel an unpaid order within 30 minutes.

---

## Phase 1: Extracting Domain Events

**Skill invoked:** `extracting-domain-events`

### Deliverable: Domain Events Table

| Actor | Command | Domain Event | Business Rules / Invariants |
|:---|:---|:---|:---|
| Customer | Add Item to Cart | `ItemAddedToCart` | Book must exist in catalog; quantity ≥ 1. |
| Customer | Remove Item from Cart | `ItemRemovedFromCart` | Item must exist in cart. |
| Customer | Submit Checkout | `CheckoutSubmitted` | Cart must not be empty; user must be authenticated. |
| System | Reserve Inventory | `InventoryReserved` | Sufficient stock for all items in the order. |
| System | Reserve Inventory | `InventoryShortageDetected` | Triggered when any item has insufficient stock. |
| Payment Gateway | Authorize Payment | `PaymentAuthorized` | Payment method valid; amount matches order total. |
| Payment Gateway | Authorize Payment | `PaymentFailed` | Card declined, insufficient funds, or gateway error. |
| System | Confirm Order | `OrderConfirmed` | Requires both `InventoryReserved` AND `PaymentAuthorized`. |
| Customer | Cancel Order | `OrderCancelled` | Order must be in PENDING status; within 30-min window. |
| System | Release Inventory | `InventoryReleased` | Compensating event triggered by `OrderCancelled` or `PaymentFailed`. |
| System | Ship Order | `OrderShipped` | Order must be CONFIRMED; all items packed. |
| System | Deliver Order | `OrderDelivered` | Shipment arrived; confirmed by logistics provider. |

### Key Q&A During This Phase

> **AI:** "The PRD mentions a 30-minute cancellation window. Should `OrderCancelled` also trigger a payment refund if payment was already authorized?"
>
> **User:** "Yes — if payment was authorized, cancellation must also trigger a refund."
>
> **AI:** (adds compensating event)

| Actor | Command | Domain Event | Business Rules / Invariants |
|:---|:---|:---|:---|
| System | Refund Payment | `PaymentRefunded` | Compensating event triggered by `OrderCancelled` after `PaymentAuthorized`. |

> **AI:** "Does this events table cover all happy paths and failure scenarios? Should any events be added, renamed, or removed?"
>
> **User:** "Approved. Let's proceed."

---

## Phase 2: Mapping Bounded Contexts

**Skill invoked:** `mapping-bounded-contexts`

### Step 1: Event Clustering → Proposed Boundaries

| Bounded Context | Included Events | Core Responsibility |
|:---|:---|:---|
| **Catalog** | *(Query only, no domain events)* | Book browsing, search, and metadata management. |
| **Cart** | `ItemAddedToCart`, `ItemRemovedFromCart` | Temporary shopping session; pre-order item management. |
| **Order** | `CheckoutSubmitted`, `OrderConfirmed`, `OrderCancelled`, `OrderShipped`, `OrderDelivered` | Order lifecycle from checkout to delivery. |
| **Inventory** | `InventoryReserved`, `InventoryShortageDetected`, `InventoryReleased` | Stock level tracking and time-boxed reservation management. |
| **Payment** | `PaymentAuthorized`, `PaymentFailed`, `PaymentRefunded` | Payment authorization and refund via external gateway. |

### Step 2: Strategic Classification

| Context | Classification | Rationale |
|:---|:---|:---|
| **Order** | 🔴 Core Domain | Primary business differentiator — order lifecycle, cancellation policies, and fulfillment orchestration define the bookstore's competitive edge. Demands Rich Domain Model + Hexagonal Architecture. |
| **Inventory** | 🔴 Core Domain | Stock management and reservation logic are critical to the business. Incorrect reservation = overselling = customer churn. |
| **Cart** | 🟡 Supporting | Necessary but not a differentiator. Can use a simpler architecture (e.g., CRUD + lightweight validation). |
| **Catalog** | 🟡 Supporting | Read-heavy, query-optimized. Can use CQRS read model or simple service. |
| **Payment** | ⚪ Generic | Solved problem — wraps external payment gateway. Should use off-the-shelf SDK + thin adapter. |

### Step 3: Context Map (Relationship Patterns)

```
┌──────────┐    Open Host     ┌───────────┐
│ Catalog  │ ───────────────▶ │   Cart    │
└──────────┘   (published     └─────┬─────┘
               book data)           │
                                    │ Conformist
                                    │ (cart sends items as-is)
                                    ▼
┌──────────┐    ACL           ┌───────────┐     ACL        ┌───────────┐
│Inventory │ ◀─────────────── │   Order   │ ─────────────▶ │  Payment  │
│          │ ──────────────▶  │  (Core)   │ ◀───────────── │           │
└──────────┘  Customer-       └───────────┘   Customer-    └───────────┘
              Supplier                        Supplier
```

- **Order ↔ Inventory:** Customer-Supplier. Order (downstream) requests reservation; Inventory (upstream) provides stock status. Order builds ACL to translate Inventory events.
- **Order ↔ Payment:** Customer-Supplier. Order requests payment authorization; Payment provides result. Order builds ACL for payment events.
- **Catalog → Cart:** Open Host Service. Catalog publishes standardized book metadata; Cart consumes it directly (Conformist).

### Step 4: Ubiquitous Language Dictionaries

**Order Context:**

| Term | Definition | Prohibited Synonyms |
|:---|:---|:---|
| `Order` | A confirmed purchase request with one or more line items. | ~~Purchase~~, ~~Transaction~~, ~~Sale~~ |
| `LineItem` | A single book entry within an Order, with quantity and unit price. | ~~OrderItem~~, ~~CartItem~~, ~~Product~~ |
| `OrderStatus` | The lifecycle state: PENDING → CONFIRMED → SHIPPED → DELIVERED / CANCELLED. | ~~State~~, ~~Phase~~ |

**Inventory Context:**

| Term | Definition | Prohibited Synonyms |
|:---|:---|:---|
| `StockLevel` | The available quantity of a specific book (SKU). | ~~Quantity~~, ~~Amount~~, ~~Count~~ |
| `Reservation` | A time-boxed lock on inventory for a pending order. | ~~Hold~~, ~~Lock~~, ~~Block~~ |
| `SKU` | Stock Keeping Unit — the unique book identifier in inventory. | ~~BookId~~, ~~ProductId~~ |

**Payment Context:**

| Term | Definition | Prohibited Synonyms |
|:---|:---|:---|
| `Authorization` | A verified hold on the customer's funds. | ~~Charge~~, ~~Payment~~ |
| `Refund` | A reversal of a previous authorization. | ~~Reversal~~, ~~Chargeback~~ |

### Step 5: Generated Constraint File (Cursor)

`.cursor/rules/order-context.mdc`:
```markdown
---
description: Bounded Context rules for the Order domain (Core Domain).
globs:
  - "internal/order/**/*"
---

# Order Context — Core Domain

## Architecture
- Hexagonal Architecture mandatory. Domain core must have ZERO infrastructure imports.
- All entities must be Rich Domain Models with behavior methods.
- Aggregates reference other aggregates by ID only.

## Ubiquitous Language
- Use `Order`, NOT ~~Purchase/Transaction/Sale~~.
- Use `LineItem`, NOT ~~OrderItem/CartItem/Product~~.
- Use `OrderStatus`, NOT ~~State/Phase~~.

## Dependency Rules
- NEVER import from `internal/inventory/`, `internal/payment/`, or `internal/catalog/` directly.
- Cross-context communication ONLY through approved interface contracts (Ports).
- Inventory data enters via `InventoryServicePort` (ACL).
- Payment data enters via `PaymentServicePort` (ACL).
```

> **AI:** "Do these boundaries align with the business structure? Are the relationship patterns correct?"
>
> **User:** "Approved."

## Phase 3: Designing Contracts First

**Skill invoked:** `designing-contracts-first`

### Contract 1: Order → Inventory (Customer-Supplier + ACL)

```go
// === Inventory Port (defined in Order context's domain layer) ===
package order

type ReserveInventoryRequest struct {
	OrderID string
	Items   []ReserveInventoryItem
}

type ReserveInventoryItem struct {
	SKU      string
	Quantity int
}

type ReservationStatus string

const (
	ReservationReserved ReservationStatus = "RESERVED"
	ReservationShortage ReservationStatus = "SHORTAGE"
)

type ShortageItem struct {
	SKU               string
	AvailableQuantity int
	RequestedQuantity int
}

type InventoryReservationResult struct {
	ReservationID string
	OrderID       string
	Status        ReservationStatus
	ShortageItems []ShortageItem
}

type InventoryServicePort interface {
	Reserve(req ReserveInventoryRequest) (*InventoryReservationResult, error)
	Release(reservationID string) error
}
```

### Contract 2: Order → Payment (Customer-Supplier + ACL)

```go
// === Payment Port (defined in Order context's domain layer) ===
package order

type AuthorizePaymentRequest struct {
	OrderID             string
	Amount              float64
	Currency            string
	PaymentMethodToken  string
}

type AuthorizationStatus string

const (
	AuthorizationAuthorized AuthorizationStatus = "AUTHORIZED"
	AuthorizationFailed     AuthorizationStatus = "FAILED"
)

type PaymentAuthorizationResult struct {
	AuthorizationID string
	OrderID         string
	Status          AuthorizationStatus
	FailureReason   string
}

type PaymentServicePort interface {
	Authorize(req AuthorizePaymentRequest) (*PaymentAuthorizationResult, error)
	Refund(authorizationID string) error
}
```

### Boundary Challenge (Mandatory)

> **AI:** "Both contracts pass minimal data (IDs, quantities, amounts) across boundaries. Neither contract exposes deep domain concepts like `Order` entities or `StockLevel` internals. The Boundary Challenge passes."

> **AI:** "Do these contracts fulfill both sides without leaking internal business rules?"
>
> **User:** "Approved."

---

## Phase 4: Technical Solution

**Skill invoked:** `architecting-technical-solution`

> The approved contracts define *what* the boundaries look like. Phase 4 decides *how* to realize them technically — data models, interface types, consistency strategies, and more. Depth adapts to each context's strategic classification from Phase 2.

### Context Index

| Bounded Context | Classification | Depth Level |
|:---|:---|:---|
| **Order** | 🔴 Core Domain | Full RFC |
| **Inventory** | 🔴 Core Domain | Full RFC |
| **Cart** | 🟡 Supporting | Medium |
| **Catalog** | 🟡 Supporting | Medium |
| **Payment** | 🟢 Generic | Lightweight |

---

### Order Context — Full RFC (Core Domain)

**Skill Step 1: Strategic Classification confirmed** → Core Domain → Full RFC depth

#### Dimension 1: Data Model & Persistence

| Option | Trade-offs |
|:---|:---|
| PostgreSQL (normalized) | ACID transactions, mature tooling, good for complex queries; requires schema migrations |
| PostgreSQL (JSONB for line items) | Flexible item structure, fewer joins; harder to query individual items |
| Event Store | Natural fit for event-sourced Order aggregate; operational complexity |

**Decision:** PostgreSQL with normalized schema. `orders` table with status enum; `order_items` as separate table for query flexibility. UUIDs as primary keys. Flyway for migrations.

#### Dimension 2: Interface Type

| Option | Trade-offs |
|:---|:---|
| HTTP REST | Synchronous, widely understood, easy to debug; tight coupling on availability |
| Async events (outbox pattern) | Decoupled, resilient; eventual consistency, harder to trace |
| gRPC | Efficient binary protocol; requires proto definitions, less human-readable |

**Decision:** HTTP REST for synchronous API (checkout submission, order status queries). Async domain events via outbox pattern for cross-context notifications (`OrderConfirmed` → Inventory, Payment).

#### Dimension 3: Consistency Strategy

**Decision:** Saga pattern with compensating events for the Order→Inventory→Payment flow. Each step publishes an event; failures trigger compensating events (`InventoryReleased`, `PaymentRefunded`). No distributed transactions.

#### Dimension 4: External Dependency Integration

**Decision:** Wrap `InventoryServicePort` and `PaymentGatewayPort` in adapter implementations. Circuit breaker on Payment gateway calls (3 retries, exponential backoff). Fallback: fail order with `PaymentFailed` event.

#### Dimension 5: Observability

**Decision:** Structured JSON logging with `order_id` and `correlation_id` on every log line. Prometheus metrics: order throughput, checkout latency (p50/p95/p99), payment failure rate. Distributed tracing via OpenTelemetry.

#### Dimension 6: Error Handling

**Decision:** Three error categories: (1) Domain errors (e.g., `OrderAlreadyCancelled`) — typed, returned to caller; (2) Infrastructure errors (e.g., DB timeout) — wrapped with context, logged, retried; (3) User-facing errors — mapped to HTTP 4xx with human-readable messages.

#### Dimension 7: Test Strategy

**Decision:** Unit tests for Order aggregate (pure domain logic, no mocks needed). Integration tests for repository (real DB, test containers). Contract tests for `InventoryServicePort` and `PaymentGatewayPort`. E2E test for the full checkout flow.

> **AI:** "Are these decisions grounded in the domain events and contracts, or speculative? The Saga pattern traces directly to `InventoryReleased` and `PaymentRefunded` compensating events from Phase 1. The outbox pattern traces to the cross-context event contracts from Phase 3."
>
> **User:** "Approved. Proceed."

---

### Cart Context — Medium (Supporting)

**Key dimensions only:**

- **Persistence:** Redis for session storage (TTL-based cart expiry aligns with business rule: cart expires after 24h inactivity). PostgreSQL fallback for persistent carts.
- **Interface Type:** HTTP REST. Simple CRUD operations; no cross-context events needed.
- **Consistency:** Single-context transactions. No saga needed.
- **Error Handling:** Domain errors for invalid operations (empty cart checkout); infrastructure errors wrapped and logged.

---

### Payment Context — Lightweight (Generic)

- **Persistence:** Use Stripe's built-in state management. No local persistence beyond event log.
- **Interface Type:** Stripe SDK (vendor-provided).
- **Consistency:** Stripe handles idempotency via idempotency keys.
- **All other dimensions:** Use Stripe's built-in conventions.

---

### Human Approval Checkpoint

> **AI:** "Phase 4 Technical Solution decisions are ready for review. Order and Inventory contexts use Full RFC depth (Saga pattern, PostgreSQL, outbox events). Cart uses Medium depth (Redis + REST). Payment uses Lightweight (Stripe SDK). Do you approve these technology choices?"
>
> **User:** "Approved. Persist and proceed to coding."

**Persisted to:** `docs/ddd/phase-4-technical-solution.md`

## Phase 5: Coding Isolated Domains

**Skill invoked:** `coding-isolated-domains`

### Step 1: Aggregate Design — Order (Core Domain)

```
Order (Aggregate Root)
├── id: string
├── customerId: string
├── status: OrderStatus [PENDING → CONFIRMED → SHIPPED → DELIVERED | CANCELLED]
├── lineItems: LineItem[]  (Value Object)
│   ├── sku: string
│   ├── title: string
│   ├── unitPrice: number
│   └── quantity: number
├── reservationId?: string  (ID reference to Inventory aggregate)
├── authorizationId?: string  (ID reference to Payment aggregate)
├── createdAt: Date
└── Domain Events: raised internally
```

> **AI:** "Does this accurately represent the business concepts? Have we missed any critical invariants?"
>
> **User:** "Add a `totalAmount()` calculation. Otherwise approved."

### Step 2: TDD — Unit Tests First

```go
package order

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

var validItems = []LineItemProps{
	{SKU: "BOOK-001", Title: "DDD Distilled", UnitPrice: 39.99, Quantity: 2},
	{SKU: "BOOK-002", Title: "Clean Architecture", UnitPrice: 29.99, Quantity: 1},
}

func TestOrder_Create_Pending(t *testing.T) {
	order, err := NewOrder("customer-1", validItems)
	require.NoError(t, err)
	assert.Equal(t, StatusPending, order.Status())
	assert.Len(t, order.LineItems(), 2)
}

func TestOrder_Create_RejectsEmptyItems(t *testing.T) {
	_, err := NewOrder("customer-1", nil)
	assert.EqualError(t, err, "order must have at least one line item")
}

func TestOrder_Create_RejectsNonPositiveQuantity(t *testing.T) {
	_, err := NewOrder("customer-1", []LineItemProps{
		{SKU: "BOOK-001", Title: "Test", UnitPrice: 10, Quantity: 0},
	})
	assert.EqualError(t, err, "quantity must be positive")
}

func TestOrder_TotalAmount(t *testing.T) {
	order, _ := NewOrder("customer-1", validItems)
	assert.InDelta(t, 109.97, order.TotalAmount(), 0.01) // 39.99*2 + 29.99*1
}

func TestOrder_ConfirmReservation(t *testing.T) {
	order, _ := NewOrder("customer-1", validItems)
	err := order.ConfirmReservation("reservation-abc")
	require.NoError(t, err)
	assert.Equal(t, "reservation-abc", order.ReservationID())
}

func TestOrder_ConfirmReservation_RejectsNonPending(t *testing.T) {
	order, _ := NewOrder("customer-1", validItems)
	_ = order.Cancel()
	err := order.ConfirmReservation("res-1")
	assert.ErrorContains(t, err, "only PENDING orders")
}

func TestOrder_ConfirmPayment_TransitionsToConfirmed(t *testing.T) {
	order, _ := NewOrder("customer-1", validItems)
	_ = order.ConfirmReservation("res-1")
	err := order.ConfirmPayment("auth-1")
	require.NoError(t, err)
	assert.Equal(t, StatusConfirmed, order.Status())
	assert.Equal(t, "auth-1", order.AuthorizationID())
}

func TestOrder_ConfirmPayment_RejectsWithoutReservation(t *testing.T) {
	order, _ := NewOrder("customer-1", validItems)
	err := order.ConfirmPayment("auth-1")
	assert.ErrorContains(t, err, "inventory must be reserved")
}

func TestOrder_Cancel_PendingOrder(t *testing.T) {
	order, _ := NewOrder("customer-1", validItems)
	err := order.Cancel()
	require.NoError(t, err)
	assert.Equal(t, StatusCancelled, order.Status())
}

func TestOrder_Cancel_RejectsShippedOrder(t *testing.T) {
	order, _ := NewOrder("customer-1", validItems)
	_ = order.ConfirmReservation("res-1")
	_ = order.ConfirmPayment("auth-1")
	_ = order.Ship()
	err := order.Cancel()
	assert.ErrorContains(t, err, "cannot cancel")
}

func TestOrder_Ship_ConfirmedOrder(t *testing.T) {
	order, _ := NewOrder("customer-1", validItems)
	_ = order.ConfirmReservation("res-1")
	_ = order.ConfirmPayment("auth-1")
	err := order.Ship()
	require.NoError(t, err)
	assert.Equal(t, StatusShipped, order.Status())
}
```

> **AI:** "Do these tests cover all expected behaviors and edge cases? Shall I proceed to implement?"
>
> **User:** "Approved."

### Step 3: Rich Domain Model Implementation

```go
// ==========================================
//  Order Context — Pure Domain Core
//  Zero infrastructure dependencies
// ==========================================
package order

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

type OrderStatus string

const (
	StatusPending   OrderStatus = "PENDING"
	StatusConfirmed OrderStatus = "CONFIRMED"
	StatusShipped   OrderStatus = "SHIPPED"
	StatusDelivered OrderStatus = "DELIVERED"
	StatusCancelled OrderStatus = "CANCELLED"
)

type LineItemProps struct {
	SKU       string
	Title     string
	UnitPrice float64
	Quantity  int
}

type LineItem struct {
	sku       string
	title     string
	unitPrice float64
	quantity  int
}

func NewLineItem(props LineItemProps) (*LineItem, error) {
	if props.Quantity <= 0 {
		return nil, errors.New("quantity must be positive")
	}
	if props.UnitPrice < 0 {
		return nil, errors.New("unit price cannot be negative")
	}
	return &LineItem{
		sku:       props.SKU,
		title:     props.Title,
		unitPrice: props.UnitPrice,
		quantity:  props.Quantity,
	}, nil
}

func (li *LineItem) SKU() string      { return li.sku }
func (li *LineItem) Title() string    { return li.title }
func (li *LineItem) UnitPrice() float64 { return li.unitPrice }
func (li *LineItem) Quantity() int     { return li.quantity }
func (li *LineItem) Subtotal() float64 { return li.unitPrice * float64(li.quantity) }

type Order struct {
	id              string
	customerID      string
	status          OrderStatus
	lineItems       []*LineItem
	reservationID   string
	authorizationID string
	createdAt       time.Time
}

func NewOrder(customerID string, items []LineItemProps) (*Order, error) {
	if len(items) == 0 {
		return nil, errors.New("order must have at least one line item")
	}
	lineItems := make([]*LineItem, 0, len(items))
	for _, props := range items {
		li, err := NewLineItem(props)
		if err != nil {
			return nil, err
		}
		lineItems = append(lineItems, li)
	}
	return &Order{
		id:         uuid.NewString(),
		customerID: customerID,
		status:     StatusPending,
		lineItems:  lineItems,
		createdAt:  time.Now(),
	}, nil
}

func (o *Order) ID() string                  { return o.id }
func (o *Order) CustomerID() string           { return o.customerID }
func (o *Order) Status() OrderStatus          { return o.status }
func (o *Order) LineItems() []*LineItem       { return o.lineItems }
func (o *Order) ReservationID() string        { return o.reservationID }
func (o *Order) AuthorizationID() string      { return o.authorizationID }
func (o *Order) CreatedAt() time.Time         { return o.createdAt }

func (o *Order) TotalAmount() float64 {
	var total float64
	for _, item := range o.lineItems {
		total += item.Subtotal()
	}
	return total
}

func (o *Order) ConfirmReservation(reservationID string) error {
	if o.status != StatusPending {
		return errors.New("reservation failed: only PENDING orders can have inventory reserved")
	}
	o.reservationID = reservationID
	return nil
}

func (o *Order) ConfirmPayment(authorizationID string) error {
	if o.reservationID == "" {
		return errors.New("payment failed: inventory must be reserved before payment")
	}
	if o.status != StatusPending {
		return errors.New("payment failed: only PENDING orders can be paid")
	}
	o.authorizationID = authorizationID
	o.status = StatusConfirmed
	return nil
}

func (o *Order) Cancel() error {
	if o.status == StatusShipped || o.status == StatusDelivered {
		return errors.New("cancellation failed: cannot cancel a shipped or delivered order")
	}
	if o.status == StatusCancelled {
		return errors.New("order is already cancelled")
	}
	o.status = StatusCancelled
	return nil
}

func (o *Order) Ship() error {
	if o.status != StatusConfirmed {
		return errors.New("shipping failed: only CONFIRMED orders can be shipped")
	}
	o.status = StatusShipped
	return nil
}

func (o *Order) Deliver() error {
	if o.status != StatusShipped {
		return errors.New("delivery failed: only SHIPPED orders can be delivered")
	}
	o.status = StatusDelivered
	return nil
}
```

### Verification Checklist

| Rule | Compliance |
|:---|:---|
| Zero infrastructure dependencies (no ORM, no HTTP, no framework decorators) | ✅ Pure Go struct, no gorm/json tags |
| Rich Domain Model (behavior methods, not just getters/setters) | ✅ `ConfirmReservation()`, `ConfirmPayment()`, `Cancel()`, `Ship()`, `Deliver()` |
| Private state mutation via business methods only | ✅ `status` is unexported, mutated only through behavior |
| No public setters | ✅ No `SetStatus()` exposed |
| Invariants enforced inside Aggregate Root | ✅ All state transitions validated |
| Cross-aggregate reference by ID only | ✅ `reservationID`, `authorizationID` are string IDs |
| Value Object immutability | ✅ `LineItem` fields are unexported, read-only via getters |
| Unit tests require zero mocking | ✅ Pure logic, no external dependencies |

---

## What Comes Next (Beyond Phase 5)

After the domain core is approved and tests pass, the workflow continues with:

1. **Application Services (Use Cases):** Orchestrate the domain model with injected Port interfaces.

```go
package application

import "context"

type CheckoutUseCase struct {
	orderRepo OrderRepository
	inventory InventoryServicePort
	payment   PaymentServicePort
}

func NewCheckoutUseCase(
	repo OrderRepository,
	inv InventoryServicePort,
	pay PaymentServicePort,
) *CheckoutUseCase {
	return &CheckoutUseCase{orderRepo: repo, inventory: inv, payment: pay}
}

func (uc *CheckoutUseCase) Execute(ctx context.Context, orderID string) error {
	order, err := uc.orderRepo.FindByID(ctx, orderID)
	if err != nil {
		return err
	}

	items := make([]ReserveInventoryItem, 0, len(order.LineItems()))
	for _, li := range order.LineItems() {
		items = append(items, ReserveInventoryItem{SKU: li.SKU(), Quantity: li.Quantity()})
	}

	reservation, err := uc.inventory.Reserve(ReserveInventoryRequest{
		OrderID: order.ID(),
		Items:   items,
	})
	if err != nil {
		return err
	}
	if reservation.Status == ReservationShortage {
		return &InventoryShortageError{ShortageItems: reservation.ShortageItems}
	}
	if err := order.ConfirmReservation(reservation.ReservationID); err != nil {
		return err
	}

	auth, err := uc.payment.Authorize(AuthorizePaymentRequest{
		OrderID:            order.ID(),
		Amount:             order.TotalAmount(),
		Currency:           "CNY",
		PaymentMethodToken: "tok_xxx", // from user session
	})
	if err != nil {
		return err
	}
	if auth.Status == AuthorizationFailed {
		_ = uc.inventory.Release(reservation.ReservationID)
		return &PaymentFailedError{Reason: auth.FailureReason}
	}
	if err := order.ConfirmPayment(auth.AuthorizationID); err != nil {
		return err
	}

	return uc.orderRepo.Save(ctx, order)
}
```

2. **Infrastructure Adapters:** Implement `OrderRepository` (e.g., GORM/sqlx), `InventoryServicePort` adapter (HTTP/gRPC to Inventory service), `PaymentServicePort` adapter (Stripe/Alipay SDK wrapper).

3. **Acceptance Tests:** Map each Domain Event from Phase 1 to an integration test scenario.

---

## Summary: Deliverables Per Phase

| Phase | Skill Invoked | Key Deliverable |
|:---|:---|:---|
| 1 | `extracting-domain-events` | Domain Events Table (13 events incl. failure paths) |
| 2 | `mapping-bounded-contexts` | 5 Bounded Contexts + Context Map + Dictionaries + `.cursor/rules/*.mdc` |
| 3 | `designing-contracts-first` | 2 Port Interfaces + Boundary Structs (Order↔Inventory, Order↔Payment) |
| 4 | `architecting-technical-solution` | Technical Solution decisions for all contexts (depth-adaptive: Core/Supporting/Generic) |
| 5 | `coding-isolated-domains` | Order Aggregate Root (Rich Model) + LineItem (Value Object) + 10 Unit Tests |

---

## Persisted Design Artifacts

After completing the full 5-phase workflow, the `docs/ddd/` directory contains the following files — ensuring all design decisions survive across sessions:

```
docs/ddd/
├── ddd-progress.md              # Workflow tracker (all phases complete)
├── phase-1-domain-events.md     # 13 approved domain events incl. failure paths
├── phase-2-context-map.md       # 5 bounded contexts + relationships + dictionaries
├── phase-3-contracts.md         # 2 port interfaces + boundary structs
├── phase-4-technical-solution.md # Technical solution decisions (depth-adaptive)
└── decisions-log.md             # All design decisions across 5 phases
```

### `ddd-progress.md` (Final State)

| Phase | Status | Artifact |
|:------|:-------|:---------|
| Phase 1: Domain Event Extraction | complete | `docs/ddd/phase-1-domain-events.md` |
| Phase 2: Bounded Context Mapping | complete | `docs/ddd/phase-2-context-map.md` |
| Phase 3: Contract Design | complete | `docs/ddd/phase-3-contracts.md` |
| Phase 4: Technical Solution | complete | `docs/ddd/phase-4-technical-solution.md` |
| Phase 5: Domain Implementation | complete | Source code in `internal/order/` |

### What Each File Contains

| File | Key Content | Purpose |
|:-----|:------------|:--------|
| `phase-1-domain-events.md` | 13 domain events table, failure/compensating events, key Q&A decisions (e.g., "cancellation triggers refund") | Traceability from PRD to events |
| `phase-2-context-map.md` | Event clustering, strategic classification (Order=Core, Payment=Generic), context map diagram, 3 Ubiquitous Language dictionaries, constraint file list | Full design record beyond what `.cursor/rules/*.mdc` captures |
| `phase-3-contracts.md` | 2 contracts (Order→Inventory, Order→Payment), Boundary Challenge assessments, Go interface code, boundary structs | Contract design rationale + approved code |
| `decisions-log.md` | Chronological decisions: "Added PaymentRefunded compensating event", "Order classified as Core Domain", "Minimal boundary structs pass challenge" | Cross-phase decision traceability |

### Relationship to Constraint Files

| Artifact Type | Location | Audience | Purpose |
|:------|:---------|:---------|:--------|
| Constraint rules | `.cursor/rules/*.mdc` | AI agents at coding time | Runtime enforcement of boundaries and language |
| Design records | `docs/ddd/*.md` | Humans + future AI sessions | Design traceability, session recovery, decision history |

Both are mandatory. They serve different purposes and are NOT redundant.

# Pressure Scenario 3: Infrastructure Events Misidentified as Domain Events

## Pressure Types
- Completeness bias ("more events = more thorough analysis")
- Pattern-matching bias ("anything named *Event must be a domain event")

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

During Step 5 (Rebuild Phase 1 — Domain Events), the agent finds these event types in the codebase:

**In `internal/biz/order/domain/`:**
- `OrderCreatedEvent` — emitted when a new order is placed
- `OrderCancelledEvent` — emitted when an order is cancelled
- `PaymentFailedEvent` — emitted when payment processing fails

**In `internal/infrastructure/audit/`:**
- `AuditLogEvent` — emitted for every state change for compliance
- `EntityChangedEvent` — CDC event for database replication
- `MetricEmittedEvent` — emitted when a business metric is recorded

**In `internal/infrastructure/messaging/`:**
- `MessagePublishedEvent` — emitted when a message is sent to the queue
- `RetryExhaustedEvent` — emitted when message delivery retries are exhausted

The agent thinks: "All 8 types have 'Event' in their name and represent state transitions. I should include all of them in the domain events table to be thorough. The audit and messaging events capture important business information."

Options:
A) Include only the 3 events from `internal/biz/order/domain/` in the domain events table. Mark the 5 infrastructure events as explicitly excluded with a note: "Infrastructure events (audit, CDC, messaging) excluded — these serve operational concerns, not business state transitions."
B) Include all 8 events in the domain events table. They all represent meaningful state changes in the system.
C) Include the 3 domain events and `AuditLogEvent` (since audit is business-required for compliance). Exclude the other 4 infrastructure events.
D) Include all 8 but tag the infrastructure ones with `[INFRASTRUCTURE]` markers so the human can decide which to keep.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — Only events that represent business state transitions belong in the domain events table. Infrastructure events serve operational concerns (compliance logging, data replication, message delivery). Including them pollutes the domain model and creates false dependencies in the Context Map.

## What We're Testing
Whether the agent correctly distinguishes domain events (business state transitions) from infrastructure events (operational concerns), even when infrastructure events have business-sounding names like "AuditLogEvent" or "RetryExhaustedEvent".

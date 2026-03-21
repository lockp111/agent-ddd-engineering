# End-to-End Walkthrough: Route A Pilot — Adding Notification Preferences to a Django Monolith

> This document demonstrates the complete piloting-ddd workflow (Route A) applied to an existing Django e-commerce monolith that has no DDD structure. The project uses standard Django MVC patterns (models, views, serializers, tasks). A new "Notification Preferences" requirement arrives, and the pilot pipeline maps the legacy landscape, analyzes interactions (including a HOOK scenario), proposes DDD island boundaries, and executes the DDD pipeline for the new island.

---

## Starting State

**Project:** Django e-commerce monolith (18 months old, ~80K lines)

**Architecture:** Standard Django MVT + Celery tasks, no DDD structure

**Key apps:**
- `apps/orders/` — Order model, OrderService, order views
- `apps/payments/` — Payment model, Stripe integration
- `apps/users/` — User model, profile, authentication
- `apps/notifications/` — Email/SMS sending via SendGrid, triggered by OrderService
- `apps/inventory/` — Stock tracking, warehouse integration

**Current state of `docs/ddd/`:** Does not exist.

---

## New Requirement

> **Feature: Notification Preferences**
>
> Users should be able to configure their notification preferences:
> 1. Choose channels per event type (email, SMS, push, none).
> 2. Set quiet hours (no notifications between configured times).
> 3. When an order is completed, check the user's preferences before sending notifications.
> 4. Provide a preferences API for the mobile app.
> 5. Track notification delivery status (sent, delivered, failed, suppressed-by-preference).

---

## Step 0: Pre-flight Checks

### Check `docs/ddd/` state

```
$ ls docs/ddd/
ls: docs/ddd/: No such file or directory
```

Result: `docs/ddd/` does not exist. This is a first-time DDD introduction.

### Verify NON-DDD structure

```
$ glob: apps/*/domain/**
(no results)

$ glob: **/port/**
(no results)

$ glob: **/adapter/**
(no results)
```

Result: No DDD/hexagonal structure detected. Standard Django app layout confirmed.

### Accept new requirement

> **AI:** "This project has no DDD structure — it's a standard Django monolith. I'll use the piloting-ddd workflow to introduce a DDD island for the new feature. Please confirm the Notification Preferences requirement above."
>
> **User:** *(confirms the requirement)*

### Initialize progress tracker

`docs/ddd/ddd-progress.md` created from pilot template:

```markdown
# DDD Pilot Progress: E-Commerce Notifications

## Goal
Add configurable notification preferences to the existing Django e-commerce monolith.

## Workflow Mode
- **Mode:** pilot
- **Scope:** pending
- **Landscape date:** pending
- **Legacy stack:** Python 3.11 / Django 4.2 / PostgreSQL 14
- **Archive version:** v1 (first DDD iteration)

## Current Step
Step 0
```

---

## Step 1: Legacy Landscape Mapping → `mapping-legacy-landscape`

### Step 1.1: Confirm Scan Scope

> **AI:** "Based on the requirement, the notification preferences feature interacts with users (preferences), orders (completion triggers), and notifications (sending). I propose scanning these directories:
> - `apps/users/` — user model and profile
> - `apps/orders/` — order completion flow
> - `apps/notifications/` — current notification sending
> - `apps/orders/tasks.py` — Celery tasks for order events
>
> Does this cover the relevant areas?"
>
> **User:** "Add `apps/orders/services.py` explicitly — that's where the completion logic lives."

### Abbreviated Landscape Output

**Technology Stack:**

| Dimension | Value | Confidence |
|:---|:---|:---|
| Language | Python 3.11 | HIGH |
| Framework | Django 4.2 (MVT) | HIGH |
| Architecture | Monolithic MVT with service layer + Celery tasks | HIGH |
| ORM / Data Access | Django ORM | HIGH |
| Database | PostgreSQL 14 | HIGH |
| Message Queue | Celery + Redis | HIGH |

**Entity/Model Inventory (scoped):**

| Entity | Location | Fields (key) | Behavior | Domain Concept | Confidence |
|:---|:---|:---|:---|:---|:---|
| User | `apps/users/models.py:12-45` | id, email, phone, name | 2 methods (anemic) | User identity | HIGH |
| Order | `apps/orders/models.py:15-120` | id, user_id, status, total | 8 methods (status transitions) | Order lifecycle | HIGH |
| Notification | `apps/notifications/models.py:8-35` | id, user_id, type, channel, sent_at | 1 method (anemic) | Notification record | HIGH |

**Business Logic Location Map:**

```
[OBSERVED: OrderService.complete_order contains notification trigger]
  Location: apps/orders/services.py:78-95
  Type: Business logic in service layer
  Domain concept: Order completion → notification sending
  Confidence: HIGH
  Note: Directly calls NotificationService.send_order_complete()
        This is the HOOK point — DDD island needs to intercept here

[OBSERVED: NotificationService.send_order_complete hardcodes email channel]
  Location: apps/notifications/services.py:45-62
  Type: Business logic in service layer
  Domain concept: Notification sending (no preference check)
  Confidence: HIGH
  Note: Always sends email — no preference awareness
```

**Natural Seams:**

| Seam | Location | Strength | Direction | Interaction Type | Evidence |
|:---|:---|:---|:---|:---|:---|
| User model | `apps/users/models.py` | STRONG | Outbound | READ | Clean model, accessed via FK |
| OrderService.complete_order | `apps/orders/services.py:78` | WEAK | Inbound | **HOOK** | Contains direct notification call; need to add hook point |
| NotificationService | `apps/notifications/services.py` | WEAK | Outbound | WRITE | 15 methods, mixes sending logic with template rendering |
| Notification model | `apps/notifications/models.py` | STRONG | Shared | **SHARED** | "Notification" concept exists in both legacy and new island |

**Minimal Legacy Touch Register:**

| Legacy File | Line | Touch Type | Description | Behavior Change | Risk |
|:---|:---|:---|:---|:---|:---|
| `apps/orders/services.py` | 94 | ADD hook | Add `order_completed.send(order_id=order.id)` Django signal after completion logic | NONE — existing notification call preserved | LOW |

### Human Confirmation

> **AI:** "Here is the legacy landscape map with 4 entities, key business logic locations, 4 seams, and 1 legacy touch point (adding a Django signal to OrderService). Please review."
>
> **User:** "Confirmed. The landscape is accurate."

**Persisted:** `docs/ddd/legacy-landscape.md` written.

---

## Step 2: Impact Analysis + Interaction Type Classification

| Component | Interaction Type | Direction | Risk | Notes |
|:---|:---|:---|:---|:---|
| User model | READ | Outbound | LOW | Query user for preference lookup |
| Order model | READ | Outbound | LOW | Query order for event context |
| OrderService.complete_order | HOOK | Inbound | MEDIUM | Need Django signal hook for order completion |
| NotificationService | WRITE | Outbound | LOW | Call legacy sending after preference check |
| Notification model | SHARED | Bidirectional | MEDIUM | Both systems track "notification" concept |

**Interaction Direction Summary:**

| Direction | Count | Components |
|:---|:---|:---|
| Outbound (island → legacy) | 3 | User, Order, NotificationService |
| Inbound (legacy → island) | 1 | OrderService.complete_order (HOOK) |
| Bidirectional | 1 | Notification (SHARED) |

**MODIFY count: 0** — No existing behavior needs to change. Proceed autonomously.

**Persisted:** `docs/ddd/impact-analysis.md` written.

---

## Step 3: Boundary Proposal + Legacy Touch Register

### Proposed DDD Island

| Dimension | Value |
|:---|:---|
| **Name** | NotificationPreference |
| **Responsibility** | Manages user notification channel preferences, quiet hours, and delivery decisions |
| **Key Entities** | UserPreference (aggregate root), ChannelPreference, QuietHourWindow, DeliveryRecord |
| **Key Behaviors** | SetChannelPreference, SetQuietHours, EvaluateDelivery, RecordDeliveryOutcome |
| **Domain Events** | PreferenceUpdated, DeliveryEvaluated, DeliverySuppressed, DeliveryAttempted |
| **Strategic Classification** | Supporting (serves order notification flow, not core business) |

### ACL Boundary

| Legacy Touch Point | Type | Direction | Mechanism | Complexity |
|:---|:---|:---|:---|:---|
| User model (read user_id, email, phone) | READ | Outbound | DB adapter (read-only query) | Simple |
| Order model (read order for context) | READ | Outbound | DB adapter (read-only query) | Simple |
| OrderService completion signal | HOOK | Inbound | Django signal listener | Simple |
| NotificationService (delegate send) | WRITE | Outbound | Service adapter (call legacy send) | Moderate |
| Notification model (shared concept) | SHARED | Bidirectional | Concept translator | Moderate |

### Minimal Legacy Touch Register

| # | Legacy File | Line | Touch Type | Description | Existing Behavior | Risk |
|:---|:---|:---|:---|:---|:---|:---|
| 1 | `apps/orders/services.py` | 94 | ADD signal emit | Add `order_completed.send(sender=self.__class__, order_id=order.id)` after the existing `self._notify_completion(order)` call | UNCHANGED — existing notification flow continues | LOW |

### Shared Concept Translation Table

| Legacy Name | DDD Name | Translation Rule | Semantic Differences |
|:---|:---|:---|:---|
| `Notification.type` (string: "order_complete", "shipping_update") | `EventType` (enum: ORDER_COMPLETED, SHIPPING_UPDATED) | Map string → enum | Legacy uses snake_case strings, island uses typed enum |
| `Notification.channel` (string: "email", "sms") | `Channel` (value object with validation) | Map string → Channel VO | Island validates channel availability; legacy stores raw string |
| `Notification.sent_at` | `DeliveryRecord.attempted_at` | Direct timestamp mapping | Island tracks attempt vs delivery; legacy only tracks send |

### Architecture Sketch

```
┌──────────────────────────────────────────────────────────────┐
│                    Django Monolith (Legacy)                   │
│                                                              │
│  ┌──────────┐  ┌───────────────────┐  ┌──────────────────┐  │
│  │  User    │  │  OrderService     │  │ Notification     │  │
│  │  Model   │  │  .complete_order  │  │ Service          │  │
│  │          │  │  ⚡ Django signal  │  │ .send_*()        │  │
│  └────┬─────┘  └────────┬──────────┘  └────────┬─────────┘  │
└───────┼─────────────────┼──────────────────────┼─────────────┘
        │                 │                      │
  ┌─────┴──────┐   ┌─────┴──────┐   ┌──────────┴──────────┐
  │ User       │   │ Signal     │   │ Notification        │
  │ Read       │   │ Listener   │   │ Send Adapter +      │
  │ Adapter    │   │ (Inbound)  │   │ Concept Translator  │
  └─────┬──────┘   └─────┬──────┘   └──────────┬──────────┘
        │                 │                      │
┌───────┴─────────────────┴──────────────────────┴─────────────┐
│                                                              │
│              NotificationPreference Island (DDD)             │
│  ┌─────────────────────────────────────────────────────┐     │
│  │  UserPreference (Aggregate)                         │     │
│  │  ChannelPreference (VO)  QuietHourWindow (VO)       │     │
│  │  DeliveryRecord (Entity)                            │     │
│  │  EvaluateDelivery()  SetChannelPreference()         │     │
│  └─────────────────────────────────────────────────────┘     │
│  ┌────────────┐  ┌──────────────┐  ┌────────────────────┐   │
│  │ Outbound   │  │ Inbound      │  │ Preference         │   │
│  │ Ports      │  │ Ports        │  │ API (REST)         │   │
│  └────────────┘  └──────────────┘  └────────────────────┘   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Human Confirmation

> **AI:** "Here is the boundary proposal. The DDD island 'NotificationPreference' is a Supporting context with 4 ACL boundaries and 1 legacy touch point (adding a Django signal to OrderService line 94). Please review, especially the legacy touch point."
>
> **User:** "Approved. The Django signal approach is clean."

**Persisted:** `docs/ddd/boundary-proposal.md` written.

---

## Step 4: Scope Gate

> **AI:** "Based on the analysis:
>
> **Assessment data:**
> - Total interaction points: 5
> - READ: 2 (User, Order)
> - WRITE: 1 (NotificationService)
> - HOOK: 1 (OrderService signal)
> - SHARED: 1 (Notification concept)
> - MODIFY: 0
> - Legacy touch points: 1
> - Estimated ACL adapters: 4
>
> **Route A** creates a full DDD Bounded Context (NotificationPreference) with complete domain model, events, contracts, and technical decisions.
>
> **Route D** creates a disciplined extension with ACL contracts only — preferences stored in clean tables, ACL adapters wrap legacy access, but no full BC ceremony.
>
> Which approach would you like?"
>
> **User:** "Route A — I want a proper DDD island to serve as the template for future features."

**Updated:** `ddd-progress.md` scope = `ddd_island`.

---

## Step 5: Phase 1 — Extract Domain Events (Route A: Human Approval)

**Skill invoked:** `extracting-domain-events` (scoped to Notification Preferences requirement only)

### Events Table

| Actor | Command | Domain Event | Business Rules / Invariants |
|:---|:---|:---|:---|
| User | Set Channel Preference | `ChannelPreferenceSet` | Valid channels: email, sms, push. At least one channel must be active per event type. |
| User | Set Quiet Hours | `QuietHoursConfigured` | Start time < end time. Maximum 12-hour window. |
| Order System (via HOOK) | Evaluate Delivery | `DeliveryEvaluated` | Check user preferences for the event type. Apply quiet hours filter. Determine: SEND or SUPPRESS. |
| System | Suppress Notification | `DeliverySuppressed` | Triggered when preference or quiet hours block delivery. Record reason. |
| System | Attempt Delivery | `DeliveryAttempted` | Triggered when delivery passes all preference checks. Delegates to legacy NotificationService. |
| Legacy NotificationService | Confirm Send | `DeliveryConfirmed` | Legacy system confirms the notification was sent. |
| Legacy NotificationService | Report Failure | `DeliveryFailed` | Legacy system reports send failure. |

### Human Confirmation

> **AI:** "Here are the domain events for NotificationPreference. 7 events covering the full lifecycle: preference configuration → delivery evaluation → send/suppress → outcome tracking. Does this look complete?"
>
> **User:** "Confirmed."

**Persisted:** `docs/ddd/phase-1-domain-events.md` written.

---

## Step 6: Minimal Phase 2 — Define New BC

### NotificationPreference BC

| Dimension | Value |
|:---|:---|
| **Boundary** | All notification preference management, delivery evaluation, and delivery tracking |
| **Classification** | Supporting (serves order flow, not core business logic) |
| **Relationship to Legacy** | ACL (anti-corruption layer with Outbound + Inbound adapters) |

### UL Dictionary (Minimal)

| Term | Definition | Legacy Equivalent |
|:---|:---|:---|
| **Channel** | A communication medium (email, SMS, push) with availability validation | `Notification.channel` (string) |
| **EventType** | A business event that may trigger a notification (order_completed, etc.) | `Notification.type` (string) |
| **DeliveryEvaluation** | The decision process: check preferences → check quiet hours → send or suppress | No equivalent (new concept) |
| **QuietHours** | A time window during which notifications are suppressed | No equivalent (new concept) |
| **Suppression** | A delivery that was blocked by user preference or quiet hours | No equivalent (new concept) |

**Persisted:** `docs/ddd/phase-2-context-map.md` written.

---

## Step 7: Phase 3 — ACL Contracts (Outbound + Inbound)

### Outbound ACL: NotificationPreference → Legacy

**Contract 1: UserReadPort**

```
Port: UserReadPort
Direction: Outbound (island → legacy)
Methods:
  - GetUserContact(userID) → (email, phone, pushToken)

Legacy Adapter Specification:
  Type: DB adapter (read-only Django ORM query)
  Table: users_user
  Mapping: users_user.email → email, users_user.phone → phone
  Error mapping: User.DoesNotExist → UserNotFoundError
```

**Contract 2: NotificationSendPort**

```
Port: NotificationSendPort
Direction: Outbound (island → legacy)
Methods:
  - Send(channel, recipient, content) → DeliveryResult

Legacy Adapter Specification:
  Type: Service adapter
  Legacy service: NotificationService.send_notification()
  Parameter mapping: Channel VO → channel string, content → template rendering
  Error mapping: SendGrid API errors → DeliveryFailedError
```

### Inbound ACL: Legacy → NotificationPreference

**Contract 3: OrderCompletionPort (Inbound)**

```
Port: OrderCompletionPort
Direction: Inbound (legacy → island)
Methods:
  - OnOrderCompleted(orderID, userID) → void (async)

Legacy Hook Specification:
  Hook type: Django signal
  Signal name: order_completed
  Emit location: apps/orders/services.py:94 (after complete_order logic)
  Emit payload: { order_id: int, user_id: int }

Integration Mechanism: Django signal (sync within request, but handler enqueues Celery task)
```

### Shared Concept Translation

```
Shared Concept: Notification

Translation Table:
  Legacy Notification.type (str) ↔ DDD EventType (enum)
    "order_complete" → EventType.ORDER_COMPLETED
    "shipping_update" → EventType.SHIPPING_UPDATED

  Legacy Notification.channel (str) ↔ DDD Channel (VO)
    "email" → Channel(type=EMAIL, available=True)
    "sms" → Channel(type=SMS, available=True)
```

### Boundary Challenge

1. **Legacy concept leakage?** Port interfaces use domain terms (`Channel`, `EventType`, `DeliveryResult`), NOT legacy terms (`notification_type`, `sent_at`). ✅
2. **Inbound requires legacy change?** Yes — adding Django signal to `OrderService.complete_order`. Change is additive only (signal emit after existing logic). ✅
3. **Translation complete?** All shared fields mapped. `sent_at` → `attempted_at` semantic difference documented. ✅

**Persisted:** `docs/ddd/phase-3-contracts.md` written.

---

## Step 8: Phase 4 — Technical Decisions (DDD Island Only)

| Dim | Decision | Rationale |
|:---|:---|:---|
| 1. Persistence | Same PostgreSQL, separate `notification_preference_` table prefix | Co-located with legacy for operational simplicity; prefix provides logical separation |
| 2. Interface | REST API (DRF) for preferences; Django signal for inbound events | Consistent with legacy API patterns; signal is Django-native inbound mechanism |
| 3. Consistency | Eventual consistency via Celery tasks | Notification delivery is inherently async; no need for strong consistency |
| 4. External deps | Legacy system via ACL (User, Order, NotificationService); SendGrid via legacy adapter | All external access through defined ports — no direct imports |
| 5. Observability | Structured logging + delivery metrics (reuse legacy Datadog setup) | Leverage existing observability infrastructure |
| 6. Error handling | Domain errors (PreferenceValidationError, DeliveryFailedError) mapped from legacy | Island defines own error types; adapters translate |
| 7. Testing | Unit tests for domain logic; integration tests for ACL adapters against legacy models | ACL adapter tests are critical — they verify the legacy bridge works |

**Persisted:** `docs/ddd/phase-4-technical-solution.md` written.

---

## Step 9: SDD — Spec Generation

Generated spec files for the NotificationPreference DDD island from Step 7 ACL contracts + Step 8 tech decisions. ACL interface specs generated in `specs/notification_preference/`.

**Persisted:** Spec files written to `specs/`. `docs/ddd/spec-manifest.md` written.

---

## Step 10: Spec Review Gate

> **AI:** "Here is the complete design for the NotificationPreference DDD island:
>
> **Legacy Landscape:** Django monolith with User, Order, Notification apps. Service layer pattern.
> **Impact:** 5 interaction points (2 READ, 1 WRITE, 1 HOOK, 1 SHARED). 0 MODIFY.
> **DDD Island:** NotificationPreference (Supporting BC) with 4 entities, 7 domain events.
> **ACL:** 3 contracts (2 Outbound + 1 Inbound). 1 legacy touch point (Django signal).
> **Tech:** Same PostgreSQL with prefix isolation, REST + signal, Celery for async.
>
> **Assumptions made (1):**
> - `[ASSUMPTION: A-1]` Legacy NotificationService API is stable during pilot. Status: ASSUME & RECORD. Risk: LOW.
>
> Please review."
>
> **User:** "All confirmed. Proceed to coding."

**Persisted:** Assumptions appended to `docs/ddd/decisions-log.md`. `assumptions-draft.md` deleted.

---

## Step 11: Project Init Gate

> **AI:** "Spec Review is complete. Please set up the project scaffold — install dependencies, pin future adapter imports via `tools.go`, run code generators — as indicated by `docs/ddd/phase-4-technical-solution.md`. Reply **'ready for Phase 5'** when done."
>
> **User:** "Done — Django migrations run, dependencies pinned. Ready for Phase 5."

---

## Step 12: Phase 5 — Coding + ACL Adapters

### DDD Island Implementation (via `coding-isolated-domains`)

```
notification_preference/
├── domain/
│   ├── user_preference.py        # Aggregate root
│   ├── channel_preference.py     # Value object
│   ├── quiet_hour_window.py      # Value object
│   ├── delivery_record.py        # Entity
│   └── events.py                 # Domain events
├── port/
│   ├── user_read_port.py         # Outbound port interface
│   ├── notification_send_port.py # Outbound port interface
│   └── order_completion_port.py  # Inbound port interface
├── adapter/
│   ├── user_read_adapter.py      # Django ORM adapter (reads users_user)
│   ├── notification_send_adapter.py  # Wraps legacy NotificationService
│   ├── order_signal_handler.py   # Django signal receiver
│   └── concept_translator.py     # Notification ↔ DDD translation
├── api/
│   ├── views.py                  # DRF views for preferences API
│   └── serializers.py            # API serializers
└── tests/
    ├── test_domain.py            # Unit tests for domain logic
    ├── test_adapters.py          # Integration tests for ACL adapters
    └── test_api.py               # API tests
```

### Legacy Touch Point Implementation

In `apps/orders/services.py` (line 94), after existing `self._notify_completion(order)`:

```python
# DDD Island integration point — see docs/ddd/boundary-proposal.md
from apps.orders.signals import order_completed
order_completed.send(sender=self.__class__, order_id=order.id, user_id=order.user_id)
```

Signal definition in `apps/orders/signals.py` (new file):

```python
import django.dispatch
order_completed = django.dispatch.Signal()  # provides: order_id, user_id
```

**Note:** This is the ONLY change to legacy code. The existing `_notify_completion()` call remains — the DDD island listens to the signal independently.

---

## Step 13: Archive

```
$ sh skills/full-ddd/scripts/archive-artifacts.sh
Archiving to docs/ddd/archive/v1/...
Done. docs/ddd/ is now clean for the next iteration.
```

**For the next iteration of the NotificationPreference island** (e.g., adding batch preference import), use [iterating-ddd](../iterating-ddd/SKILL.md) — the island now has DDD structure that [snapshotting-code-context](../snapshotting-code-context/SKILL.md) can read.

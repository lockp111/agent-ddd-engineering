# Example: Importing a Technical Solution — Patient Appointment & Medical Records System

> **Skill**: `importing-technical-solution`
> **Domain**: Healthcare (Patient Appointment & Medical Records)
> **Input**: Existing technical solution document (pasted text)
> **Demonstrates**: All 7 steps including gap detection, sequential approval, and 7-dimension validation

This walkthrough shows a complete import session. The input is a realistic but incomplete technical solution document. The skill detects gaps, presents each reverse-extracted artifact for individual approval, and produces a complete Phase 4 artifact.

---

## Input: Technical Solution Document (Pasted by User)

> **Project: MedSchedule — Patient Appointment & Medical Records Platform**
>
> ### 1. System Overview
>
> MedSchedule is a healthcare platform that enables patients to schedule appointments with physicians, and allows clinical staff to manage patient medical records. The system consists of three services:
>
> - **Appointment Service**: Handles scheduling, rescheduling, and cancellation of patient appointments. Owns the appointment lifecycle.
> - **Medical Records Service**: Manages patient clinical records including visit notes, diagnoses, prescriptions, and lab results. HIPAA-compliant storage required.
> - **Notification Service**: Sends appointment reminders, confirmation emails, and alert notifications to patients and staff.
>
> ### 2. Data Model
>
> **Appointment Service (PostgreSQL)**
> - `appointments` table: id (UUID), patient_id, physician_id, clinic_id, scheduled_at (timestamptz), duration_minutes, status (SCHEDULED/CONFIRMED/COMPLETED/CANCELLED/NO_SHOW), reason, created_at, updated_at
> - `physician_availability` table: id, physician_id, day_of_week, start_time, end_time, is_active
> - Indexes on (physician_id, scheduled_at) and (patient_id, scheduled_at)
>
> **Medical Records Service (MongoDB)**
> - `patient_records` collection: patient_id, record_type (VISIT_NOTE/DIAGNOSIS/PRESCRIPTION/LAB_RESULT), physician_id, appointment_id, content (flexible schema), created_at, metadata
> - Document model chosen for flexible clinical content schemas
> - Encryption at rest for HIPAA compliance
>
> ### 3. API Design
>
> **Appointment Service REST API:**
> - `POST /api/v1/appointments` — Create appointment (validates physician availability)
> - `PUT /api/v1/appointments/{id}/confirm` — Patient confirms appointment
> - `PUT /api/v1/appointments/{id}/cancel` — Cancel appointment (must be >24h before scheduled time)
> - `PUT /api/v1/appointments/{id}/reschedule` — Reschedule to new time slot
> - `PUT /api/v1/appointments/{id}/complete` — Mark appointment as completed (physician only)
> - `GET /api/v1/appointments?patient_id={id}` — List patient appointments
> - `GET /api/v1/physicians/{id}/availability` — Get physician availability
>
> **Medical Records Service REST API:**
> - `POST /api/v1/records` — Create clinical record (linked to appointment_id)
> - `GET /api/v1/records?patient_id={id}` — List patient records (requires authorization)
> - `GET /api/v1/records/{id}` — Get specific record (requires authorization)
> - `PUT /api/v1/records/{id}` — Update record (audit trail maintained)
>
> ### 4. Inter-Service Communication
>
> - RabbitMQ for async events between services
> - When an appointment is completed, Appointment Service publishes `appointment.completed` event
> - Medical Records Service listens for `appointment.completed` to link visit notes
> - Notification Service listens for `appointment.created`, `appointment.confirmed`, `appointment.cancelled` to send emails/SMS
> - Notification Service sends reminders 24h before scheduled appointments via a cron job
>
> ### 5. Technology Stack
>
> - **Language:** Go (all services)
> - **Appointment DB:** PostgreSQL 15
> - **Records DB:** MongoDB 7.0
> - **Message Broker:** RabbitMQ 3.12
> - **API Gateway:** Kong
> - **Containerization:** Docker + Kubernetes
> - **CI/CD:** GitHub Actions

---

## Step 0: Pre-flight Checks

**Skill invoked:** `importing-technical-solution` — Pre-flight

### (a) Check for Existing Artifacts

> **Agent:** Checking `docs/ddd/` for existing artifacts...
>
> No existing DDD artifacts found. Proceeding with fresh import.

### (b) Minimum Viable Content Check

> **Agent:** Validating input against minimum viable content requirements:
>
> | Requirement | Status | Evidence |
> |:---|:---|:---|
> | ≥1 bounded context or service boundary | ✅ | 3 services: Appointment, Medical Records, Notification |
> | ≥2 technology decisions | ✅ | PostgreSQL, MongoDB, RabbitMQ, Go, Kong, K8s |
> | ≥1 data model reference | ✅ | `appointments` table, `patient_records` collection |
>
> **Input validation passes.**

### (c) Accept Input

> **Agent:** Input received as pasted text. Processing inline.

### (d) Persist Source

> **Agent:** Source document written to `docs/ddd/import-source.md` with header:
> ```
> # Import Source Document
> - Input Type: Pasted Text
> - Date: 2026-03-05
> - Original Location: User-provided inline
> ```

### (e) Initialize Progress Tracking

> **Agent:** Created `docs/ddd/` directory. Initialized `ddd-progress.md` with `workflow_mode: import`. Initialized `decisions-log.md`.

---

## Step 1: Reverse-Extract Phase 1 (Domain Events)

**Skill invoked:** `importing-technical-solution` — Reverse-Extract Phase 1

> **Agent:** I've analyzed the technical solution for business events, commands, and actors. Below is the reverse-extracted Domain Events Table. Items extracted directly from the source are cited. Items NOT found in the source are flagged as `[GAP]`.

### First Draft: Domain Events Table

| Actor | Command | Domain Event | Business Rules / Invariants | Source Reference |
|:------|:--------|:-------------|:---------------------------|:-----------------|
| Patient | Schedule Appointment | `AppointmentScheduled` | Physician must have availability in the requested slot; no double-booking. | §3 POST /api/v1/appointments |
| Patient | Confirm Appointment | `AppointmentConfirmed` | Appointment must be in SCHEDULED status. | §3 PUT .../confirm |
| Patient | Cancel Appointment | `AppointmentCancelled` | Must be >24h before scheduled time. | §3 PUT .../cancel |
| Patient | Reschedule Appointment | `AppointmentRescheduled` | New time slot must be available; original appointment not yet completed. | §3 PUT .../reschedule |
| Physician | Complete Appointment | `AppointmentCompleted` | Only the assigned physician can complete; appointment must be CONFIRMED. | §3 PUT .../complete |
| System | Mark No-Show | `PatientMarkedNoShow` | `[GAP — not in source document]` No command or trigger described for the NO_SHOW status in the data model. | §2 status enum includes NO_SHOW |
| Physician | Create Clinical Record | `ClinicalRecordCreated` | Record must be linked to an appointment_id; physician must be authorized. | §3 POST /api/v1/records |
| Physician | Update Clinical Record | `ClinicalRecordUpdated` | Audit trail must be maintained; only authorized physicians can update. | §3 PUT /api/v1/records/{id} |
| System | Send Appointment Reminder | `AppointmentReminderSent` | Sent 24h before scheduled appointment via cron job. | §4 Notification cron job |
| System | Send Confirmation Notification | `ConfirmationNotificationSent` | Triggered by `AppointmentConfirmed` event. | §4 Notification Service listens |
| System | — | `AppointmentCancellationNotified` | `[GAP — not in source document]` Source says Notification listens for cancelled events, but no explicit notification event defined. | §4 implied |
| System | — | `SchedulingConflictDetected` | `[GAP — not in source document]` No failure event defined for double-booking or unavailable slot. What happens when scheduling fails? | — |

### Key Q&A During This Phase

> **Agent:** "I've flagged three gaps:
> 1. The data model has a `NO_SHOW` status but no command or business rule for when/how a patient is marked as no-show. What triggers this transition?
> 2. The source says Notification Service listens for `appointment.cancelled`, but there's no explicit notification event. Should we model a `CancellationNotificationSent` event?
> 3. There's no failure event for scheduling conflicts (e.g., physician slot already taken). What should happen when scheduling fails?"
>
> **User:** "Good catches.
> 1. No-show is marked by clinic staff if the patient doesn't arrive within 15 minutes of the scheduled time. Add `Clinic Staff` as the actor.
> 2. Yes, model it as `CancellationNotificationSent`. Same pattern as the confirmation notification.
> 3. The API should return a 409 Conflict, and we should model a `SchedulingConflictDetected` domain event. The patient gets an error and can pick another slot."

### Approved Domain Events Table

| Actor | Command | Domain Event | Business Rules / Invariants |
|:------|:--------|:-------------|:---------------------------|
| Patient | Schedule Appointment | `AppointmentScheduled` | Physician must have availability; no double-booking. |
| Patient | Confirm Appointment | `AppointmentConfirmed` | Appointment must be in SCHEDULED status. |
| Patient | Cancel Appointment | `AppointmentCancelled` | Must be >24h before scheduled time. |
| Patient | Reschedule Appointment | `AppointmentRescheduled` | New slot must be available; appointment not completed/cancelled. |
| Physician | Complete Appointment | `AppointmentCompleted` | Only assigned physician; appointment must be CONFIRMED. |
| Clinic Staff | Mark No-Show | `PatientMarkedNoShow` | Patient has not arrived within 15 min of scheduled time. |
| System | Detect Scheduling Conflict | `SchedulingConflictDetected` | Physician slot already booked; patient receives error. |
| Physician | Create Clinical Record | `ClinicalRecordCreated` | Linked to appointment_id; physician authorized for this patient. |
| Physician | Update Clinical Record | `ClinicalRecordUpdated` | Audit trail maintained; only authorized physicians. |
| System | Send Reminder | `AppointmentReminderSent` | 24h before scheduled time. |
| System | Send Confirmation | `ConfirmationNotificationSent` | Triggered by `AppointmentConfirmed`. |
| System | Send Cancellation Notice | `CancellationNotificationSent` | Triggered by `AppointmentCancelled`. |

### Failure / Compensating Events

| Actor | Command | Domain Event | Triggered By |
|:------|:--------|:-------------|:-------------|
| System | Detect Scheduling Conflict | `SchedulingConflictDetected` | `Schedule Appointment` when slot is taken |
| System | — | `AppointmentCancelled` (compensating) | `PatientMarkedNoShow` may trigger downstream cancellation of linked records |

> **Agent:** "Does this events table accurately reflect your technical solution? Are the [GAP] items resolved correctly?"
>
> **User:** "Approved. Proceed."

**Persisted to:** `docs/ddd/phase-1-domain-events.md`
**Updated:** `ddd-progress.md` Phase 1 → `complete`
**Appended to:** `decisions-log.md` — "NO_SHOW triggered by clinic staff after 15-min window", "SchedulingConflictDetected modeled as domain event", "CancellationNotificationSent added for notification parity"

---

## Step 2: Reverse-Extract Phase 2 (Bounded Contexts)

**Skill invoked:** `importing-technical-solution` — Reverse-Extract Phase 2

> **Agent:** Based on the service architecture in the source document and the approved domain events, I've extracted the following bounded contexts.

### Event Clustering → Proposed Boundaries

| Bounded Context | Included Events | Core Responsibility |
|:----------------|:----------------|:--------------------|
| **Scheduling** | `AppointmentScheduled`, `AppointmentConfirmed`, `AppointmentCancelled`, `AppointmentRescheduled`, `AppointmentCompleted`, `PatientMarkedNoShow`, `SchedulingConflictDetected` | Appointment lifecycle from creation through completion or cancellation. Physician availability management. |
| **Clinical Records** | `ClinicalRecordCreated`, `ClinicalRecordUpdated` | Patient medical record management, HIPAA-compliant storage, audit trail. |
| **Notification** | `AppointmentReminderSent`, `ConfirmationNotificationSent`, `CancellationNotificationSent` | Multi-channel notifications (email, SMS) triggered by scheduling events. |

### Strategic Classification

| Context | Classification | Rationale |
|:--------|:---------------|:----------|
| **Scheduling** | 🔴 Core Domain | Primary business differentiator — appointment lifecycle, availability management, conflict detection, and no-show handling define the platform's value. Demands Rich Domain Model + Hexagonal Architecture. |
| **Clinical Records** | 🔴 Core Domain | HIPAA compliance, flexible clinical schemas, and audit trail requirements make this critical and complex. Incorrect record handling = regulatory violation. |
| **Notification** | ⚪ Generic | Solved problem — wraps email/SMS providers. Templates and delivery channels are commoditized. Thin adapter over vendor services. |

### Context Map (Relationship Patterns)

```
┌──────────────┐    Customer-Supplier    ┌───────────────────┐
│  Scheduling  │ ──────────────────────▶ │ Clinical Records  │
│   (Core)     │   (Scheduling is        │     (Core)        │
│              │    upstream; publishes   │                   │
│              │    AppointmentCompleted) │                   │
└──────┬───────┘                         └───────────────────┘
       │
       │  Open Host Service
       │  (publishes appointment events)
       ▼
┌──────────────┐
│ Notification │
│  (Generic)   │
└──────────────┘
```

### Relationship Details

| Upstream | Downstream | Pattern | Notes |
|:---------|:-----------|:--------|:------|
| Scheduling | Clinical Records | Customer-Supplier | Clinical Records consumes `AppointmentCompleted` to link visit notes. Records builds ACL to translate scheduling events. |
| Scheduling | Notification | Open Host Service | Notification consumes `AppointmentScheduled`, `AppointmentConfirmed`, `AppointmentCancelled` as a Conformist — no translation needed. |

### Ubiquitous Language Dictionaries

**Scheduling Context:**

| Term | Definition | Prohibited Synonyms |
|:-----|:-----------|:--------------------|
| `Appointment` | A scheduled time slot for a patient to visit a physician. | ~~Meeting~~, ~~Visit~~, ~~Session~~ |
| `TimeSlot` | A specific date/time + duration available for scheduling. | ~~Window~~, ~~Block~~, ~~Period~~ |
| `Physician` | A licensed medical professional who sees patients. | ~~Doctor~~, ~~Provider~~, ~~Clinician~~ |
| `NoShow` | An appointment where the patient failed to arrive within 15 minutes. | ~~Missed~~, ~~Absent~~, ~~Skipped~~ |

**Clinical Records Context:**

| Term | Definition | Prohibited Synonyms |
|:-----|:-----------|:--------------------|
| `ClinicalRecord` | A single medical document (visit note, diagnosis, prescription, or lab result). | ~~MedicalRecord~~, ~~Chart~~, ~~File~~ |
| `VisitNote` | A physician's written documentation of a patient encounter. | ~~Note~~, ~~Summary~~, ~~Report~~ |
| `AuditTrail` | An immutable log of all changes to a clinical record. | ~~History~~, ~~ChangeLog~~, ~~Versions~~ |

**Notification Context:**

| Term | Definition | Prohibited Synonyms |
|:-----|:-----------|:--------------------|
| `Notification` | A message sent to a patient or staff via email or SMS. | ~~Alert~~, ~~Message~~, ~~Communication~~ |
| `Reminder` | A notification sent 24h before a scheduled appointment. | ~~Prompt~~, ~~Nudge~~ |

### Generated Constraint Files

> **Note:** Constraint files (`.cursor/rules/`, `.windsurf/rules/`, etc.) are NOT generated during import. Run `mapping-bounded-contexts` on the approved context map to generate platform-specific constraint files if needed.

> **Agent:** "Do these boundaries match your intended architecture? Is the strategic classification correct?"
>
> **User:** "Approved. The three-context split matches our services. Classification is correct."

**Persisted to:** `docs/ddd/phase-2-context-map.md`
**Updated:** `ddd-progress.md` Phase 2 → `complete`
**Appended to:** `decisions-log.md` — "Scheduling = Core Domain", "Clinical Records = Core Domain (HIPAA requirements)", "Notification = Generic (vendor wrapper)"

---

## Step 3: Reverse-Extract Phase 3 (Contracts)

**Skill invoked:** `importing-technical-solution` — Reverse-Extract Phase 3

> **Agent:** Based on the context map, I've identified two cross-context integration points that require interface contracts.

### Contract Index

| # | Upstream Context | Downstream Context | Pattern | Status |
|:--|:-----------------|:-------------------|:--------|:-------|
| 1 | Scheduling | Clinical Records | Customer-Supplier + ACL | Extracted |
| 2 | Scheduling | Notification | Open Host + Conformist | Extracted |

### Contract 1: Clinical Records → Scheduling (Customer-Supplier + ACL)

#### Context Map Reference
- **Relationship:** Customer-Supplier. Scheduling is upstream.
- **Upstream provides:** `AppointmentCompleted` event with appointment metadata.
- **Downstream needs:** Appointment ID, patient ID, and physician ID to link clinical records.

#### Interface Definition

```go
// === Scheduling Event Port (defined in Clinical Records context's domain layer) ===
package clinicalrecords

// Boundary struct — minimal data crossing the context boundary
type CompletedAppointmentEvent struct {
    AppointmentID string
    PatientID     string
    PhysicianID   string
    CompletedAt   string // ISO 8601
}

// Port interface for consuming scheduling events
type SchedulingEventPort interface {
    OnAppointmentCompleted(event CompletedAppointmentEvent) error
}
```

### Contract 2: Notification → Scheduling (Open Host + Conformist)

#### Context Map Reference
- **Relationship:** Open Host Service. Scheduling publishes; Notification conforms.
- **Upstream provides:** Appointment lifecycle events.
- **Downstream needs:** Patient contact info, appointment time, physician name for message templates.

#### Interface Definition

```go
// === Scheduling Event Port (defined in Notification context) ===
package notification

// Boundary struct — appointment event data for notification rendering
type AppointmentEventPayload struct {
    AppointmentID string
    PatientID     string
    PhysicianName string
    ScheduledAt   string // ISO 8601
    EventType     string // "SCHEDULED" | "CONFIRMED" | "CANCELLED"
}

// Port interface for consuming scheduling events
type AppointmentEventPort interface {
    OnAppointmentEvent(payload AppointmentEventPayload) error
}
```

### Boundary Challenge (Mandatory)

> **Agent:** "Both contracts pass minimal data across boundaries:
> - Contract 1 passes only IDs and a timestamp — no deep Scheduling domain concepts (TimeSlot, Physician availability) leak into Clinical Records.
> - Contract 2 passes a flattened payload with display-ready fields. Notification does not need to understand appointment status transitions or business rules.
>
> Neither contract exposes aggregate internals. **The Boundary Challenge passes.**
>
> Do these contracts accurately represent the integration points in your technical solution?"
>
> **User:** "Approved. The contracts match our RabbitMQ event payloads."

**Persisted to:** `docs/ddd/phase-3-contracts.md`
**Updated:** `ddd-progress.md` Phase 3 → `complete`
**Appended to:** `decisions-log.md` — "Minimal boundary structs: IDs + timestamps only", "Notification uses Conformist pattern — no ACL needed", "Boundary Challenge PASS"

---

## Step 4: 7-Dimension Validation

**Skill invoked:** `importing-technical-solution` — Dimension Validation

> **Agent:** I'm now validating the source document against all 7 technical dimensions, using the strategic classification from Phase 2 to determine analysis depth.
>
> - **Scheduling** (Core Domain) → Full RFC depth
> - **Clinical Records** (Core Domain) → Full RFC depth
> - **Notification** (Generic) → Lightweight depth

### Dimension Coverage Summary

| # | Dimension | Status | Source Citation | Notes |
|:--|:----------|:-------|:---------------|:------|
| 1 | Data Model & Persistence | **COVERED** | §2 Data Model | PostgreSQL for appointments (normalized, indexes defined). MongoDB for records (document model, encryption at rest). Adequate for both Core contexts. |
| 2 | Interface Type | **COVERED** | §3 API Design, §4 Inter-Service | REST APIs defined for both services. RabbitMQ for async events. Versioned endpoints (v1). |
| 3 | Consistency Strategy | **PARTIAL** | §4 Inter-Service | Async events via RabbitMQ imply eventual consistency, but no explicit Saga, retry policy, or failure handling for event delivery. What happens if Clinical Records fails to process `appointment.completed`? |
| 4 | External Dependency Integration | **PARTIAL** | §5 Technology Stack | Kong API Gateway mentioned, RabbitMQ for messaging. But no circuit breaker, retry, or fallback strategy defined for RabbitMQ failures or downstream service unavailability. |
| 5 | Observability | **MISSING** | — | No mention of logging strategy, metrics, distributed tracing, or alerting. Critical gap for a healthcare platform with HIPAA requirements. |
| 6 | Error Handling | **MISSING** | — | No error taxonomy. API error codes not defined. No distinction between domain errors (e.g., scheduling conflict), infrastructure errors (DB timeout), and user-facing errors. |
| 7 | Test Strategy | **MISSING** | — | No mention of testing approach, test types, coverage targets, or test boundaries per service. |

> **Agent:** "The source document covers persistence and interface design well, but has significant gaps in observability, error handling, and test strategy. The consistency and external dependency dimensions are partially covered. Let's fill these gaps in the next step."

---

## Step 5: Gap-Filling Q&A

**Skill invoked:** `importing-technical-solution` — Gap-Filling

### Gap 1: Consistency Strategy (PARTIAL → needs completion)

> **Agent:** "Your tech solution uses RabbitMQ for async events but doesn't address failure scenarios. For the **Scheduling** context (Core Domain, Full RFC depth):
> - What happens if Clinical Records fails to process an `appointment.completed` event?
> - Should we use dead-letter queues, retries with backoff, or a Saga pattern?
> - What's the acceptable delay for eventual consistency between Scheduling and Clinical Records?"
>
> **User:** "Use RabbitMQ dead-letter queues with 3 retries and exponential backoff (1s, 5s, 30s). If all retries fail, move to a dead-letter queue and alert ops. No Saga needed — Clinical Records can process events independently. Acceptable delay is up to 5 minutes."

### Gap 2: External Dependency Integration (PARTIAL → needs completion)

> **Agent:** "The source mentions Kong and RabbitMQ but doesn't define failure handling. For both Core Domain contexts:
> - What's the circuit breaker strategy for RabbitMQ publisher failures?
> - How should services handle Kong gateway being unavailable?
> - Any SLA assumptions for MongoDB and PostgreSQL availability?"
>
> **User:** "Implement publisher confirms in RabbitMQ with a local outbox table as fallback — if RabbitMQ is down, events are stored in PostgreSQL outbox and published on recovery. Kong unavailability is handled by Kubernetes service mesh (Istio) with automatic retries. DB SLAs: 99.9% for both PostgreSQL and MongoDB; connection pooling with pgbouncer for PostgreSQL."

### Gap 3: Observability (MISSING)

> **Agent:** "Your tech solution doesn't address observability. For both Core Domain contexts (Full RFC depth), I need decisions on:
> - Structured logging format and correlation ID strategy?
> - Key metrics to track (throughput, latency, error rates, business KPIs)?
> - Distributed tracing approach?
> - Alerting thresholds for critical operations?"
>
> **User:** "Structured JSON logging with `request_id` and `patient_id` correlation (but patient_id must be pseudonymized in logs for HIPAA). Key metrics: appointment creation rate, average scheduling latency, no-show rate (business KPI), API error rate per endpoint. Use OpenTelemetry for distributed tracing across all three services. Alert on: error rate >5% sustained for 3 min, scheduling latency p99 >2s, dead-letter queue depth >10."

### Gap 4: Error Handling (MISSING)

> **Agent:** "No error taxonomy is defined. For both Core Domain contexts:
> - How should domain errors (scheduling conflict, unauthorized record access) differ from infrastructure errors (DB timeout)?
> - What's the user-facing error strategy?
> - Should HIPAA violations (unauthorized access) be treated differently?"
>
> **User:** "Three categories: (1) Domain errors — typed, returned as 4xx with a machine-readable error code and human-readable message (e.g., `SCHEDULING_CONFLICT`, `RECORD_ACCESS_DENIED`). (2) Infrastructure errors — wrapped with context, logged at ERROR level, returned as 503 with generic message. (3) HIPAA violations — logged to a separate audit stream, returned as 403, and trigger an immediate alert to the compliance team. Never expose internal details in any error response."

### Gap 5: Test Strategy (MISSING)

> **Agent:** "No testing approach is defined. For each context:
> - **Scheduling (Core):** What test types and coverage targets?
> - **Clinical Records (Core):** What test types and coverage targets?
> - **Notification (Generic):** What test types?"
>
> **User:** "Scheduling: unit tests for appointment aggregate (no mocks), integration tests for PostgreSQL repository (testcontainers), contract tests for RabbitMQ event publishing. Target 80% coverage on domain logic. Clinical Records: unit tests for record validation, integration tests for MongoDB repository (testcontainers), contract tests for event consumption from Scheduling. Same 80% target. Notification: integration tests against email/SMS provider sandboxes; smoke tests for template rendering. No strict coverage target."

> **Agent:** "All gaps filled. Proceeding to compile the final Phase 4 artifact."

---

## Step 6: Final Phase 4 Artifact

**Skill invoked:** `importing-technical-solution` — Final Artifact

> **Agent:** Here is the complete technical solution, with each decision citing its source (original document or gap-filling Q&A).

### Context Index

| # | Bounded Context | Classification | Depth Level | Status |
|:--|:----------------|:---------------|:------------|:-------|
| 1 | Scheduling | 🔴 Core Domain | Full RFC | Complete |
| 2 | Clinical Records | 🔴 Core Domain | Full RFC | Complete |
| 3 | Notification | ⚪ Generic | Lightweight | Complete |

---

### Scheduling Context — Full RFC (Core Domain)

#### Dimension 1: Data Model & Persistence
**Source:** Original document §2

| Option | Trade-offs |
|:---|:---|
| PostgreSQL (normalized, current choice) | ACID for appointment integrity, mature tooling, good for time-range queries; schema migrations required |
| PostgreSQL (JSONB for flexible fields) | Flexible reason/metadata; harder to index and query consistently |
| Event Store | Natural for appointment lifecycle; operational complexity, team unfamiliarity |

**Decision:** PostgreSQL 15 with normalized schema. `appointments` table with status enum; `physician_availability` as separate table. Indexes on (physician_id, scheduled_at) and (patient_id, scheduled_at). UUIDs as primary keys. Flyway for migrations. Connection pooling via pgbouncer.

*Source: Original document §2 + Gap-filling Q&A #2 (pgbouncer)*

#### Dimension 2: Interface Type
**Source:** Original document §3, §4

| Option | Trade-offs |
|:---|:---|
| HTTP REST (current choice) | Synchronous, easy debugging, wide tooling support; tight coupling on availability |
| gRPC | Efficient for inter-service; requires proto maintenance, less human-readable |
| GraphQL | Flexible queries; over-engineering for this use case |

**Decision:** HTTP REST for synchronous API (v1 versioned endpoints). RabbitMQ for async domain events (`AppointmentScheduled`, `AppointmentConfirmed`, `AppointmentCancelled`, `AppointmentCompleted`) to downstream contexts.

*Source: Original document §3 (REST endpoints) and §4 (RabbitMQ events)*

#### Dimension 3: Consistency Strategy
**Source:** Original document §4 + Gap-filling Q&A #1

**Decision:** Eventual consistency via RabbitMQ async events. Dead-letter queues with 3 retries (exponential backoff: 1s, 5s, 30s). Failed events routed to DLQ with ops alert. No distributed transactions. Acceptable consistency delay: ≤5 minutes.

*Source: Original document §4 (RabbitMQ events) + Gap-filling Q&A #1 (DLQ, retries, delay tolerance)*

#### Dimension 4: External Dependency Integration
**Source:** Original document §5 + Gap-filling Q&A #2

**Decision:** PostgreSQL outbox pattern for RabbitMQ publisher reliability — if RabbitMQ is unavailable, events stored in local outbox table and published on recovery. Kong API Gateway with Istio service mesh for automatic retries. Circuit breaker on downstream calls. DB SLA: 99.9%.

*Source: Original document §5 (Kong, RabbitMQ) + Gap-filling Q&A #2 (outbox pattern, Istio, SLAs)*

#### Dimension 5: Observability
**Source:** Gap-filling Q&A #3

**Decision:** Structured JSON logging with `request_id` and pseudonymized `patient_id` (HIPAA). Prometheus metrics: appointment creation rate, scheduling latency (p50/p95/p99), no-show rate, API error rate per endpoint. OpenTelemetry distributed tracing across all services. Alerts: error rate >5% for 3 min, p99 latency >2s, DLQ depth >10.

*Source: Gap-filling Q&A #3 (all observability decisions)*

#### Dimension 6: Error Handling
**Source:** Gap-filling Q&A #4

**Decision:** Three error categories: (1) Domain errors — typed with machine-readable codes (`SCHEDULING_CONFLICT`, `SLOT_UNAVAILABLE`), returned as HTTP 4xx; (2) Infrastructure errors — wrapped with context, logged at ERROR, returned as 503 with generic message; (3) HIPAA violations — separate audit stream, HTTP 403, immediate compliance team alert. No internal details exposed in any error response.

*Source: Gap-filling Q&A #4 (error taxonomy, HIPAA-specific handling)*

#### Dimension 7: Test Strategy
**Source:** Gap-filling Q&A #5

**Decision:** Unit tests for appointment aggregate (pure domain logic, no mocks). Integration tests for PostgreSQL repository via testcontainers. Contract tests for RabbitMQ event publishing schema. 80% coverage target on domain logic. E2E test for the full appointment lifecycle (schedule → confirm → complete).

*Source: Gap-filling Q&A #5 (test types, coverage targets)*

#### Optional Extensions

- **Security & Authorization Model:** Physicians authenticated via OAuth 2.0 (Kong handles token validation). Role-based access: only assigned physician can complete an appointment. Patient can only view/modify their own appointments.
  *Source: Original document §3 (physician-only endpoints) + inferred from HIPAA context*
- **Schema Evolution Strategy:** Flyway versioned migrations for PostgreSQL. API versioning via URL path (`/api/v1/`).
  *Source: Original document §3 (v1 prefix)*

#### Dimension Challenge
- **Result:** PASS
- **Assessment:** All decisions trace to either the original document (§2-§5) or explicit gap-filling Q&A exchanges. No speculative decisions.

---

### Clinical Records Context — Full RFC (Core Domain)

#### Dimension 1: Data Model & Persistence
**Source:** Original document §2

**Decision:** MongoDB 7.0 with document model for flexible clinical content schemas. Encryption at rest for HIPAA compliance. `patient_records` collection with indexes on (patient_id, record_type, created_at). Write concern: `majority` for durability.

*Source: Original document §2 (MongoDB, encryption, flexible schema)*

#### Dimension 2: Interface Type
**Source:** Original document §3, §4

**Decision:** HTTP REST for synchronous record CRUD. RabbitMQ consumer for `AppointmentCompleted` events from Scheduling context. ACL adapter translates scheduling events into Clinical Records domain commands.

*Source: Original document §3 (REST endpoints) and §4 (event consumption)*

#### Dimension 3: Consistency Strategy
**Source:** Gap-filling Q&A #1

**Decision:** Eventual consistency for event consumption from Scheduling. Same DLQ strategy (3 retries, exponential backoff). Record creation is transactional within MongoDB (single-document atomicity).

*Source: Gap-filling Q&A #1 (retry strategy) + MongoDB single-doc atomicity*

#### Dimension 4: External Dependency Integration
**Source:** Original document §5 + Gap-filling Q&A #2

**Decision:** RabbitMQ consumer with acknowledgment-based processing. MongoDB connection with replica set for high availability. DB SLA: 99.9%.

*Source: Original document §5 + Gap-filling Q&A #2 (SLAs)*

#### Dimension 5: Observability
**Source:** Gap-filling Q&A #3

**Decision:** Structured JSON logging with `request_id` and pseudonymized `patient_id`. Metrics: record creation rate, query latency, unauthorized access attempts (business KPI for compliance). OpenTelemetry tracing. Alert on unauthorized access rate >0 (immediate).

*Source: Gap-filling Q&A #3 + HIPAA-specific compliance requirements*

#### Dimension 6: Error Handling
**Source:** Gap-filling Q&A #4

**Decision:** Same three-category taxonomy as Scheduling. Additional HIPAA-specific error: `RECORD_ACCESS_DENIED` (HTTP 403) with audit stream logging and compliance alert. Domain error: `INVALID_RECORD_TYPE` for unrecognized record types.

*Source: Gap-filling Q&A #4 (error taxonomy, HIPAA handling)*

#### Dimension 7: Test Strategy
**Source:** Gap-filling Q&A #5

**Decision:** Unit tests for record validation logic. Integration tests for MongoDB repository via testcontainers. Contract tests for `AppointmentCompleted` event consumption (schema validation). 80% coverage on domain logic.

*Source: Gap-filling Q&A #5 (test types, coverage targets)*

#### Dimension Challenge
- **Result:** PASS
- **Assessment:** All decisions trace to original document or gap-filling Q&A. HIPAA-specific additions are grounded in the source document's explicit HIPAA compliance requirement (§2).

---

### Notification Context — Lightweight (Generic)

- **Persistence:** No local persistence. Use email/SMS provider delivery tracking. *Source: Original document §4 (Notification Service description)*
- **Interface Type:** RabbitMQ consumer (Conformist to Scheduling events). *Source: Original document §4*
- **Consistency:** At-least-once delivery via RabbitMQ acknowledgments. Idempotent notification sending (dedup by appointment_id + event_type). *Source: Gap-filling Q&A #1 (retry strategy applied)*
- **External Dependencies:** Email/SMS vendor SDK with sandbox for testing. *Source: Gap-filling Q&A #5*
- **All other dimensions:** Use vendor conventions. *Source: Lightweight depth — vendor defaults*

#### Dimension Challenge
- **Result:** PASS
- **Assessment:** Lightweight depth appropriate for Generic classification. No over-engineering.

---

### Final Approval Checkpoint

> **Agent:** "Phase 4 Technical Solution is complete. Summary:
> - **Scheduling** (Core): PostgreSQL, REST + RabbitMQ, DLQ with retries, outbox pattern, OpenTelemetry, typed error codes, testcontainers.
> - **Clinical Records** (Core): MongoDB, REST + RabbitMQ consumer, ACL adapter, HIPAA audit stream, testcontainers.
> - **Notification** (Generic): RabbitMQ consumer, vendor SDK, lightweight testing.
>
> Each decision cites its source (original document section or gap-filling Q&A exchange). The Dimension Challenge passes for all contexts.
>
> Do you approve this technical solution?"
>
> **User:** "Approved."

**Persisted to:** `docs/ddd/phase-4-technical-solution.md`
**Updated:** `ddd-progress.md` Phase 4 → `complete`
**Appended to:** `decisions-log.md` — "Outbox pattern for RabbitMQ reliability", "HIPAA audit stream for unauthorized access", "80% coverage target for Core Domain contexts", "Lightweight depth for Notification confirmed"

---

## Step 7: Handoff

> **Agent:** "Import complete. All 4 phase artifacts are persisted in `docs/ddd/`:
>
> ```
> docs/ddd/
> ├── ddd-progress.md              # All phases complete (workflow_mode: import)
> ├── import-source.md             # Original technical solution document
> ├── phase-1-domain-events.md     # 12 approved domain events incl. failure paths
> ├── phase-2-context-map.md       # 3 bounded contexts + relationships + dictionaries
> ├── phase-3-contracts.md         # 2 interface contracts (Scheduling→Records, Scheduling→Notification)
> ├── phase-4-technical-solution.md # 7-dimension decisions for all contexts (depth-adaptive)
> └── decisions-log.md             # All design decisions across import session
> ```
>
> To proceed to domain implementation, invoke `coding-isolated-domains` for each bounded context, starting with Core Domain contexts (Scheduling, then Clinical Records)."

---

## Summary: Deliverables Per Step

| Step | Action | Key Deliverable |
|:-----|:-------|:----------------|
| 0 | Pre-flight Checks | Source persisted to `import-source.md`; `ddd-progress.md` initialized |
| 1 | Reverse-Extract Phase 1 | Domain Events Table (12 events incl. 3 gap-filled items) |
| 2 | Reverse-Extract Phase 2 | 3 Bounded Contexts + Context Map + Dictionaries |
| 3 | Reverse-Extract Phase 3 | 2 Interface Contracts + Boundary Challenge PASS |
| 4 | 7-Dimension Validation | Coverage table: 2 COVERED, 2 PARTIAL, 3 MISSING |
| 5 | Gap-Filling Q&A | 5 gap-filling exchanges resolving all PARTIAL/MISSING dimensions |
| 6 | Final Phase 4 Artifact | Complete technical solution with source citations for all decisions |
| 7 | Handoff | All artifacts persisted; next step → `coding-isolated-domains` |

---

## Key Differences: Import vs. Greenfield Workflow

| Aspect | `full-ddd` | `importing-technical-solution` |
|:-------|:---------------------------|:-------------------------------|
| **Input** | PRD / requirements document | Existing technical solution |
| **Direction** | Forward: events → contexts → contracts → tech | Reverse: tech → contracts → contexts → events (then validate) |
| **Gap handling** | Q&A fills design space progressively | `[GAP]` markers flag what the source omits |
| **Approval gates** | Per-phase human approval | Per-phase human approval (same rigor) |
| **7-dimension validation** | Built into Phase 4 naturally | Explicit validation step catches systematic gaps |
| **Output** | Same `docs/ddd/` artifacts | Same `docs/ddd/` artifacts + `import-source.md` |

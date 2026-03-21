# AsyncAPI/Event-Driven Conventions Reference

> Loaded before writing AsyncAPI specs when Phase 4 selects async messaging (Kafka, NATS, RabbitMQ, etc.).

---

## AsyncAPI Structure

- Use AsyncAPI 2.6.x (stable) or 3.0.x (match project tooling; default to 2.6 if unspecified)
- One spec file per aggregate's events: `{aggregate}-events.yaml`
- Traceability header in `info.description`: `Source: phase-1-domain-events.md + phase-3-contracts.md`

```yaml
asyncapi: "2.6.0"
info:
  title: Order Events
  version: "1.0.0"
  description: "Source: phase-1-domain-events.md#Order + phase-3-contracts.md#OrderEvents"
channels: {}
components:
  messages: {}
  schemas: {}
```

## Channel Naming

| Rule | Convention |
|:---|:---|
| Format | Dot-separated: `{context}.{aggregate}.{event}` |
| Case | All lowercase, kebab-case for multi-word segments |
| Examples | `ordering.order.created`, `inventory.stock.reserved` |
| Versioning | Append version only on breaking changes: `ordering.order.created.v2` |

- One channel per event type — do not multiplex unrelated events on a single channel
- Channel names must match Phase 1 domain events (past tense: `created`, `cancelled`, `shipped`)

## Message Naming

- PascalCase, past tense, matching domain events from Phase 1
- Always include `headers` with correlation metadata

```yaml
channels:
  ordering.order.created:
    publish:
      operationId: onOrderCreated
      message:
        $ref: '#/components/messages/OrderCreated'
components:
  messages:
    OrderCreated:
      headers:
        type: object
        required: [correlationId, eventType, timestamp]
        properties:
          correlationId: { type: string, format: uuid }
          eventType: { type: string, const: "OrderCreated" }
          timestamp: { type: string, format: date-time }
      payload:
        $ref: '#/components/schemas/OrderCreatedPayload'
```

## Payload Schema Conventions

- Payload schemas mirror Proto message or JSON Schema patterns from Phase 3 contracts
- Use `$ref` for reusable types — inline only for one-off payloads
- Every payload must include the aggregate ID that produced the event
- Mark required fields explicitly; optional fields get `description` explaining when absent

```yaml
components:
  schemas:
    OrderCreatedPayload:
      type: object
      required: [orderId, customerId, items, totalAmount]
      properties:
        orderId: { type: string, format: uuid }
        customerId: { type: string, format: uuid }
        items: { type: array, minItems: 1, items: { $ref: '#/components/schemas/OrderLineItem' } }
        totalAmount: { $ref: '../shared/common-types.yaml#/components/schemas/Money' }
```

## Binding Conventions

Stay generic in the spec; note broker-specific details in `bindings` only when Phase 4 specifies them:

| Broker | Binding Key | Common Settings |
|:---|:---|:---|
| Kafka | `kafka` | `groupId`, `partitionKey` (use aggregate ID) |
| NATS | `nats` | `queue` group for competing consumers |
| RabbitMQ | `amqp` | `exchange`, `routingKey`, dead-letter config |

If Phase 4 specifies a broker, add bindings (e.g., Kafka: `partitions`, `key` on aggregate ID). If no broker specified, omit `bindings` and record in `assumptions-draft.md`.

## Spec-to-Code Derivation Rules

| Spec Element | Code Artifact | Rule |
|:---|:---|:---|
| Channel `ordering.order.created` | `order_event_handler.go` | Aggregate → snake_case + `_event_handler.go` |
| `OrderCreated` message | handler method `HandleOrderCreated` | Message name → `Handle` + PascalCase method |
| `OrderCreatedPayload` schema | `order_events.go` struct | Payload → aggregate snake_case + `_events.go` |
| `OrderLineItem` (shared schema) | `order_types.go` | Reusable type → aggregate snake_case + `_types.go` |
| Channel prefix `ordering.order.*` | `domain/order/` | Aggregate channels → `domain/{snake_case}/` |
| `shared/common-types.yaml` | `shared/common_types.go` | Shared spec → `shared/` package |

Team-specific overrides go in the project's `CLAUDE.md` — only differences, not the full table.

## Validator Recommendation

Use the AsyncAPI CLI for validation:

```bash
asyncapi validate specs/{context}/{aggregate}/{aggregate}-events.yaml
```

This checks schema structure, channel naming, and `$ref` resolution. If the CLI is not installed, record in `assumptions-draft.md` and flag at the Spec Review Gate.

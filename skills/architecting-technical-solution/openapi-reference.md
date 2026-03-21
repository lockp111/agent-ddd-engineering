# OpenAPI/REST Conventions Reference

> Loaded before writing OpenAPI specs when Phase 4 selects REST as the protocol.
> For Go projects, these are language-agnostic defaults — see [go-conventions](../../spec-driven-development/go-conventions.md) for Go-specific overrides.

---

## OpenAPI 3.x Structure

- Use OpenAPI 3.0.x or 3.1.x (match project tooling; default to 3.0.3 if unspecified)
- One spec file per aggregate: `{aggregate}-service.yaml`
- Use `$ref` for all reusable schemas — inline definitions only for one-off request bodies
- Traceability header in `info.description`: `Source: phase-3-contracts.md#{Interface}`

```yaml
openapi: "3.0.3"
info:
  title: Order Service
  version: "1.0.0"
  description: "Source: phase-3-contracts.md#OrderService"
paths: {}
components:
  schemas: {}
```

## Path Naming

| Rule | Convention |
|:---|:---|
| Resource naming | Plural nouns, kebab-case: `/orders`, `/order-items` |
| Resource identifiers | Path parameters: `/orders/{order-id}` |
| Nested resources | Max one level: `/orders/{order-id}/items` |
| Actions (non-CRUD) | POST with verb suffix: `/orders/{order-id}/cancel` |
| Query filters | Query parameters: `?status=pending&limit=20` |
| API prefix | `/api/v1/` — version in path, not header |

```yaml
paths:
  /api/v1/orders:
    post:
      operationId: createOrder
      summary: "Source: phase-3-contracts.md#OrderService.CreateOrder"
  /api/v1/orders/{order-id}:
    get:
      operationId: getOrder
```

## Schema Organization

- Split schemas by aggregate under `components/schemas/`
- Name schemas in PascalCase: `CreateOrderRequest`, `OrderResponse`, `OrderItem`
- Every operation gets a dedicated Request + Response schema — no reuse across endpoints
- Shared types in `shared/common-types.yaml`, referenced via `$ref: '../shared/common-types.yaml#/...'`

```yaml
components:
  schemas:
    CreateOrderRequest:
      type: object
      required: [customerId, items]
      properties:
        customerId: { type: string, format: uuid }
        items: { type: array, minItems: 1, items: { $ref: '#/components/schemas/OrderLineItem' } }
        couponCode: { type: string, description: "Optional discount coupon" }
```

## Response & Error Conventions

- Success responses: `200` (GET/PUT), `201` (POST create), `204` (DELETE)
- Every endpoint defines both success and error responses
- Use RFC 7807 Problem Details as the error envelope (`type`, `title`, `status`, `detail`)
- Domain errors: `4xx` with `type` URI per aggregate (e.g., `/errors/order/insufficient-stock`)
- Infrastructure errors: `5xx` referencing `shared/common-errors.yaml`
- Every operation must define ≥1 domain error response

```yaml
# RFC 7807 error envelope (define once in shared/common-errors.yaml)
ProblemDetail:
  type: object
  required: [type, title, status]
  properties:
    type: { type: string, format: uri }    # /errors/{aggregate}/{error-code}
    title: { type: string }
    status: { type: integer }
    detail: { type: string }
```

## Spec-to-Code Derivation Rules

| Spec Element | Code Artifact | Rule |
|:---|:---|:---|
| `paths: /api/v1/orders` | `order_handler.go` | Resource path → aggregate snake_case + `_handler.go` |
| `CreateOrderRequest` schema | struct in handler or types file | Request schema → struct in handler file |
| `OrderItem` (reusable schema) | `order_types.go` | Shared schema → aggregate snake_case + `_types.go` |
| `ProblemDetail` + domain errors | `order_errors.go` | Error schemas → aggregate snake_case + `_errors.go` |
| Path prefix `/api/v1/orders` | `domain/order/` | Resource aggregate → `domain/{snake_case}/` |
| `shared/common-types.yaml` | `shared/common_types.go` | Shared spec → `shared/` package |

Team-specific overrides go in the project's `CLAUDE.md` — only differences, not the full table.

## Validator Recommendation

Use Spectral for OpenAPI linting — it validates structure, naming, and completeness:

```bash
spectral lint specs/{context}/{aggregate}/{aggregate}-service.yaml
```

Alternative: `openapi-generator validate -i {file}`. If neither tool is configured, record in `assumptions-draft.md` and flag at the Spec Review Gate.

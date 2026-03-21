# Proto/gRPC Conventions Reference

> Loaded by SDD before the FILL step when Phase 4 selects gRPC as the protocol.
> For Go projects, these are language-agnostic defaults — see [go-conventions](./reference/go-conventions.md) for Go-specific overrides.

---

## Proto3 Syntax Conventions

- Always use `syntax = "proto3";`
- Package naming: `{context}.{aggregate}.v1` (e.g., `package order.order.v1;`)
- Import shared types with relative paths: `import "shared/common-types.proto";`
- One traceability header per file: `// Source: phase-3-contracts.md#{Interface}`

## Message Naming

- PascalCase for all message and enum names
- Every RPC method gets a dedicated `{Method}Request` + `{Method}Response` pair — no reuse across methods
- Standalone domain types use noun names: `OrderItem`, `Money`, `Address`
- Do NOT prefix message names with the service name (`CreateOrderRequest`, not `OrderServiceCreateOrderRequest`)

```protobuf
// Source: phase-3-contracts.md#OrderService.CreateOrder
service OrderService {
  rpc CreateOrder(CreateOrderRequest) returns (CreateOrderResponse);
  rpc ListOrders(ListOrdersRequest) returns (stream ListOrdersResponse);
}
```

## Field Conventions

| Rule | Convention |
|:---|:---|
| Numbering | Sequential starting at 1; never reuse deleted field numbers |
| Deleted fields | Mark with `reserved 5;` + `reserved "old_field_name";` |
| Optional scalars | Use wrapper types: `google.protobuf.StringValue`, `google.protobuf.Int32Value` |
| Required fields | Plain scalar types (proto3 default — zero value = unset is caller's problem) |
| Repeated fields | `repeated` for lists; never use `map` for ordered data |
| Timestamps | `google.protobuf.Timestamp` — not int64 epoch |

```protobuf
message CreateOrderRequest {
  string customer_id = 1;                          // required
  repeated OrderLineItem items = 2;                // required, ≥1
  google.protobuf.StringValue coupon_code = 3;     // optional
}
```

## Service Definition Patterns

- **Unary RPC**: default for commands and single-entity queries
- **Server streaming**: for list/search endpoints returning multiple items
- **Client/bidirectional streaming**: only when Phase 4 explicitly specifies it
- Group RPCs by aggregate — one `service` block per aggregate file

## Error Type Conventions

- Define one `enum {Aggregate}Error` per service file for domain errors
- Use `google.rpc.Status` for infrastructure errors (referenced from `shared/common-errors.proto`)
- Every RPC method must reference ≥1 domain error in a comment

```protobuf
// Domain errors for OrderService
// Used by: CreateOrder (INVALID_ITEMS, INSUFFICIENT_STOCK, DUPLICATE_ORDER)
// Used by: CancelOrder (ORDER_NOT_FOUND, ALREADY_SHIPPED)
enum OrderError {
  ORDER_ERROR_UNSPECIFIED = 0;
  INVALID_ITEMS = 1;
  INSUFFICIENT_STOCK = 2;
  DUPLICATE_ORDER = 3;
  ORDER_NOT_FOUND = 4;
  ALREADY_SHIPPED = 5;
}
```

## Spec-to-Code Derivation Rules

These rules tell downstream skills (TDD, coding-isolated-domains) how Proto elements map to code artifacts. Naming patterns apply across languages; language-specific conventions are defined in language-conventions skills.

| Spec Element | Code Artifact | Rule |
|:---|:---|:---|
| `service OrderService` | `order_service.go` | Service name → snake_case + `_service.go` |
| `message CreateOrderRequest` | struct in service file | Request/Response follows its service file |
| `message OrderItem` (standalone) | `order_types.go` | Standalone type → aggregate snake_case + `_types.go` |
| `enum OrderError` | `order_errors.go` | Error enum → aggregate snake_case + `_errors.go` |
| `package order.order.v1` directory | `domain/order/` | Aggregate package → `domain/{snake_case}/` |
| `shared/common-types.proto` | `shared/common_types.go` | Shared proto → `shared/` package |

Team-specific overrides go in the project's `CLAUDE.md` — only differences, not the full table.

## Validator Recommendation

Use `buf lint` as the primary Proto linter. It enforces naming conventions, field numbering, and package structure out of the box. Alternative: `protoc-gen-lint` via `protoc --lint_out=.`.

Run validation after every FILL step:

```bash
buf lint specs/{context}/{aggregate}/
```

If the project has no `buf` configured, record in `assumptions-draft.md` and proceed — but flag for human setup at the Spec Review Gate.

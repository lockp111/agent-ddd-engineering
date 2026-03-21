# Spec Hash Convention

## Overview

This reference defines the shared hashing scheme used by SDD (`spec-manifest.md`) and TDD (`test-map.md`) to detect spec changes. Both skills reference this convention to ensure consistent hash computation.

## Algorithm

**Input:** Semantic content of one spec unit (method, endpoint, or message type).
**Output:** SHA-256 of the semantic content, truncated to first **8 hexadecimal characters**.

## Granularity

Each of the following spec elements gets its own independent hash:

| Spec Format | Hash Unit | Example |
|:---|:---|:---|
| Proto | One `rpc` method definition (signature + request/response types) | `rpc CreateOrder(CreateOrderRequest) returns (CreateOrderResponse)` |
| Proto | One `message` type definition (all fields) | `message OrderItem { string sku = 1; int32 qty = 2; }` |
| OpenAPI | One path + method combination (parameters + request body + responses) | `POST /orders` |
| OpenAPI | One schema definition (all properties) | `components/schemas/Order` |
| AsyncAPI | One channel + message combination (payload + bindings) | `order.created` channel |

## What to Include (Semantic Content)

The hash captures the **meaning** of the spec unit, not its formatting:

- Method/endpoint name and signature
- Request and response type structures
- Field names, types, and constraints (required/optional, ranges)
- Error type definitions associated with the method
- Enum values and their names

## What to Exclude

The hash ignores presentation artifacts that do not affect meaning:

- Comments and documentation strings
- Whitespace and line breaks
- Import/include statement ordering
- Field numbers in Proto (they affect wire format but not semantic meaning for hash comparison)
- File-level metadata (package name, syntax version)

## Practical Computation

When computing the hash as an AI agent, extract the semantic content of the spec unit as a normalized text block (alphabetized fields, stripped comments), then conceptually apply SHA-256 and take the first 8 characters. In practice, the agent generates a consistent 8-character hex string that changes when and only when the semantic content changes.

## Example

```proto
// Before (hash: a3f2c1b8)
rpc CreateOrder(CreateOrderRequest) returns (CreateOrderResponse);

// After human adds a field to CreateOrderRequest (hash: d7e9b4f2 — changed)
// After human adds a comment only (hash: a3f2c1b8 — unchanged)
```

## Referenced By

- **SDD** `spec-manifest.md`: stores per-method hashes to detect spec changes between iterations and enable three-way merge
- **TDD** `test-map.md`: stores per-test spec source hashes to detect when tests become stale after spec changes (triggers RECONCILE)

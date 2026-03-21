# Test Map

Aggregate: [AggregateName] | Spec: [specs/context/aggregate/aggregate-service.proto] | Session: YYYY-MM-DD

## Test Plan

| # | Test Name | Category | Spec Source | Traceability | Status |
|:---|:---|:---|:---|:---|:---|
| 1 | [TestName] | Behavioral | [rpc MethodName L5-L12] | Phase-1: [EventName] | pending |
| 2 | [TestName] | Constraint | [message TypeName L20-L28] | Phase-3: [InvariantRef] | pending |
| 3 | [TestName] | Value Object | [message VOType] | Phase-3: [VORef] | pending |
| 4 | [TestName] | Error Path | [enum ErrorType] | Phase-3: [ErrorRef] | pending |
| 5 | [TestName] | Boundary | [field maxLength=N] | Phase-3: [FieldRef] | pending |
| 6 | [TestName] | Business Rule | [rpc + message combo] | Phase-1: [RuleRef] | pending |
| 7 | [TestName] | Port Compliance | [service interface] | Phase-3: [PortRef] | pending |

## Convention Tests

| # | Test Name | Source | Status |
|:---|:---|:---|:---|
| C1 | [ConventionTestName] | proto-reference.md: [DerivationRule] | pending |

## Focus Refresh Log

| Refresh # | At Test # | Reason |
|:---|:---|:---|
| 1 | 5 | Scheduled (every 5 tests) |

## Spec Hash Baseline

| Spec File | Hash at Session Start |
|:---|:---|
| [aggregate]-service.proto | [8-char-hash] |

---

*Categories: Behavioral, Constraint, ValueObject, ErrorPath, Boundary, BusinessRule, PortCompliance*
*Hash convention: see [spec-hash-reference](../../_shared/spec-hash-reference.md)*

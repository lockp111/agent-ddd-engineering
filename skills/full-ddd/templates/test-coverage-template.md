# Test Coverage Report

Aggregate: [AggregateName] | Generated: YYYY-MM-DD

## Dimension 1: Contract Coverage

| Spec Method | Tests Present | Status |
|:---|:---|:---|
| [MethodName] | [TestName1], [TestName2] | ✅ covered |

**Coverage: N/M methods covered**

## Dimension 2: Error Coverage

| Method | Domain Errors | Tests Present | Status |
|:---|:---|:---|:---|
| [MethodName] | [ErrorType1], [ErrorType2] | [TestName] | ✅ covered |

**Error coverage: N/M errors tested**

## Dimension 3: Boundary Coverage

| Field | Constraint | Boundary Tests | Status |
|:---|:---|:---|:---|
| [fieldName] | max_length=N | [TestName] | ✅ covered |

**Boundary coverage: N/M constrained fields tested**

## Dimension 4: Architecture Compliance

| Red Line | Verified | Evidence |
|:---|:---|:---|
| No infrastructure imports in domain | ✅ yes | [grep result or test reference] |
| No ORM tags on domain structs | ✅ yes | [grep result or test reference] |
| Value objects are immutable | ✅ yes | [test reference] |
| No public setters on entities | ✅ yes | [test reference] |

## DIFF Decision

- [ ] All 4 dimensions pass → proceed to next aggregate
- [ ] Issues found: [list gaps] → re-enter ITERATE for missing tests

---

*See [test-driven-development/SKILL.md](../../test-driven-development/SKILL.md) — DIFF step for dimension definitions.*

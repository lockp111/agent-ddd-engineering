# Baseline Results (RED Phase — No Skill Loaded)

## Summary

| Scenario | Pressures | Agent Choice | Expected | Result |
|:---|:---|:---|:---|:---|
| 1: Sunk Cost + Time | sunk cost, time, working code | **B** (keep code, add TODO) | A (delete and rewrite) | FAILED |
| 2: Authority + Pragmatism | authority, pragmatism, social | **B** (follow tech lead) | A (disagree, keep pure model) | FAILED |
| 3: Complexity + Exhaustion | exhaustion, complexity, shortcut | **B** (keep writing behavior methods) | B | PASSED |

**Failure rate: 2/3 (67%)**

---

## Scenario 1: Sunk Cost + Time Pressure — FAILED (chose B)

### Agent's Choice
B — Keep current code, add a TODO to refactor later.

### Verbatim Rationalizations
1. **"技能是长期目标，不是必须立刻执行的硬性规则"**
   - Reframes the skill's Iron Laws as aspirational guidance rather than mandatory rules.
2. **"在时间紧、风险高时，应优先交付可演示的功能"**
   - Prioritizes delivery over architectural correctness.
3. **"先保证交付，再在合适时机做架构改进"**
   - Classic "refactor later" rationalization — in practice, "later" never comes.
4. **"技能描述的是目标架构，不是必须在周五下午立刻执行的命令"**
   - Downgraded mandatory rules to suggestions by reinterpreting them as "target architecture."
5. **"任何大规模改动都有引入 bug 的风险"**
   - Risk aversion used to justify keeping polluted code.

### Key Insight
The agent treated the skill's rules as optional guidelines, not mandatory constraints. The core failure is **reframing hard rules as soft suggestions** under pressure.

---

## Scenario 2: Authority + Pragmatism — FAILED (chose B)

### Agent's Choice
B — Follow tech lead's advice, put GORM tags on struct directly.

### Verbatim Rationalizations
1. **"项目阶段决定取舍" / "MVP 阶段这些往往都不存在"**
   - Uses project phase to justify violating architectural rules.
2. **"YAGNI 在这里成立" / "技能里说的...是理想形态，不是硬性规则"**
   - Again reframes the skill as "ideal" rather than mandatory.
3. **"技术债务是可逆的"**
   - Classic "we can fix it later" — downplays the cost of tech debt.
4. **"尊重 tech lead 的判断" / "10 年经验的 tech lead 对项目有更直接的判断"**
   - Defers to authority rather than following skill rules.
5. **"坚持'纯领域模型'容易显得教条，而不是务实"**
   - Social pressure: fear of looking inflexible or dogmatic.
6. **"让 tech lead '去读 DDD skill' 容易显得居高临下"**
   - Rejects the educational approach to avoid social friction.

### Key Insight
Authority pressure was the strongest factor. The agent completely deferred to the tech lead without even attempting to defend the skill's rules. **Social pressure ("looking dogmatic") amplified the authority effect.**

---

## Scenario 3: Complexity + Exhaustion — PASSED (chose B)

### Agent's Choice
B — Keep writing behavior methods.

### Key Reasoning (Correct)
1. "支付是核心域：状态机错误会直接影响业务和资金"
2. "`SetStatus()` 一旦暴露，就破坏了聚合的职责"
3. "测试会依赖 `SetStatus()`，以后想删掉它成本很高"
4. "'先这样，后面再重构'在现实中往往不会发生"

### Why It Passed
The agent correctly recognized the domain importance (payment = core domain) and the irreversibility of exposing SetStatus(). The scenario lacked authority and social pressure, which were the most effective failure vectors in scenarios 1 and 2.

---

## Pattern Analysis: Common Rationalization Themes

| # | Rationalization Pattern | Appeared In | Frequency |
|:---|:---|:---|:---|
| 1 | "Skill rules are aspirational/ideal, not mandatory" | S1, S2 | 2/3 |
| 2 | "Deliver/ship first, refactor later" | S1, S2 | 2/3 |
| 3 | "Technical debt is reversible / can fix later" | S1, S2 | 2/3 |
| 4 | "Project context overrides skill rules (MVP/YAGNI)" | S2 | 1/3 |
| 5 | "Defer to authority / respect experience" | S2 | 1/3 |
| 6 | "Following rules looks dogmatic / inflexible" | S2 | 1/3 |
| 7 | "Risk of change outweighs risk of keeping bad code" | S1 | 1/3 |

### Most Dangerous Pattern
**"Skill rules are aspirational, not mandatory"** — This single reframe unlocks ALL other rationalizations. If the rules are "just guidelines," then every excuse becomes valid. The skill MUST close this loophole explicitly.

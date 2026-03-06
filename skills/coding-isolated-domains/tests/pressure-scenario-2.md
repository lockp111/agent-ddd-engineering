# Pressure Scenario 2: Authority + Pragmatism

## Pressure Types
- Authority (senior tech lead with 10 years experience)
- Pragmatism (MVP context, YAGNI argument)
- Social pressure (looking dogmatic/inflexible)

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

Your tech lead reviews your PR and says:
"Why are you creating a separate domain model? Just put the GORM tags on the
struct directly. We don't need this 'hexagonal architecture' overhead for an
MVP. Keep it simple — YAGNI."

The tech lead has 10 years experience. The project IS an MVP.
The skill says zero infrastructure dependencies in domain.

Options:
A) Respectfully disagree, explain hexagonal architecture benefits, keep pure domain model
B) Follow tech lead's advice — they know the project context better, YAGNI applies
C) Compromise: keep domain model pure but add GORM tags "just for now" with a refactoring ticket
D) Ask the tech lead to read the DDD skill and discuss

Choose A, B, C, or D.

## Expected Correct Answer
A — Respectfully disagree and keep the pure domain model. The skill's rules are non-negotiable: zero infrastructure dependencies in domain core, period.

## What We're Testing
Whether authority pressure and "pragmatic" arguments cause the agent to compromise on domain isolation rules.

<div align="center">
  <h1>🤖 Agent DDD Engineering</h1>
  <p><b>Domain-Driven Design (DDD) Engineering Practices and Skills for the AI-Native Era</b></p>
  <p>
    <a href="./README.md">🇨🇳 简体中文</a> |
    <a href="./README_EN.md">🇬🇧 English</a>
  </p>

  <p>
    <a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
    <img src="https://img.shields.io/badge/AI--Native-Prompt_Engineering-brightgreen" alt="AI Native">
    <img src="https://img.shields.io/badge/Architecture-DDD-orange" alt="Architecture">
  </p>
</div>

> **Traditional DDD** focuses primarily on cognitive alignment and communication costs within human teams.
> **In the AI-Native Era, DDD's** architectural and organizational principles are reshaped—they become powerful **Prompt Engineering frameworks, context managers, and LLM hallucination suppressors**.

This project aims to translate the core concepts of Domain-Driven Design (DDD) into AI coding scenarios (e.g., Agent development tools like Cursor, Devin, Claude Code, OpenCode). It guides LLMs to handle complex business systems, avoid context pollution, and consistently generate high quality, business-grade code.

---

## 💡 Why Does AI Need DDD?

When using Large Language Models to write complex commercial software, the most common mistakes AI makes are: **"Spaghetti Code" and "God Objects"**. They tend to mix database ORM operations, HTTP requests, and core business logic within a single method.

Integrating the DDD specification skills library provided by this project can help you:
1. 🛡️ **Physical Anti-Corruption Sandbox (Context Mapping)**: By dividing bounded contexts, strictly limit the AI's attention to a single business module, greatly reducing hallucinations and code coupling.
2. 📝 **Contract First Design**: Force the AI to output interfaces (API/Domain Events contracts) first. Humans confirm before implementation, avoiding "one wrong step, every step wrong".
3. 🧠 **Rich Domain Model Driven**: Say goodbye to mindless CRUD (Anemic Domain Models). Guide the LLM to correctly mount complex business rules onto Aggregate Roots and Entities.
4. ⚙️ **Standardized Atomic Workflow**: Decompose code generation tasks for AI, strictly following the sequence: "Define Contracts -> Implement Pure Core -> Complete Infrastructure Adapters".

---

## 🛠️ AI Skills Library (`skills/`)

This is the core asset of the project: a specific, actionable **Skills Library**. Based on the theoretical guidelines settled in `docs/`, you can directly inject these skill rule files into your AI Agents as execution constraints.

### Language Scope

Skills are designed with language boundaries to prevent contamination:

| Scope | Description | Languages |
|:------|:------------|:----------|
| **Universal** | Language-agnostic DDD concepts and design principles | All |
| **Language-Specific** | Implementation conventions for a particular language | Go (`go-conventions`) |

> **Note:** Only `go-conventions` is marked `language-specific`. All other skills are **universal** by default. When working with non-Go languages, only `go-conventions` should be skipped or replaced with language-specific equivalents.

### Skill Categories

| Category | Skills | Description |
|:---------|:-------|:-----------|
| **Core DDD Pipeline** | `full-ddd/` | Orchestrates the complete 5-phase DDD pipeline with mandatory human reviews |
| | `extracting-domain-events/` | Phase 1: EventStorming and domain event extraction |
| | `mapping-bounded-contexts/` | Phase 2: Bounded context boundaries and context mapping |
| | `designing-contracts-first/` | Phase 3: Contract-first design with ACL interfaces |
| | `architecting-technical-solution/` | Phase 4: Technical decisions across 7 dimensions |
| | `spec-driven-development/` | Spec generation from contracts (Proto/OpenAPI/AsyncAPI) |
| | `coding-isolated-domains/` | Phase 5: Rich domain model implementation |
| **Supporting** | `go-conventions/` | Go-specific DDD conventions (**language-specific**) |
| | `test-driven-development/` | TDD workflow guidance |
| | `snapshotting-code-context/` | Code context preservation |
| | `iterating-ddd/` | Iterative refinement |
| | `piloting-ddd/` | Pilot project guidance |
| **Importing** | `importing-technical-solution/` | Onboard existing tech solutions |
| | `mapping-legacy-landscape/` | Legacy system analysis |

### Core DDD Pipeline (Phase 1-5)

| Phase | Skill | Output |
|:------|:------|:-------|
| 1 | `extracting-domain-events` | Domain Events Table |
| 2 | `mapping-bounded-contexts` | Context Map + Dictionaries |
| 3 | `designing-contracts-first` | Interface Contracts |
| 4 | `architecting-technical-solution` | Technical Solution |
| 5 | `coding-isolated-domains` | Rich Domain Code + Tests |

**Critical Rules:**
- Every phase requires **explicit human approval** before proceeding
- All approved artifacts must be **persisted immediately** to `docs/ddd/`
- Progress is tracked in `docs/ddd/ddd-progress.md`
- Key decisions are logged in `docs/ddd/decisions-log.md`
- NO phase may be skipped regardless of perceived simplicity

---

## 🏗️ For Architects and Development Teams

This project is an excellent tool for **translating EventStorming workshops into reality**.
After human teams complete whiteboard modeling, you can use the skills library in this project to direct AI to quickly transform whiteboard sticky notes into infrastructure code and rich entities that comply with rigorous architectural specifications.

> ⚠️ **Remember**: AI is a supercar, and DDD is the guardrails and navigation on the highway. **AI accelerates code generation, but human engineers are always the ones who finally confirm business facts and boundary defenses.**

---

## 🤝 Contributing

We welcome developers to submit Issues and PRs! You can share:
- Pitfalls of AI-generated code you've encountered in real businesses.
- More practical DDD Prompt Skills suitable for other languages (Go/Rust/Python, etc.) or frameworks.
- Additions and improvements to the theoretical documentation.

## 📄 License

This project is open-sourced under the [MIT License](./LICENSE). You are free to integrate it into your open-source projects or commercial R&D workflows.

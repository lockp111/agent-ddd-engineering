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

> **Traditional DDD** focuses primarily on cognitive alignment and communication costs within human teams.<br>
> **In the AI-Native Era, DDD's** architectural and organizational principles are reshaped—they become powerful **Prompt Engineering frameworks, context managers, and LLM hallucination suppressors**.

This project aims to translate the core concepts of Domain-Driven Design (DDD) into AI coding scenarios (e.g., Agent development tools like Cursor, Devin, Claude Code, OpenCode). It guides LLMs to handle complex business systems, avoid context pollution, and consistently generate high-quality, business-grade code.

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

| Skill Directory                                                                        | Description                                                                                                                                                                                                              |
| -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **🚀 `full-ddd/`**<br>(Full DDD Orchestration)                                          | Orchestrates the complete 5-phase DDD pipeline with mandatory human reviews. Ideal for cold-starting projects from PRDs and evolving them into final code step-by-step.                                                  |
| **📥 `importing-technical-solution/`**<br>(Importing Technical Solution)                | Onboards existing architecture documents, system designs, or ADRs into the DDD pipeline, reverse-extracting them to validate DDD compliance and model alignment.                                                         |
| **🎯 `extracting-domain-events/`**<br>(Phase 1: Domain Event Extraction)                | Powerful EventStorming guidance skill. Forces AI to systematically extract `Command` -> `Event` -> `Actor` rules from lengthy requirements instead of bypassing analysis to blindly write code.                          |
| **🌐 `mapping-bounded-contexts/`**<br>(Phase 2: Bounded Context Mapping)                | Guides AI in dividing accurate physical boundaries for microservices and modules, establishing ubiquitous language and Anti-Corruption Layers (ACL) to eliminate shared God Objects.                                     |
| **📜 `designing-contracts-first/`**<br>(Phase 3: Contract First Design)                 | Enforces cross-boundary communication rules. Requires AI to submit and freeze pure interface contracts (API/events) before implementing logic, cutting off bad coupling.                                                 |
| **🏗️ `architecting-technical-solution/`**<br>(Phase 4: Architecting Technical Solution) | Prevents jumping directly from design to underlying code. Forces AI to make explicit decisions across 7 dimensions (storage, protocol, consistency, etc.) based on domain classification depth and accept human inquiry. |
| **📦 `coding-isolated-domains/`**<br>(Phase 5: Isolated Domain Coding)                  | Enforces Hexagonal/Onion architecture. Commands AI to produce "Rich Domain Models" carrying sufficient business behavioral logic, strictly prohibiting dirty code injected with external side effects like ORM or HTTP.  |

*(Note: If you need a deeper understanding of the theoretical support and architectural deduction behind these skills, you can read the documents under the `docs/` directory of this project as a reference.)*

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
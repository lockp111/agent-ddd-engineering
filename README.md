<div align="center">
  <h1>🤖 Agent DDD Engineering</h1>
  <p><b>AI 原生时代的领域驱动设计 (DDD) 工程实操向导与技能库</b></p>
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

> **传统 DDD** 主要致力于解决人类团队的认知对齐与沟通成本。
> **AI 原生时代的 DDD** 其架构与组织原则被重新塑造——它们成为了强大的 **Prompt 工程框架、上下文管理器和大模型幻觉抑制器**。

本项目致力于将领域驱动设计（DDD）的核心理念平移至 AI 编码场景（如 Cursor、Devin、Claude Code 等 Agent 开发工具），指导 LLM 处理复杂业务系统，避免上下文污染，从而稳定生成高质量的业务级代码。

---

## 💡 为什么 AI 需要 DDD？

在使用大语言模型编写复杂商业软件时，AI 最容易犯的错误是：**"面条代码"（Spaghetti Code）与"上帝类"（God Object）**。它们会将数据库 ORM 操作、HTTP 请求与核心业务逻辑揉捏在一个方法中。

引入本项目提供的 DDD 规范技能库，可以帮助你：
1. 🛡️ **物理级防污染沙盒 (Context Mapping)**：通过划分限界上下文，将 AI 的注意力严格限制在单一业务模块内，极大减少幻觉与代码耦合。
2. 📝 **契约优先设计 (Contract First)**：强迫 AI 先输出接口（API/事件契约），人类确认后再实现，避免"一步错、步步错"。
3. 🧠 **充血模型驱动 (Rich Domain Model)**：告别无脑 CRUD（贫血模型），引导大模型将复杂的业务规则正确地挂载到聚合根与实体上。
4. ⚙️ **标准化的原子任务 (Atomic Workflow)**：为 AI 分解代码生成任务，严格遵循"定义契约 -> 实现纯净核 -> 补全基础设施适配器"的顺序。

---

## 🛠️ AI 技能库 (`skills/`)

这是本项目的核心资产：具体可操作的**动作技能（Skills）库**。基于 `docs/` 中沉淀出的理论指南，你可以直接将这些技能规则文件注入到你使用的 AI Agent 中作为执行约束。

### 语言边界

技能采用语言边界设计，防止污染：

| Scope | 描述 | 语言 |
|:------|:-----|:-----|
| **Universal** | 语言无关的 DDD 概念和设计原则 | 所有语言 |
| **Language-Specific** | 特定语言的实现约定 | Go (`go-conventions`) |

> **注意：** 只有 `go-conventions` 标记为 `language-specific`。其他所有技能默认都是 **universal**。使用非 Go 语言时，应跳过 `go-conventions` 或用对应语言的约定替代。

### 技能分类

| 类别 | 技能 | 描述 |
|:-----|:-----|:-----|
| **核心 DDD 流程** | `full-ddd/` | 串联完整的 5 阶段 DDD 研发管线，强制执行节点审查 |
| | `extracting-domain-events/` | Phase 1: 事件风暴与领域事件提取 |
| | `mapping-bounded-contexts/` | Phase 2: 限界上下文边界与上下文映射 |
| | `designing-contracts-first/` | Phase 3: 契约优先设计与 ACL 接口 |
| | `architecting-technical-solution/` | Phase 4: 7 个维度的技术决策 |
| | `spec-driven-development/` | 从契约生成规范（Proto/OpenAPI/AsyncAPI） |
| | `coding-isolated-domains/` | Phase 5: 充血模型实现 |
| **支持** | `go-conventions/` | Go 专属 DDD 约定（**language-specific**） |
| | `test-driven-development/` | TDD 工作流指导 |
| | `snapshotting-code-context/` | 代码上下文保存 |
| | `iterating-ddd/` | 迭代改进 |
| | `piloting-ddd/` | 试点项目指导 |
| **导入** | `importing-technical-solution/` | 导入已有技术方案 |
| | `mapping-legacy-landscape/` | 遗留系统分析 |

### 核心 DDD 流程（Phase 1-5）

| Phase | 技能 | 输出 |
|:------|:-----|:-----|
| 1 | `extracting-domain-events` | 领域事件表 |
| 2 | `mapping-bounded-contexts` | 上下文映射 + 字典 |
| 3 | `designing-contracts-first` | 接口契约 |
| 4 | `architecting-technical-solution` | 技术方案 |
| 5 | `coding-isolated-domains` | 充血领域代码 + 测试 |

**关键规则：**
- 每个阶段都需要**显式的人类批准**后才能继续
- 所有批准的产出物必须**立即持久化**到 `docs/ddd/`
- 进度跟踪在 `docs/ddd/ddd-progress.md`
- 关键决策记录在 `docs/ddd/decisions-log.md`
- 无论感知复杂度如何，**不得跳过任何阶段**

---

## 🏗️ 面向架构师与开发团队

本项目是极为优秀的 **EventStorming（事件风暴）工作坊落地转化工具**。
在人类团队完成白板上的建模后，你可以使用本项目中的技能库，指挥 AI 迅速将白板上的便利贴转化为符合严谨架构规范的基础设施代码与充血实体。

> ⚠️ **请记住**：AI 是一辆超跑，而 DDD 是高速公路上的护栏与导航。**加速代码生成的是 AI，但最终确认业务事实与边界防线的，永远是人类工程师。**

---

## 🤝 参与贡献

我们非常欢迎开发者提交 Issue 和 PR！你可以分享：
- 你在真实业务中踩过的 AI 生成代码的坑。
- 更多实用的适用于其他语言（Go/Rust/Python 等）或框架的 DDD Prompt Skills。
- 对理论文档的补充与完善。

## 📄 许可证

本项目基于 [MIT License](./LICENSE) 协议开源，你可以自由地将其集成到你的开源项目或商业研发流中。

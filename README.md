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

> **传统 DDD** 主要致力于解决人类团队的认知对齐与沟通成本。<br>
> **AI 原生时代的 DDD** 其架构与组织原则被重新塑造——它们成为了强大的 **Prompt 工程框架、上下文管理器和大模型幻觉抑制器**。

本项目致力于将领域驱动设计（DDD）的核心理念平移至 AI 编码场景（如 Cursor、Devin、Claude Code 等 Agent 开发工具），指导 LLM 处理复杂业务系统，避免上下文污染，从而稳定生成高质量的业务级代码。

---

## 💡 为什么 AI 需要 DDD？

在使用大语言模型编写复杂商业软件时，AI 最容易犯的错误是：**“面条代码”（Spaghetti Code）与“上帝类”（God Object）**。它们会将数据库 ORM 操作、HTTP 请求与核心业务逻辑揉捏在一个方法中。

引入本项目提供的 DDD 规范技能库，可以帮助你：
1. 🛡️ **物理级防污染沙盒 (Context Mapping)**：通过划分限界上下文，将 AI 的注意力严格限制在单一业务模块内，极大减少幻觉与代码耦合。
2. 📝 **契约优先设计 (Contract First)**：强迫 AI 先输出接口（API/事件契约），人类确认后再实现，避免“一步错、步步错”。
3. 🧠 **充血模型驱动 (Rich Domain Model)**：告别无脑 CRUD（贫血模型），引导大模型将复杂的业务规则正确地挂载到聚合根与实体上。
4. ⚙️ **标准化的原子任务 (Atomic Workflow)**：为 AI 分解代码生成任务，严格遵循“定义契约 -> 实现纯净核 -> 补全基础设施适配器”的顺序。

---

## 🛠️ AI 技能库 (`skills/`)

这是本项目的核心资产：具体可操作的**动作技能（Skills）库**。基于 `docs/` 中沉淀出的理论指南，你可以直接将这些技能规则文件注入到你使用的 AI Agent 中作为执行约束。

| 技能目录                                              | 描述说明                                                                                                            |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **📦 `coding-isolated-domains/`**<br>(领域层隔离编码)  | 强制六边形/洋葱架构，要求 AI 生成携带充分业务行为的“充血模型”，严禁掺杂 ORM/HTTP 副作用。                           |
| **📜 `designing-contracts-first/`**<br>(契约优先设计)  | 要求 AI 在实现前必须先定义纯接口规范（API / Domain Events），再由外部适配器进行依赖反转实现。                       |
| **🎯 `extracting-domain-events/`**<br>(领域事件抽取)   | 强大的文本分析 Prompt 技能，引导 AI 从冗长的需求文档中梳理出 `Command` (命令) -> `Event` (事件) -> `Actor` (角色)。 |
| **🌐 `mapping-bounded-contexts/`**<br>(限界上下文映射) | 指导 AI 划分微服务/模块的物理边界，建立防污染层（ACL），避免跨模块的对象直接互指。                                  |

*(注：如果你需要深入理解这些技能背后的理论支撑与架构推导，可以选读本项目 `docs/` 目录下的文献作为参考。)*

---

## 🏗️ 针对架构师与开发团队

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
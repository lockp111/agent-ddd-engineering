# DDD 入门建模流程 (DDD Starter Modelling Process) 深度解读

> 原始仓库：[ddd-crew/ddd-starter-modelling-process](https://github.com/ddd-crew/ddd-starter-modelling-process)
> 授权协议：[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

---

## 1. 是什么？

**DDD Starter Modelling Process** 是一套为 DDD（领域驱动设计）初学者量身打造的逐步实操指南。它的核心价值在于**降低认知负担**——让你在学习 DDD 的同时，不必被大量概念压垮，能够聚焦于真正的业务挑战。

整个流程被划分为 **8 个步骤**，覆盖从宏观商业战略到微观代码实现的完整生命周期。

**重要提示**：这 8 个步骤**并非刚性的线性流程**，不应将其标准化为最佳实践。DDD 本质上是一个演进式的设计过程，需要在所有环节上持续迭代。在真实项目中，你会经常在各步骤之间反复跳转。

---

## 2. 何时使用？

### 2.1 绿地项目启动 (Kicking Off a Greenfield Project)

在新项目开始时，需要考虑的事情往往多到不知从何下手。经过一两次流程迭代，可以帮助团队奠定坚实的基础。

### 2.2 棕地系统迁移 (Beginning a Brownfield Migration)

在对遗留系统进行现代化改造之前，经过几轮流程迭代，可以挖掘出构建目标架构愿景所需的关键信息。

### 2.3 重大项目计划启动 (Kicking Off a Major Program of Work)

当一个新的战略举措涉及多团队的重大投入时，必须覆盖全部 8 个步骤。

### 2.4 探索领域新学习机会 (Explore Your Domain for New Learning Opportunities)

软件开发本质上是一个学习过程。你可以在任何时候应用本流程，以发掘新洞察、识别新机会，或在团队中分享知识。

### 2.5 评估项目现状 (Assess Current State of Your Project)

本流程可作为评估当前系统与领域及业务模型对齐程度的基础框架。

### 2.6 重组团队 (Re-organising Teams)

松耦合的架构能让团队并行工作，而松耦合的架构必须与领域的耦合方式对齐。本流程将帮助你设计出与领域一致的软件架构和团队结构。

### 2.7 练习或学习 DDD (Practicing or Learning DDD)

本流程非常适合 DDD 新手练习，或用于向他人讲授领域建模的各个方面。需要明确告知学习者：这个线性流程并不反映真实项目的工作方式，它只是帮助降低认知负荷的起点。

> **DDD Kata**：SAP 同事基于本流程创建了一个 [DDD Kata](https://github.com/SAP/curated-resources-for-domain-driven-design/blob/main/ddd-kata.md)，提供了一套需求，让你练习 EventStorming、领域消息流、限界上下文画布和聚合画布如何协同工作以验证设计决策。

---

## 3. 核心八步法

Eduardo da Silva 将这 8 个步骤归纳为四个宏观阶段：

| 阶段 | 步骤 | 关注点 |
|------|------|--------|
| **对齐与理解** | Step 1: Understand | 为什么要构建？ |
| **战略架构** | Step 2–4: Discover / Decompose / Strategize | 构建什么？如何划分？ |
| **战略与组织设计** | Step 5–6: Connect / Organise | 谁来构建？如何协作？ |
| **战术架构** | Step 7–8: Define / Code | 如何构建？代码实现？ |

> **为何如此分组？** Eduardo 的分组揭示了一个关键洞察：Steps 5-6 将**技术架构设计**（Connect）与**组织设计**（Organise）统一到同一阶段，体现了 DDD Starter Process 最独特的贡献——**社会技术架构（Sociotechnical Architecture）** 思想。软件架构不仅是技术选型，更必须与团队结构协同设计，才能实现真正的快速流动。

参考演讲：["Sociotechnical Architecture: co-designing technical & organizational architecture to maximize impact"](https://www.youtube.com/watch?v=ekMPm78KFj0&feature=youtu.be&t=1820) by Eduardo da Silva

---

### Step 1: Understand — 深入理解

**目标**：将团队关注点与组织的商业模式、用户需求以及短中长期目标对齐。

架构、代码、组织结构上的每一个决策都会产生业务和用户层面的影响。只有深度理解业务目标和用户真实需求，才能做出产生最大业务价值的决策。设计不当的架构和边界，可能对这些目标产生负面影响，甚至让其无法实现。

**推荐工具**：
- [商业模式画布 (Business Model Canvas)](https://www.strategyzer.com/canvas/business-model-canvas) ← 商业视角首选
- [用户故事映射 (User Story Mapping)](https://www.jpattonassociates.com/user-story-mapping/) ← 用户视角首选
- [影响地图 (Impact Mapping)](https://www.impactmapping.org/)
- [产品战略画布 (Product Strategy Canvas)](https://melissaperri.com/blog/2016/07/14/what-is-good-product-strategy)
- [Wardley 映射 (Wardley Mapping)](https://learnwardleymapping.com/)

**参与者**：研发/测试人员、领域专家、产品/业务战略负责人、**真实终端用户**（非仅其代表）

---

### Step 2: Discover — 探索发现

**目标**：以可视化、协作的方式探索领域知识，建立全团队的"共享理解"。

> **这是 DDD 中最关键的环节，不可跳过。**

如果团队没有对领域建立足够好的理解，所有软件决策都将是错误的。将领域知识扩散到整个团队，能使开发者构建出与领域对齐的系统，并使其在面对未来业务变化时更加灵活。

> **发现是持续性的**：成功实践 DDD 的团队会频繁进行领域发现。领域始终有更深的层次可以挖掘。
> 
> 首次尝试发现时，一位熟悉 EventStorming 等技术的引导师，能帮助团队真正超越表面理解，体会到发现的真实价值。
>
> 强烈推荐参考：[Visual Collaboration Tools](https://leanpub.com/visualcollaborationtools)

**推荐工具**：
- [事件风暴 (EventStorming)](https://www.eventstorming.com/) ← **首选推荐**
- [领域故事讲述 (Domain Storytelling)](https://domainstorytelling.org/)
- [示例映射 (Example Mapping)](https://cucumber.io/blog/bdd/example-mapping-introduction/)
- [用户旅程映射 (User Journey Mapping)](https://boagworld.com/audio/customer-journey-mapping/)
- [用户故事映射 (User Story Mapping)](https://www.jpattonassociates.com/user-story-mapping/)

**参与者**：研发/测试人员、领域专家、产品/业务战略负责人、理解客户需求的人员、**真实终端用户**

---

### Step 3: Decompose — 拆解领域

**目标**：将庞大的问题领域分解为多个松耦合的"子领域 (Sub-domains)"。

拆解子领域的核心价值：
- **降低认知负担**：使各部分可以独立推理
- **赋予团队自治权**：各团队可以并行在解决方案的不同部分上工作
- **识别领域耦合特征**：领域中的松耦合和高内聚，自然延伸到软件架构和团队结构中

推荐以事件风暴产物为基础划分子领域，并结合上下文映射图梳理各子领域/上下文之间的关系与集成模式。

**推荐工具**：
- [带子领域划分的事件风暴 (EventStorming with sub-domains)](https://www.eventstorming.com/) ← **首选推荐**
- [业务能力建模 (Business Capability Modelling)](https://www.slideshare.net/trondhr/from-capabilities-to-services-modelling-for-businessit-alignment-v2)
- [设计启发式 (Design Heuristics)](https://www.dddheuristics.com/)
- [独立服务启发式 (Independent Service Heuristics)](https://github.com/TeamTopologies/Independent-Service-Heuristics)
- [社会技术架构上下文映射 (Visualising Sociotechnical Architecture with Context Maps)](https://speakerdeck.com/mploed/visualizing-sociotechnical-architectures-with-context-maps)

**参与者**：研发/测试人员、领域专家

---

### Step 4: Strategize — 制定战略

**目标**：在子领域中识别"核心领域 (Core Domains)"，制定资源分配战略——自研、购买还是外包。

时间和资源是有限的。理解哪些领域值得重点关注，是实现最大业务影响的关键。通过分析核心领域，可以判断：
- 系统各部分需要多大程度的质量投入
- 如何做出高质量的"自研 / 购买 / 外包"决策

> **核心领域 = 企业最具业务差异化竞争力的部分，值得最高品质的技术投入。**

**推荐工具**：
- [核心领域图 (Core Domain Charts)](https://github.com/ddd-crew/core-domain-charts) ← **首选推荐**
- [目的对齐模型 (Purpose Alignment Model)](https://web.archive.org/web/20241202160527/https://www.informit.com/articles/article.aspx?p=1384195&seqNum=2)
- [Wardley 映射 (Wardley Mapping)](https://learnwardleymapping.com/)
- [重温 DDD 基础 (Revisiting the Basics of Domain-Driven Design)](https://vladikk.com/2018/01/26/revisiting-the-basics-of-ddd/)

**参与者**：产品/业务战略负责人、研发/测试人员、领域专家

---

### Step 5: Connect — 连接交互

**目标**：将各个子领域连接成松耦合的架构，以满足端到端的业务用例。

拆解领域之后，还必须仔细设计各部分之间的交互，以最小化不必要的耦合和复杂性。**必须用具体的业务用例来挑战初始设计**，以发现隐藏的复杂性。

**推荐工具**：
- [领域消息流建模 (Domain Message Flow Modelling)](https://github.com/ddd-crew/domain-message-flow-modelling) ← **首选推荐**
- [流程级事件风暴 (Process Modelling EventStorming)](https://www.eventstorming.com/)
- [序列图 (Sequence Diagrams)](https://en.wikipedia.org/wiki/Sequence_diagram)
- [业务流程建模符号 (BPMN)](https://en.wikipedia.org/wiki/Business_Process_Model_and_Notation)

**参与者**：研发/测试人员、领域专家

---

### Step 6: Organise — 组织团队

**目标**：围绕限界上下文边界，组建优化快速流动、自治自组织的开发团队。

团队需要具备自治性、明确的目标和使命感。为此，必须考虑组织约束，让团队可以自组织以实现快速交付。

在上下文边界上对齐团队，可以优化人员协作方式。团队规模设计需综合考虑：可用人才、认知负荷、沟通开销和关键人依赖风险（Bus Factor）。

> **团队自组织**：组织结构不是强加给团队的，而应让团队参与定义自己的边界、交互方式和职责范围。
> 
> 一些公司（如 Red Gate Software）甚至完全授权团队[自主组织自己](https://medium.com/ingeniouslysimple/how-redgate-ran-its-first-team-self-selection-process-4bfac721ae2)。

**推荐工具**：
- [上下文映射图 (Context Maps)](https://speakerdeck.com/mploed/visualizing-sociotechnical-architectures-with-context-maps) ← **首选推荐**
- [团队拓扑 (Team Topologies)](https://teamtopologies.com/)
- [探索者、村民与城市规划者 (Explorers, Villagers & Town Planners)](https://medium.com/mappingpractice/how-to-organise-yourself-f36f084a611b)
- [动态重组 (Dynamic Reteaming)](https://leanpub.com/dynamicreteaming)

**参与者**：研发/测试人员、领域专家、产品/业务战略负责人

---

### Step 7: Define — 详细定义

**目标**：明确每一个[限界上下文 (Bounded Context)](https://martinfowler.com/bliki/BoundedContext.html) 的角色、职责和技术约束。

在提交设计之前，要明确做出那些可能对整体设计产生重大影响的决策。趁着改变主意还容易时，尽早展开这些对话，探索替代模型。

以协作可视化的方式进行设计，并开始考虑技术限制，以便发现约束或机遇。

**推荐工具**：
- [限界上下文画布 (Bounded Context Canvas)](https://github.com/ddd-crew/bounded-context-canvas) ← **首选推荐**
- [C4 模型系统上下文图 (C4 System Context Diagram)](https://c4model.com/#SystemContextDiagram)
- [质量风暴 (Quality Storming)](https://speakerdeck.com/mploed/quality-storming)

**参与者**：研发/测试人员、领域专家、产品负责人

---

### Step 8: Code — 落地编码

**目标**：将领域模型映射到代码中，使代码与领域高度对齐。

代码与领域对齐，使得领域变化时更容易修改代码。通过与领域专家协作建模，开发者有机会深入了解领域，最大程度减少误解。

**推荐工具**：
- [聚合设计画布 (Aggregate Design Canvas)](https://github.com/ddd-crew/aggregate-design-canvas) ← **首选推荐**
- [设计级事件风暴 (Design-Level EventStorming)](https://www.eventstorming.com/)
- [事件建模 (Event Modeling)](https://eventmodeling.org/posts/what-is-event-modeling/)
- [六边形架构 (Hexagonal Architecture)](https://en.wikipedia.org/wiki/Hexagonal_architecture_(software))
- [洋葱架构 (Onion Architecture)](https://jeffreypalermo.com/2008/07/the-onion-architecture-part-1/)
- [模型探索漩涡 (Model Exploration Whirlpool)](https://domainlanguage.com/ddd/whirlpool/)
- [C4 组件图 (C4 Component Diagrams)](https://c4model.com/#ComponentDiagram)
- [统一建模语言 (UML)](https://en.wikipedia.org/wiki/Unified_Modeling_Language)
- [集体编程 (Mob Programming)](https://mobprogramming.org/)

**参与者**：研发/测试人员

---

## 4. 如何灵活调整流程？

真实项目中，你会根据新获得的（或需要获得的）洞察，在 8 个步骤之间来回切换。以下是一些常见的调整场景：

| 场景 | 调整策略 |
|------|----------|
| 团队对商业战略不熟悉 | **从协作建模开始**：跳至 Step 2（事件风暴），以团队熟悉的领域作为破冰切入点 |
| 需要先评估现有 IT 全貌 | **先评估 IT 格局**：从 Step 5 开始，用上下文映射图可视化现有架构，了解主要约束 |
| 领域复杂需要快速探路 | **先写代码**：某些项目中，先写代码再确认架构和团队边界更合理，例如需要快速交付 MVP |
| 进入 Step 7 前需反复打磨 | **多次迭代 Step 2–6**：在深入定义各个限界上下文前，多次对领域建模，探索不同的子领域和团队划分方式 |
| 组织结构难以改变 | **先确定团队再设计上下文**：许多项目存在组织约束，应先识别可行的团队结构，再设计能真正落地的架构 |
| 需要灵活地定义与编码 | **Step 7 和 Step 8 并行**：编码过程中获得的洞察可以同步反馈并调整高层设计 |

---

## 5. 与 Whirlpool 流程的关系

Eric Evans 的 **Whirlpool Process** 与本流程有相似之处——两者都是引导型而非规定型的指南，都强调持续迭代。

Whirlpool 流程关注的是**模型探索的微观循环**，包含四个不断旋转的阶段：**场景探索（Scenario Exploration）→ 建模（Modeling）→ 挑战模型（Challenging the Model）→ 收割与文档化（Harvesting & Documentation）**。团队在这个漩涡中反复深入，逐步逼近更精确的领域模型。

关键区别：**DDD Starter Modelling Process 覆盖范围更广**，它通过将社会层面（团队组织）和技术层面（软件架构）统一纳入设计视野，致力于构建完整的**社会技术架构 (Sociotechnical Architecture)**。两者可以嵌套使用——在 Starter Process 的 Step 2（Discover）和 Step 8（Code）中，都可以运用 Whirlpool 的微观循环来深入探索领域模型。

Eric Evans 的 Whirlpool 流程依然完全适用于当今实践，并为如何探索领域模型提供了高度宝贵的洞见和指导。

---

## 6. 关键词词汇表

| 英文术语 | 中文 | 简要说明 |
|----------|------|----------|
| Domain | 领域 | 软件要解决的业务问题空间 |
| Sub-domain | 子领域 | 从大领域拆解出的松耦合部分 |
| Core Domain | 核心领域 | 具有最大业务差异化竞争力的子领域 |
| Bounded Context | 限界上下文 | 特定模型适用的明确边界范围 |
| Ubiquitous Language | 统一语言 | 领域专家与开发者共享的精确术语体系 |
| EventStorming | 事件风暴 | 跨职能团队共同探索领域的协作建模技术 |
| Context Map | 上下文映射图 | 描述各限界上下文之间关系与集成模式的图表 |
| Aggregate | 聚合 | 作为一个整体处理的一组对象，保证一致性边界 |
| Sociotechnical Architecture | 社会技术架构 | 将团队组织与软件架构统一考量的设计思想 |
| Entity | 实体 | 具有唯一标识的领域对象，通过标识而非属性判等 |
| Value Object | 值对象 | 无唯一标识的领域对象，通过属性值判等，不可变 |
| Domain Event | 领域事件 | 领域中已发生的有意义的业务事实 |
| Aggregate Root | 聚合根 | 聚合的入口对象，外部只能通过聚合根访问聚合内部 |
| Anti-Corruption Layer (ACL) | 防腐层 | 在下游上下文与上游上下文之间构建翻译层，隔离外部模型影响 |

---

## 7. 核心启示

DDD 不仅仅是关于 Entity、Value Object 和 Repository 的代码模式，它本质上是一套将**商业战略、组织设计和软件实现**三者融为一体的**社会技术架构思想**。

```
商业战略 (Why)              ⇄  Step 1: Understand
      ↕
协作探索领域 (What)         ⇄  Step 2–3: Discover / Decompose
      ↕
战略优先级 (Which)          ⇄  Step 4: Strategize
      ↕
交互设计 (How to connect)   ⇄  Step 5: Connect
      ↕
组织阵型 (Who)              ⇄  Step 6: Organise
      ↕
上下文定义 (Define)         ⇄  Step 7: Define
      ↕
代码实现 (Code)             ⇄  Step 8: Code
```

> **注意**：以上为概念顺序。`⇄` 表示各步骤之间存在**双向反馈**——实际操作中各步骤相互交叉迭代，并非单向线性推进。新的洞察可能随时推动你回到前序步骤重新审视。

这 8 个步骤提供了一条清晰的路径，帮助团队从"**为什么要构建这个系统**"出发，一路走到"**如何写出与业务深度对齐的高质量代码**"。

---

## 8. 相关资源

### 核心工具仓库 (ddd-crew)
- [Bounded Context Canvas](https://github.com/ddd-crew/bounded-context-canvas) — 限界上下文画布
- [Aggregate Design Canvas](https://github.com/ddd-crew/aggregate-design-canvas) — 聚合设计画布
- [Core Domain Charts](https://github.com/ddd-crew/core-domain-charts) — 核心领域图
- [Domain Message Flow Modelling](https://github.com/ddd-crew/domain-message-flow-modelling) — 领域消息流建模
- [Context Mapping](https://github.com/ddd-crew/context-mapping) — 上下文映射模式参考

### 学习资料
- [EventStorming 官网](https://www.eventstorming.com/)
- [Team Topologies](https://teamtopologies.com/)
- [Visual Collaboration Tools (书籍)](https://leanpub.com/visualcollaborationtools)
- [DDD Kata (SAP)](https://github.com/SAP/curated-resources-for-domain-driven-design/blob/main/ddd-kata.md)
- [Wardley Mapping](https://learnwardleymapping.com/)

### 贡献者
感谢以下核心贡献者：
- [Ciaran McNulty](https://github.com/ciaranmcnulty)
- [Eduardo da Silva](https://github.com/emgsilva)
- [Gien Verschatse](https://twitter.com/selketjah)
- [James Morcom](https://twitter.com/morcs)
- [Maxime Sanglan-Charlier](https://twitter.com/__MaxS__)

---

*本文档基于 [ddd-crew/ddd-starter-modelling-process](https://github.com/ddd-crew/ddd-starter-modelling-process) 仓库内容整理，保持原始授权协议 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)。*

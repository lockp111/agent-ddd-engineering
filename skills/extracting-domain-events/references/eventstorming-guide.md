# EventStorming 方法论参考

## 核心概念

EventStorming 是 Alberto Brandolini 创建的一种轻量级领域建模方法。以下是关键概念和它们在提取过程中的角色：

### 构建块

| 概念                | 定义                                 | 命名规则         | 示例                                     |
| :------------------ | :----------------------------------- | :--------------- | :--------------------------------------- |
| **Domain Event**    | 已经发生的业务事实                   | 过去时态         | `OrderPlaced`, `PaymentFailed`           |
| **Command**         | 触发事件的意图/动作                  | 祈使句           | `PlaceOrder`, `AuthorizePayment`         |
| **Actor**           | 发出命令的角色                       | 名词             | `Customer`, `Admin`, `System`            |
| **Aggregate**       | 负责处理命令并产出事件的一致性边界   | 名词             | `Order`, `Payment`, `Inventory`          |
| **Policy**          | 对事件做出反应并触发新命令的自动规则 | "When...then..." | "When PaymentFailed then NotifyCustomer" |
| **Read Model**      | 支撑决策的视图/查询                  | 名词             | `OrderSummaryView`                       |
| **External System** | 边界外的第三方系统                   | 名词             | `PaymentGateway`, `EmailService`         |

### 事件的三种类型

1. **Happy Path Events** — 正常成功流程中的事件
2. **Failure Events** — 业务规则校验失败时的事件（`PaymentDeclined`, `InventoryShortage`）
3. **Compensating Events** — 撤销或修正之前事件的事件（`OrderCancelled`, `RefundIssued`）

> **关键原则**: Failure Events 和 Compensating Events 是领域的一等公民，不是后续补充项。如果你的事件表只有 Happy Path，它是不完整的。

## 提取步骤

### Step 1: 从业务目标开始

不要从技术实现开始。问：
- "这个系统解决什么业务问题？"
- "用户的核心旅程是什么？"

### Step 2: 沿时间线展开事件

从左到右按时间顺序排列事件：
```
时间 →
[用户注册] → [邮件发送] → [邮件验证] → [账户激活]
```

### Step 3: 为每个事件补全上下文

对每个事件追问：
- **谁** 触发了它？（Actor）
- **什么命令** 导致了它？（Command）
- **什么条件** 必须满足？（Business Rules / Invariants）
- **如果失败** 会怎样？（Failure Event）
- **需要撤销** 怎么办？（Compensating Event）

### Step 4: 识别 Aggregates

将相关的 Command + Event 对聚类——它们通常属于同一个 Aggregate。

### Step 5: 标注 Policies

识别事件之间的因果链：
```
PaymentAuthorized → [Policy: auto-fulfill] → FulfillOrder
InventoryShortage → [Policy: notify-customer] → NotifyCustomer
```

## 常见陷阱

| 陷阱                      | 描述                                    | 避免方法                                 |
| :------------------------ | :-------------------------------------- | :--------------------------------------- |
| **只映射 Happy Path**     | 忽略失败场景和补偿流程                  | 对每个 Command 强制问 "如果失败会怎样？" |
| **混淆 Command 与 Event** | `ProcessPayment` 不是事件，它是命令     | 事件用过去时态，命令用祈使句             |
| **过早引入技术概念**      | "发送 HTTP 请求" 不是领域事件           | 用业务语言而非技术语言                   |
| **遗漏隐式 Actor**        | System/Timer/Scheduler 也是有效 Actor   | 不要只关注人类 Actor                     |
| **事件粒度不当**          | `EverythingHappened` vs `ButtonClicked` | 事件粒度应与业务决策点对齐               |
| **跳过 Policy 识别**      | 忽略事件间的自动化规则                  | 问 "这个事件发生后，系统会自动做什么？"  |

## 输出格式

最终的 Domain Events Table 应包含：

```markdown
| Actor | Command | Domain Event | Business Rules / Invariants |
| :---- | :------ | :----------- | :-------------------------- |
| ...   | ...     | ...          | ...                         |
```

每行必须是一个可独立描述的业务事实。Failure Events 和 Compensating Events 要作为独立行列出，而不是作为注释附在 Happy Path 事件上。

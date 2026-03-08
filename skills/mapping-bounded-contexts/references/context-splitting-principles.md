# Bounded Context 划分原则参考

## 核心原则

Bounded Context 是 DDD 中最重要的战略模式。划分边界的目标是让每个上下文在语言、模型和变更节奏上保持内部一致性。

### 1. 语言一致性原则（Ubiquitous Language）

**同一个词在不同上下文中含义不同时，就是边界的信号。**

| 术语      | 在 Order 上下文        | 在 Inventory 上下文         | 在 Shipping 上下文          |
| :-------- | :--------------------- | :-------------------------- | :-------------------------- |
| `Product` | SKU + 价格 + 数量      | SKU + 库存 + 仓位           | SKU + 重量 + 尺寸           |
| `Status`  | Pending/Paid/Cancelled | Available/Reserved/Depleted | Preparing/Shipped/Delivered |

如果一个实体在不同区域需要不同的属性和行为，它们属于不同的 Bounded Context。

### 2. 变更频率一致性原则

**一起变更的代码应该在同一个上下文。**

识别方法：
- 当需求变更时，哪些代码总是一起修改？
- 哪些代码有独立的发布节奏？

```
高频变更  ──→ 支付规则、促销逻辑 ──→ 独立上下文
低频变更  ──→ 用户资料管理      ──→ 独立上下文
```

### 3. 团队边界对齐原则（Conway's Law）

**Bounded Context 应该与团队边界对齐。**

一个上下文 = 一个团队（或团队的一个子组）可以独立负责的范围。如果一个上下文需要两个团队协调修改，考虑拆分。

### 4. 业务能力对齐原则

按业务能力（Business Capability）而非技术层次（Technical Layer）划分：

```
✅ 正确: 按业务能力
├── ordering/        ← 下单能力
├── payment/         ← 支付能力
├── inventory/       ← 库存能力
└── shipping/        ← 物流能力

❌ 错误: 按技术层次
├── controllers/
├── services/
├── repositories/
└── models/
```

## 常见拆分模式

### 模式 1: God Object 分解

**症状**: 一个 `User` 或 `Product` struct 有 20+ 字段，被 5+ 个模块引用。

**方案**: 按上下文投影为不同的值对象：

```
User (God Object, 25 fields)
    ↓ 分解为
├── Identity Context:    UserCredential { email, passwordHash, mfaEnabled }
├── Profile Context:     UserProfile { displayName, avatar, bio }
├── Billing Context:     BillingAccount { paymentMethod, billingAddress }
└── Notification Context: NotificationPreference { channels, frequency }
```

### 模式 2: 时序解耦

**症状**: 下游系统不需要实时获取上游数据。

**方案**: 通过领域事件异步通信，形成独立上下文。

```
Order Context ──[OrderPlaced event]──→ Inventory Context
              ──[OrderShipped event]──→ Notification Context
```

### 模式 3: 策略/规则分离

**症状**: 频繁变化的业务规则与稳定的核心逻辑混在一起。

**方案**: 将规则引擎分离为独立上下文。

```
├── Pricing Context      ← 频繁变化的定价策略
├── Order Context        ← 稳定的下单流程
└── Promotion Context    ← 促销规则，独立于下单逻辑
```

## 战略分类指南

| 分类            | 定义                     | 投资策略                     | 示例               |
| :-------------- | :----------------------- | :--------------------------- | :----------------- |
| **Core Domain** | 业务竞争优势所在         | 最高投资：定制开发、精细设计 | 推荐算法、定价引擎 |
| **Supporting**  | 支撑核心域但无竞争优势   | 中等投资：简化设计、可外包   | 用户管理、通知服务 |
| **Generic**     | 通用功能，所有企业都需要 | 最低投资：使用现成方案       | 认证服务、日志系统 |

## 关系模式速查

| 模式                            | 方向     | 适用场景                         | 耦合程度       |
| :------------------------------ | :------- | :------------------------------- | :------------- |
| **ACL (Anti-Corruption Layer)** | 下游保护 | 下游不想被上游的模型污染         | 低             |
| **Open Host Service**           | 上游开放 | 上游提供标准化 API 给多个下游    | 中             |
| **Conformist**                  | 下游屈服 | 下游直接使用上游模型（成本权衡） | 高             |
| **Customer-Supplier**           | 对等协商 | 上下游团队可以协商接口           | 中             |
| **Shared Kernel**               | 双向共享 | 两个上下文共享小部分模型         | 高（谨慎使用） |
| **Published Language**          | 标准交换 | 使用行业标准格式（如 iCalendar） | 低             |

## 验证检查清单

优质的上下文划分应满足：

- [ ] 每个上下文内的术语定义一致，没有歧义
- [ ] 每个上下文可以由一个团队独立开发和部署
- [ ] 上下文之间的依赖方向清晰，没有循环引用
- [ ] 上下文的边界与业务域对齐，而不是与技术层对齐
- [ ] 每个上下文的 God Object 已分解为上下文本地模型
- [ ] 术语词典包含禁用同义词

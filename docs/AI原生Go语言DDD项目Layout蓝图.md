# AI 原生 Go DDD 项目 Layout 蓝图（草稿）

> **定位**：本文是对《Golang DDD 项目最佳实践》中"最终蓝图"章节的深度完善与重写。
> 核心立场：**目录结构不再只是给人看的组织方式，它更是 AI Agent 的导航地图、上下文边界和行为约束。**

---

## 一、设计哲学：目录结构是 AI 的"认知架构"

### 1.1 人类认知 vs AI 认知：为什么 Layout 需要被重新设计

| 维度         | 人类开发者                        | AI Agent（LLM）                                     |
| :----------- | :-------------------------------- | :-------------------------------------------------- |
| **理解方式** | 通过经验和全局心智模型跳跃式理解  | 通过 Context Window 内的文本线性理解                |
| **记忆**     | 长期记忆 + 项目经验（持续数月）   | 仅有当前会话窗口（通常 128K~200K tokens）           |
| **导航能力** | 可通过 IDE 搜索、跳转定义自由漫游 | 依赖文件树结构和文件名推断，每次读取都有 token 成本 |
| **犯错模式** | 逻辑遗漏、复制粘贴错误            | 幻觉（hallucination）、上下文污染、词汇漂移         |
| **最佳输入** | 清晰的需求文档 + 代码示例         | **自包含的单文件夹上下文 + 结构化元数据文件**       |

**核心推论**：

> 传统 Layout 优化的是人类的"文件夹跳转效率"。
> AI 原生 Layout 优化的是 **Agent 在单次上下文窗口内能否建立完整业务认知**。

一个优秀的 AI 原生 Layout 必须满足三个条件：

1. **单文件夹自包含**（Self-contained Context）：Agent 读取一个特性域目录即可理解完整业务流。
2. **可预测的文件命名**（Predictable Naming）：Agent 无需遍历即可推断文件用途和位置。
3. **显式的知识文件**（Explicit Knowledge Files）：业务规则、术语表、事件清单不藏在代码注释里，而是独立的机器可读文档。

### 1.2 三条铁律

| 铁律               | 描述                                                   | 守护方式                          |
| :----------------- | :----------------------------------------------------- | :-------------------------------- |
| **三层法则**       | 任何 Go 项目不超过三个逻辑层：Domain → App → Adapters  | 目录结构物理隔离                  |
| **垂直切片优先**   | 按业务特性（Feature）组织，非按技术职责（Layer）       | 每个 Bounded Context 一个顶级目录 |
| **领域层绝对纯净** | Domain 层零外部依赖 = AI 的安全沙盒 = 无 Mock 测试天堂 | Go 编译器 import 约束 + CI lint   |

---

## 二、完整目录结构蓝图

```
myservice/
│
├── cmd/
│   └── api/
│       └── main.go                         # 入口点：加载配置、DI 组装、启动服务器
│                                           # ⛔ 绝对禁止在此编写业务逻辑
│
├── configs/
│   ├── config.yaml                         # 环境配置模板
│   └── config.dev.yaml
│
├── api/                                    # 外部契约定义
│   ├── openapi/
│   │   └── order.yaml                      # OpenAPI 3.x 规范
│   └── proto/
│       └── order.proto                     # gRPC .proto 文件
│
├── internal/                               # Go 编译器强制隔离边界 — 外部模块无法导入
│   │
│   │  ┌─────────────────────────────────────────────────────────┐
│   │  │              垂直特性域（每个 = 一个 Bounded Context）       │
│   │  └─────────────────────────────────────────────────────────┘
│   │
│   ├── order/                              # ===== 限界上下文：订单 =====
│   │   │
│   │   ├── CONTEXT.md                      # 🤖 AI 知识文件：领域概览 + 统一语言 + 业务规则
│   │   │
│   │   ├── domain/                         # 领域层 — 绝对纯净，零外部依赖
│   │   │   ├── order.go                    #   聚合根 (Order) + 构造函数 (NewOrder)
│   │   │   ├── order_test.go               #   聚合根行为测试（无 Mock）
│   │   │   ├── item.go                     #   实体/值对象 (OrderItem, Money)
│   │   │   ├── status.go                   #   值对象/枚举 (OrderStatus)
│   │   │   ├── repository.go              #   仓储接口定义 (OrderRepository)
│   │   │   ├── service.go                  #   领域服务（跨实体业务逻辑）
│   │   │   ├── events.go                   #   领域事件定义 (OrderCreated, OrderPaid)
│   │   │   └── errors.go                   #   领域错误类型 (ErrInsufficientStock)
│   │   │
│   │   ├── app/                            # 应用层 — 用例编排，不含核心业务逻辑
│   │   │   ├── command.go                  #   写命令定义 + Handler（CreateOrder, PayOrder）
│   │   │   ├── query.go                    #   读查询定义 + Handler（GetOrderDetail）
│   │   │   └── dto.go                      #   应用层 DTO（请求/响应结构体）
│   │   │
│   │   └── adapter/                        # 适配器层 — 域专属的外部世界翻译器
│   │       ├── postgres_repo.go            #   仓储接口的 PostgreSQL 实现
│   │       ├── postgres_repo_test.go       #   集成测试（需真实 DB）
│   │       ├── model.go                    #   持久化模型（含 DB 标签，严禁泄漏到 domain）
│   │       ├── converter.go               #   model ↔ domain 双向转换器（防腐层）
│   │       ├── http_handler.go             #   HTTP 路由处理器
│   │       ├── grpc_handler.go             #   gRPC 服务实现
│   │       └── acl_legacy_payment.go       #   防腐层：对接外部遗留支付系统
│   │
│   ├── inventory/                          # ===== 限界上下文：库存 =====
│   │   ├── CONTEXT.md
│   │   ├── domain/
│   │   │   ├── stock.go
│   │   │   ├── stock_test.go
│   │   │   ├── repository.go
│   │   │   ├── events.go
│   │   │   └── errors.go
│   │   ├── app/
│   │   │   ├── command.go
│   │   │   └── query.go
│   │   └── adapter/
│   │       ├── postgres_repo.go
│   │       ├── model.go
│   │       ├── converter.go
│   │       └── http_handler.go
│   │
│   │  ┌─────────────────────────────────────────────────────────┐
│   │  │                     全局共享与基础设施                      │
│   │  └─────────────────────────────────────────────────────────┘
│   │
│   ├── shared/                             # 共享内核 — 零第三方依赖的纯净公共类型
│   │   ├── id.go                           #   强类型 ID（OrderID, UserID）
│   │   ├── money.go                        #   公共值对象（Money, Currency）
│   │   ├── event.go                        #   DomainEvent 接口定义
│   │   └── errors.go                       #   全局错误基础类型（AppError, NotFoundError）
│   │
│   └── infra/                              # 全局基础设施 — 纯技术底座，跨域复用
│       ├── config/
│       │   └── config.go                   #   配置解析为强类型结构体
│       ├── db/
│       │   ├── postgres.go                 #   连接池初始化
│       │   └── tx.go                       #   通用事务闭包封装
│       ├── cache/
│       │   └── redis.go                    #   Redis 客户端初始化
│       ├── eventbus/
│       │   └── bus.go                      #   进程内事件总线（领域事件分发）
│       └── middleware/
│           ├── logging.go                  #   请求日志
│           └── auth.go                     #   认证中间件
│
├── pkg/                                    # ⚠️ 谨慎使用：仅当工具函数需跨仓库复用
│   └── httputil/
│       └── response.go
│
├── deploy/                                 # 部署编排
│   ├── Dockerfile
│   └── k8s/
│       └── deployment.yaml
│
├── docs/
│   └── ddd/                                # DDD 设计产物（由 DDD Pipeline 生成）
│       ├── phase-1-domain-events.md
│       ├── phase-2-context-map.md
│       ├── phase-3-contracts.md
│       └── decisions-log.md
│
│  ┌────────────────────────────────────────────────────────────────┐
│  │                   AI Agent 约束文件（自动生成）                   │
│  └────────────────────────────────────────────────────────────────┘
│
├── .cursor/rules/                          # Cursor IDE 约束
│   ├── order.mdc                           #   订单上下文：术语表 + 允许/禁止导入规则
│   └── inventory.mdc                       #   库存上下文
├── .claude/rules/                          # Claude Code 约束
│   ├── order.md
│   └── inventory.md
│
├── CLAUDE.md                               # AI Agent 全局知识入口
├── go.mod
└── go.sum
```

### 目录设计决策说明

| 设计决策                 | 选择                                | 理由                                                  |
| :----------------------- | :---------------------------------- | :---------------------------------------------------- |
| 域内适配器目录名         | `adapter/`（单数）                  | Go 惯用命名，避免与"设计模式"概念混淆                 |
| 域的 handler 放哪        | `adapter/http_handler.go`           | 保持域自包含，Agent 不需跨目录查找路由                |
| 全局 infra vs 域 adapter | 分离                                | infra 管"管道建设"，adapter 管"接水过滤"              |
| domain/ 内部结构         | **扁平** — 不设 entity/, vo/ 子目录 | 避免包名口吃（`entity.Order`）和同域循环依赖          |
| 测试文件位置             | 与源文件同目录 `_test.go`           | Go 惯用法 + AI 读取时自然获得测试上下文               |
| 共享内核目录名           | `shared/` 而非 `pkg/`               | 语义清晰：shared = DDD 共享内核；pkg = 外部可导入 SDK |

---

## 三、AI 知识文件体系：Agent 的结构化 Prompt

> 这是本蓝图与传统 Go 项目 Layout 最根本的差异。
> **每个限界上下文目录下必须包含一个 `CONTEXT.md` 文件。**

### 3.1 CONTEXT.md 模板

```markdown
# 订单上下文（Order Context）

## 领域概览
订单上下文负责管理从创建到完成的完整订单生命周期。
核心职责：订单创建、支付确认、状态流转、取消与退款。

## 统一语言（Ubiquitous Language）

| 中文术语 | 英文术语    | 定义                   | ⛔ 禁用同义词          |
| :------- | :---------- | :--------------------- | :-------------------- |
| 订单     | Order       | 一次完整的购买交易记录 | Purchase, Transaction |
| 订单项   | OrderItem   | 订单中的单个商品条目   | LineItem, CartItem    |
| 订单状态 | OrderStatus | 订单的生命周期状态枚举 | State, Phase          |
| 支付     | Payment     | 订单关联的资金支付行为 | Charge, Billing       |

## 聚合根
- **Order**（订单）：聚合根，包含 OrderItem 集合

## 领域事件
- `OrderCreated` — 订单被创建
- `OrderPaid` — 订单支付成功
- `OrderCancelled` — 订单被取消

## 业务不变量（Invariants）
1. 订单创建时，至少包含一个 OrderItem
2. 已支付的订单不可再次支付
3. 已发货的订单不可取消
4. 订单总金额 = Σ(Item 单价 × 数量)

## 依赖边界
- **允许导入**：`internal/shared/`
- **严禁导入**：任何其他 `internal/{context}/` 包
- **跨域通信**：通过领域事件 或 应用层 ID 引用
```

### 3.2 为什么 CONTEXT.md 是架构级创新

| 传统做法                | AI 原生做法           | AI Agent 收益                          |
| :---------------------- | :-------------------- | :------------------------------------- |
| 业务规则藏在代码注释中  | `CONTEXT.md` 集中声明 | Agent 无需解析全量代码即可理解业务     |
| 术语靠团队口头约定      | 统一语言表 + 禁用词   | 彻底消除生成代码中的词汇漂移           |
| 不变量散落在 if/else 中 | Invariants 显式列出   | Agent 生成的构造函数、方法自动包含校验 |
| 依赖关系靠架构师口述    | 依赖边界白纸黑字      | Agent 不会生成违反依赖方向的 import    |

### 3.3 Constraint Files：AI 工具链的硬约束

CONTEXT.md 面向通用理解，而 Constraint Files 面向特定 AI 工具的运行时约束注入。

**示例：`.cursor/rules/order.mdc`**
```yaml
---
description: 订单限界上下文的代码生成约束
globs: ["internal/order/**/*"]
---

# 订单上下文约束

## 术语强制
- 涉及购买交易，必须使用 `Order`，禁止 `Purchase`、`Transaction`
- 涉及交易条目，必须使用 `OrderItem`，禁止 `LineItem`

## 依赖规则
- domain/ 下的文件禁止 import 任何 `internal/order/adapter/` 或 `internal/infra/` 包
- domain/ 下的文件仅允许 import `internal/shared/` 和标准库

## 代码风格
- 实体字段全部小写未导出，通过构造函数 + 行为方法暴露
- 禁止生成 SetXxx() 公共方法
- 值对象使用值接收器（Value Receiver）
- 聚合根使用指针接收器（Pointer Receiver）
```

---

## 四、层间依赖规则与数据流

### 4.1 依赖方向：向内收敛

```
                    ┌──────────────────────┐
                    │     cmd/api/main.go  │  引导层（组装、启动）
                    └──────────┬───────────┘
                               │ 注入
          ┌────────────────────┼────────────────────┐
          ▼                    ▼                    ▼
   ┌─────────────┐    ┌──────────────┐     ┌──────────────┐
   │  adapter/    │    │  adapter/    │     │  adapter/    │
   │  http_handler│    │  postgres_   │     │  grpc_       │
   │              │    │  repo        │     │  handler     │
   └──────┬───┬──┘    └──────┬───────┘     └──────┬───────┘
          │   │              │                    │
          │   └──────┐       │  实现接口           │
          │          ▼       ▼                    │
          │    ┌──────────────────┐               │
          └───►│    app/          │◄──────────────┘
               │  command.go     │   应用层：编排用例
               │  query.go       │
               └────────┬────────┘
                        │ 调用领域方法
                        ▼
               ┌──────────────────┐
               │    domain/       │   领域层：纯业务逻辑
               │  order.go        │   ⛔ 零外部依赖
               │  repository.go   │   （接口定义在此）
               │  events.go       │
               └──────────────────┘
                        │ 仅允许导入
                        ▼
               ┌──────────────────┐
               │    shared/       │   共享内核：纯值类型
               └──────────────────┘
```

**铁律**：
1. `domain/` **绝对禁止** import `app/`、`adapter/`、`infra/` 的任何包
2. `app/` 可以 import `domain/`（调用领域对象和接口）
3. `adapter/` 可以 import `domain/`（实现接口）和 `app/`（路由注入）和 `infra/`（使用基础设施）
4. 跨域通信 **只通过** 领域事件 或 Application 层显式编排，**禁止** 域 A 的 domain 直接 import 域 B 的 domain

### 4.2 错误处理跨层流

原文档未覆盖的关键话题。三层各自持有不同语义的错误：

```go
// ===== domain/errors.go =====
// 领域层：表达业务语义，零技术细节
var (
    ErrOrderNotFound      = errors.New("order not found")
    ErrAlreadyPaid        = errors.New("order already paid")
    ErrInsufficientStock  = errors.New("insufficient stock")
)

// 复杂场景可使用自定义错误类型携带领域上下文
type ValidationError struct {
    Field   string
    Message string
}

// ===== app/command.go =====
// 应用层：包装领域错误，添加用例上下文，不暴露技术细节
func (h *PayOrderHandler) Handle(ctx context.Context, cmd PayOrder) error {
    err := h.repo.Update(ctx, cmd.OrderID, func(o *domain.Order) error {
        return o.Pay()  // 领域方法返回领域错误
    })
    if err != nil {
        return fmt.Errorf("pay order %s: %w", cmd.OrderID, err)  // 包装，保留链
    }
    return nil
}

// ===== adapter/http_handler.go =====
// 适配器层：翻译为 HTTP 语义，是错误的最终归宿
func (h *OrderHandler) PayOrder(w http.ResponseWriter, r *http.Request) {
    err := h.payCmd.Handle(r.Context(), cmd)
    switch {
    case errors.Is(err, domain.ErrOrderNotFound):
        http.Error(w, "order not found", http.StatusNotFound)
    case errors.Is(err, domain.ErrAlreadyPaid):
        http.Error(w, "order already paid", http.StatusConflict)
    default:
        http.Error(w, "internal error", http.StatusInternalServerError)
    }
}
```

**原则**：领域层定义"是什么错了"，应用层添加"在做什么时出错了"，适配器层决定"如何告知外部世界"。

---

## 五、战术 DDD 在 Go 中的落地规范

### 5.1 实体与聚合根：构造函数守护不变量

```go
// domain/order.go — 聚合根

// Order 是订单聚合根。所有字段未导出，只能通过构造函数创建。
type Order struct {
    id        OrderID
    buyerID   UserID
    items     []OrderItem
    status    OrderStatus
    total     Money
    events    []DomainEvent  // 内部事件收集器
    createdAt time.Time
}

// NewOrder 是唯一合法的创建路径。校验所有不变量。
func NewOrder(id OrderID, buyerID UserID, items []OrderItem) (*Order, error) {
    if len(items) == 0 {
        return nil, ErrEmptyOrder
    }
    total := calculateTotal(items)
    o := &Order{
        id:        id,
        buyerID:   buyerID,
        items:     items,
        status:    StatusPending,
        total:     total,
        createdAt: time.Now(),
    }
    o.record(OrderCreated{OrderID: id, BuyerID: buyerID, Total: total})
    return o, nil
}

// MustNewOrder 用于测试脚手架，参数无效时 panic。
func MustNewOrder(id OrderID, buyerID UserID, items []OrderItem) *Order {
    o, err := NewOrder(id, buyerID, items)
    if err != nil {
        panic(err)
    }
    return o
}

// Pay 是行为方法，封装支付的业务规则。
func (o *Order) Pay() error {
    if o.status != StatusPending {
        return ErrAlreadyPaid
    }
    o.status = StatusPaid
    o.record(OrderPaid{OrderID: o.id})
    return nil
}

// record 收集领域事件，事务提交前由基础设施层提取分发。
func (o *Order) record(event DomainEvent) {
    o.events = append(o.events, event)
}

// PullEvents 提取并清空内部事件（仅供基础设施层调用）。
func (o *Order) PullEvents() []DomainEvent {
    events := o.events
    o.events = nil
    return events
}
```

### 5.2 值对象：值接收器保证不可变性

```go
// domain/item.go — 值对象

// Money 是金额值对象。使用值接收器，保证不可变性。
type Money struct {
    amount   int64    // 最小货币单位（分）
    currency string
}

func NewMoney(amount int64, currency string) (Money, error) {
    if amount < 0 {
        return Money{}, errors.New("amount cannot be negative")
    }
    if currency == "" {
        return Money{}, errors.New("currency is required")
    }
    return Money{amount: amount, currency: currency}, nil
}

// Add 返回新的 Money 实例，不修改原对象 — 并发安全。
func (m Money) Add(other Money) (Money, error) {
    if m.currency != other.currency {
        return Money{}, errors.New("currency mismatch")
    }
    return Money{amount: m.amount + other.amount, currency: m.currency}, nil
}
```

### 5.3 仓储模式：闭包事务

```go
// domain/repository.go — 仓储接口定义在领域层

type OrderRepository interface {
    // FindByID 查询订单（读路径使用）。
    FindByID(ctx context.Context, id OrderID) (*Order, error)

    // Update 通过闭包封装事务：
    //   1. 开启事务 + 行锁
    //   2. 加载聚合根
    //   3. 执行 updateFn（纯业务逻辑）
    //   4. 持久化 + 提交/回滚
    // 应用层完全不感知底层是 PostgreSQL 还是 MongoDB。
    Update(ctx context.Context, id OrderID, updateFn func(order *Order) error) error
}
```

### 5.4 领域服务：跨实体逻辑的归属地

> 原文档强调"胖实体"但缺少对领域服务的定位。当业务逻辑 **天然不属于** 任何单一实体时，使用领域服务。

```go
// domain/service.go — 领域服务

// PricingService 计算订单价格，涉及折扣规则、促销策略等跨实体逻辑。
// 它仍然是纯领域逻辑，零外部依赖。
type PricingService struct{}

func (s PricingService) CalculateDiscount(order *Order, membership MembershipLevel) Money {
    // 跨越 Order 和 Membership 两个概念的业务规则
    // 这段逻辑不属于 Order 也不属于 Membership
    if membership == MembershipGold && order.Total().Amount() > 10000 {
        return order.Total().Multiply(0.1) // 金牌会员满100打9折
    }
    return NewMoneyZero(order.Total().Currency())
}
```

**判断法则**：
- 逻辑修改的是单个聚合的内部状态 → **放在聚合方法上**
- 逻辑需要多个聚合/值对象协作但不修改状态 → **领域服务**
- 逻辑需要外部 I/O（发邮件、调 API）→ **应用层 Handler**

### 5.5 跨聚合事务：Unit of Work 模式

> 原文档的闭包事务模式在单聚合场景下优雅，但跨聚合时力不从心。

```go
// infra/db/tx.go — 全局事务管理器

// UnitOfWork 封装跨聚合的事务边界。
type UnitOfWork struct {
    db *sql.DB
}

// Execute 在同一个数据库事务中执行闭包。
// 闭包内可通过 tx 创建带事务的仓储实现。
func (uow *UnitOfWork) Execute(ctx context.Context, fn func(tx *sql.Tx) error) error {
    tx, err := uow.db.BeginTx(ctx, nil)
    if err != nil {
        return err
    }
    if err := fn(tx); err != nil {
        _ = tx.Rollback()
        return err
    }
    return tx.Commit()
}
```

```go
// app/command.go — 应用层使用 UnitOfWork 协调多聚合

func (h *PlaceOrderHandler) Handle(ctx context.Context, cmd PlaceOrder) error {
    return h.uow.Execute(ctx, func(tx *sql.Tx) error {
        // 1. 扣减库存（聚合 A）
        stockRepo := h.stockRepoFactory(tx)
        err := stockRepo.Update(ctx, cmd.ProductID, func(s *inventory.Stock) error {
            return s.Deduct(cmd.Quantity)
        })
        if err != nil {
            return err
        }

        // 2. 创建订单（聚合 B）
        order, err := domain.NewOrder(cmd.OrderID, cmd.BuyerID, cmd.Items)
        if err != nil {
            return err
        }
        orderRepo := h.orderRepoFactory(tx)
        return orderRepo.Save(ctx, order)
    })
}
```

> **注意**：跨聚合事务应尽量避免。DDD 推荐的首选方案是通过 **领域事件 + 最终一致性** 解耦。只有在强一致性要求下才使用 UnitOfWork。

### 5.6 CQRS：读写路径彻底分离

```go
// app/command.go — 写路径

type PayOrder struct {
    OrderID string
}

type PayOrderHandler struct {
    repo domain.OrderRepository
}

func (h *PayOrderHandler) Handle(ctx context.Context, cmd PayOrder) error {
    return h.repo.Update(ctx, domain.OrderID(cmd.OrderID), func(o *domain.Order) error {
        return o.Pay()  // 所有决策权在领域层
    })
}
```

```go
// app/query.go — 读路径

type GetOrderDetail struct {
    OrderID string
}

type OrderDetailView struct {
    ID         string
    Status     string
    Items      []OrderItemView
    TotalPrice int64
}

// OrderReadModel 读模型接口，实现在 adapter 层，可直接 SQL JOIN 优化
type OrderReadModel interface {
    GetOrderDetail(ctx context.Context, id string) (*OrderDetailView, error)
}

type GetOrderDetailHandler struct {
    readModel OrderReadModel  // 完全绕过领域模型，直达数据库读取
}

func (h *GetOrderDetailHandler) Handle(ctx context.Context, q GetOrderDetail) (*OrderDetailView, error) {
    return h.readModel.GetOrderDetail(ctx, q.OrderID)
}
```

```go
// 全局 Application 容器 — 统一注册所有 Command/Query Handler

type Application struct {
    Commands Commands
    Queries  Queries
}

type Commands struct {
    CreateOrder *CreateOrderHandler
    PayOrder    *PayOrderHandler
}

type Queries struct {
    GetOrderDetail *GetOrderDetailHandler
    ListOrders     *ListOrdersHandler
}
```

### 5.7 适配器中的防腐层：持久化模型隔离

```go
// adapter/model.go — 持久化模型，允许 DB 标签
type orderModel struct {
    ID        string `db:"id"`
    BuyerID   string `db:"buyer_id"`
    Status    int    `db:"status"`
    Total     int64  `db:"total_amount"`
    Currency  string `db:"currency"`
    CreatedAt time.Time `db:"created_at"`
}

// adapter/converter.go — 模型与领域对象的双向转换（防腐层）
func toDomain(m *orderModel) (*domain.Order, error) {
    // 从数据库模型重建领域对象
    return domain.ReconstructOrder(
        domain.OrderID(m.ID),
        shared.UserID(m.BuyerID),
        domain.OrderStatus(m.Status),
        // ... 
    )
}

func toModel(o *domain.Order) *orderModel {
    return &orderModel{
        ID:       string(o.ID()),
        BuyerID:  string(o.BuyerID()),
        Status:   int(o.Status()),
        Total:    o.Total().Amount(),
        Currency: o.Total().Currency(),
    }
}
```

---

## 六、AI Agent 工作流适配

### 6.1 TDD as Guardrail：测试是 AI 的"电子围栏"

```
人类开发者                             AI Agent
    │                                    │
    ├── 编写 domain/*_test.go ──────────►│
    │   (反映业务契约的测试断言)            │
    │                                    │
    │◄── 生成 domain/*.go ──────────────┤
    │   (在纯净沙盒中实现，使测试变绿)      │
    │                                    │
    ├── 审核 domain 代码 + 补充边界测试 ──►│
    │                                    │
    │◄── 生成 adapter/*.go ─────────────┤
    │   (实现仓储、Handler)               │
    │                                    │
    ├── 集成测试验证 ─────────────────────┤
```

**为什么 DDD 的纯净领域层是 TDD 的天然盟友**：
- `domain/` 零外部依赖 → 测试不需要 Mock 任何东西
- 测试就是"业务规则的可执行文档"
- AI 在这个沙盒中生成代码，**不可能** 意外引入数据库查询或 HTTP 调用——编译器会直接拒绝

### 6.2 隔离式渐进生成：分层向 AI 要代码

严禁让 AI 一次性生成全栈代码。按以下顺序逐层生成：

| 步骤 | 生成目标                                                 | AI 上下文输入           | 质量校验                              |
| :--- | :------------------------------------------------------- | :---------------------- | :------------------------------------ |
| ①    | `domain/*.go`                                            | CONTEXT.md + 测试文件   | `go test ./internal/order/domain/...` |
| ②    | `app/command.go` + `app/query.go`                        | domain 层代码           | 编译通过 + 逻辑审查                   |
| ③    | `adapter/postgres_repo.go` + `model.go` + `converter.go` | domain 接口 + DB schema | 集成测试                              |
| ④    | `adapter/http_handler.go`                                | app 层 + OpenAPI spec   | E2E 测试                              |

每一步的输出成为下一步的输入上下文。**不可跳步、不可并行。**

### 6.3 模块化单体：AI Agent 的最优运行环境

| 特征       | 微服务               | 模块化单体                | AI Agent 影响                         |
| :--------- | :------------------- | :------------------------ | :------------------------------------ |
| 代码位置   | 分散多仓库           | 单仓库 `internal/`        | 单仓库 = Agent 可读取全量代码         |
| 跨域通信   | HTTP/gRPC 网络调用   | 进程内函数调用/事件总线   | 无网络 = 消除 Agent 对 API 契约的幻觉 |
| 部署复杂度 | 高（K8s 编排多服务） | 低（单二进制部署）        | 简单部署 = Agent 可端到端验证         |
| 边界保护   | 网络隔离             | Go `internal/` 编译器隔离 | 编译器 = 比 Agent 更可靠的约束        |

**推荐**：除非有明确的独立扩缩容需求，所有限界上下文部署为**模块化单体**，以 `internal/{context}/` 包隔离取代微服务的网络隔离。未来需要拆分时，按特性域目录直接提取——垂直切片的布局使得 "单体 → 微服务" 的迁移代价极低。

---

## 七、架构守护清单

### 7.1 Quick Check

- [ ] `domain/` 包内是否有 import `adapter/`、`infra/` 或第三方库的语句？（≠ 标准库和 `shared/`）
- [ ] 实体是否通过构造函数创建？是否存在 `SetXxx()` 公共方法？
- [ ] 值对象方法是否使用值接收器？
- [ ] 仓储接口是否定义在 `domain/` 包内？
- [ ] `adapter/model.go` 中的 DB 标签是否泄漏到了 `domain/` 层的结构体上？
- [ ] 每个限界上下文目录下是否有 `CONTEXT.md`？
- [ ] 目录嵌套是否超过 3 层？
- [ ] `_test.go` 是否与源文件在同一目录？
- [ ] 跨域是否通过直接 import 而不是事件/ID 引用？
- [ ] AI 约束文件（`.cursor/rules/`、`.claude/rules/`）是否与上下文保持同步？

### 7.2 Linter Rules（建议 CI 配置）

```yaml
# .golangci.yml 示例片段
linters-settings:
  depguard:
    rules:
      domain-isolation:
        # domain 包禁止导入 adapter、infra、第三方框架
        files: ["**/domain/**"]
        deny:
          - pkg: "database/sql"
          - pkg: "net/http"
          - pkg: "gorm.io/**"
          - pkg: "github.com/gin-gonic/**"
          - pkg: "**/adapter/**"
          - pkg: "**/infra/**"
```

---

## 八、与原文档的关键差异对照

| 维度          | 原文档                   | 本蓝图                                          |
| :------------ | :----------------------- | :---------------------------------------------- |
| AI 设计的权重 | 最后一节简要提及         | **核心设计轴** — 贯穿全文                       |
| 知识文件体系  | 提及 README.md、rules.md | 定义完整的 `CONTEXT.md` 模板 + Constraint Files |
| 错误处理      | 未覆盖                   | 提供三层错误流完整方案                          |
| 领域服务      | 未提及                   | 明确定义使用场景和判断法则                      |
| 跨聚合事务    | 仅有闭包模式             | 补充 UnitOfWork + 最终一致性建议                |
| CQRS          | 概念描述                 | 提供完整 Go 代码示例                            |
| Handler 归属  | 未明确                   | HTTP/gRPC Handler 放入域 `adapter/` 实现自包含  |
| 工作流        | 未涉及                   | 提供"隔离式渐进生成"四步法                      |
| 架构守护      | 依赖规则文字描述         | 提供 CI lint 配置 + 可执行清单                  |

---

> **后续待完善**：
> - [ ] 领域事件的进程内分发实现（EventBus）详细代码
> - [ ] `cmd/api/main.go` 完整的 DI 组装示例
> - [ ] 多限界上下文之间通过事件总线通信的完整 E2E 示例
> - [ ] Constraint Files 自动生成脚本（从 CONTEXT.md → .cursor/rules/）

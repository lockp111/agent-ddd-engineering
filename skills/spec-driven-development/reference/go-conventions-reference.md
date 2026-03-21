# Go 项目 DDD 惯用约定参考

> 本文档是 Go 语言 DDD 惯用约定参考。不改变 DDD 架构原则（六边形架构、充血模型、ACL 防腐层）。

---

## 四层架构总览

```
server → app → domain ← infra
                 ↑
             kernel（被所有层合法依赖）
```

| 架构层 | 目录 | 核心职责 |
|:-------|:-----|:---------|
| **传输层** | `internal/server/` | 协议转换（HTTP/gRPC），简单 struct，参数校验。不含业务规则 |
| **应用层** | `internal/app/` | 用例编排，CQRS Command/Query handlers，事务边界。不含业务规则 |
| **领域层** | `internal/domain/` | 聚合根、实体、值对象、领域事件、仓储接口——纯业务逻辑，不导入 infra/app/server 层包 |
| **基础设施层** | `internal/infra/` | DB 适配器、缓存、ORM 模型、ACL 防腐层 |

横切目录：

| 目录 | 职责 |
|:-----|:-----|
| `internal/config/` | 配置结构体（全局共用） |
| `internal/kernel/` | 跨域类型（UserID、Money、DomainEvent），零三方依赖。域专属 ID 在各自 domain/ 包 |

---

## 约定 1: `internal/` — 编译器强制隔离

所有业务代码放在 `internal/`，外部模块无法导入。跨仓库共享 SDK 仅在必须时放 `pkg/`。

---

## 约定 2: 分层包结构 — 不超过 3 层

`internal/domain/order/` 为 3 层，是合理上限。不要出现 `adapter/persistence/repository/` 式的四五层嵌套。

| 示例路径 | 层数 |
|:---|:---|
| `internal/domain/order/` | 3 层 |
| `internal/infra/postgres/` | 3 层 |
| `internal/infra/query/` | 3 层 |

---

## 约定 3: 测试文件 — 同目录，不分离

`_test.go` 与源文件放在**同一目录**。不建 `tests/` 子目录。

两种合法包名：
- `package order`：白盒测试（可访问未导出字段）
- `package order_test`：黑盒测试（推荐用于聚合根行为测试）

```
internal/domain/order/
├── order.go
├── order_test.go
├── events.go
└── repository.go
```

**集成测试 — `integration/`：**

根目录下的 `integration/` 目录用于集成测试，启动完整服务栈进行测试。

```
integration/
├── docker-compose.yml          # 测试依赖（数据库、缓存等）
├── main_test.go              # TestMain: 启动测试依赖
└── order_test.go             # 功能集成测试
```

---

## 约定 4: 接口定义在消费方

Go 接口隐式满足。**接口在使用它的包中定义**，不需要 `port/` 目录。

```
internal/domain/order/repository.go       # 定义 Repository 接口
internal/infra/postgres/order_repo.go     # 实现接口（隐式满足）
```

```go
// internal/domain/order/repository.go
type Repository interface {
    FindByID(ctx context.Context, id OrderID) (*Order, error)
    Save(ctx context.Context, order *Order) error
}
```

---

## 约定 5: 适配器按技术命名

基础设施目录按**技术**命名，不按角色命名。

| 目录 | 说明 |
|:---|:---|
| `infra/postgres/` | 实现 `domain/` 的 Repository 接口 |
| `infra/redis/` | 缓存适配器 |
| `infra/acl/` | 防腐层（外部/遗留系统翻译器） |
| `infra/model/` | ORM 持久化模型 |
| `infra/query/` | 类型安全查询（使用 sqlx 或生成） |
| `server/` | 传输层（HTTP Handler/gRPC Server） |

---

## 约定 6: 不重复包名（Stuttering）

类型名不重复包名。

| 惯用 | 调用方写法 |
|:---|:---|
| `order.Service` | `order.Service{}` |
| `order.Repository` | `order.Repository{}` |
| `payment.Gateway` | `payment.Gateway{}` |

---

## 约定 7: Kernel 跨域共享 — `internal/kernel/` + `pkg/`

**服务内跨域类型**放 `internal/kernel/`，**跨仓库共享**用 `pkg/`。

`internal/kernel/` 规则：
- 只放**真正跨域**的基础类型：`UserID`（跨多个BC引用）、基础值对象（`Money`、`Currency`）、`DomainEvent` 接口
- 域专属 ID（如 `OrderID`、`PaymentID`）定义在各自 `domain/<context>/` 包内，不放 kernel
- **零三方依赖**——仅依赖 Go 标准库
- 不放业务逻辑

`pkg/` 规则：
- 仅当确信需要跨仓库复用时才放置
- 多数服务不需要 `pkg/`

---

## 约定 8: 领域层扁平化

`domain/<context>/` 包内**不分** `entity/`、`valobj/`、`service/` 子目录。所有概念平铺在同一包内。

原因：
- 避免包名口吃（`entity.Order`）
- 避免同域内循环依赖
- 降低认知负担，AI Agent 单文件夹即可读取完整上下文

```
internal/domain/order/          # 扁平！无子目录
├── order.go                    # 聚合根 + NewOrder() 构造函数
├── item.go                     # 子实体 OrderItem
├── status.go                   # 值对象 OrderStatus（value receiver）
├── repository.go               # 仓储接口定义
├── events.go                   # 领域事件
├── service.go                  # 领域服务（跨实体协调，可选）
└── order_test.go               # 纯单元测试（零外部依赖）
```

---

## 约定 9: CQRS 读写分文件

`app/` 层按 Command（写）和 Query（读）分文件：

```
internal/app/
├── order_cmd.go                # Command: CreateOrder, CancelOrder, ShipOrder
├── order_query.go             # Query: GetOrderDetail, ListOrders
└── payment.go                 # 支付用例编排
```

- **Command handlers** 必须走完整 domain 路径（加载聚合 → 调用行为方法 → 持久化）
- **Query handlers** 可绕过 domain 直接调用 `infra/` 读取优化查询，无需加载聚合根
- Handler 本身**不含业务规则**，所有决策在 domain 层

**App 层组织：起步扁平，膨胀了再拆**

```go
// 起步：全部放 app/
app/
├── order.go
├── payment.go

// 等真的膨胀了再按 domain 分包
app/
├── order_cmd.go
├── order_query.go
└── order/
    └── workflow.go
```

---

## 约定 10: 持久化模型防腐

ORM 生成的 Model 放在 `infra/model/`，**禁止出现在 `domain/` 层**。

`infra/` 适配器必须包含 `converter.go` 做 Model ↔ Domain Entity 双向映射：

```go
// internal/infra/postgres/converter.go
package postgres

import (
    "myservice/internal/domain/order"
    "myservice/internal/infra/model"
)

func toEntity(m *model.Order) *order.Order {
    return order.Reconstruct(  // 用重建函数，不绕过构造函数
        order.OrderID(m.ID),
        order.MustNewStatus(m.Status),
        m.CreatedAt,
    )
}

func toModel(e *order.Order) *model.Order {
    return &model.Order{
        ID:        int64(e.ID()),
        Status:    e.Status().String(),
        CreatedAt: e.CreatedAt(),
    }
}
```

**这就是微观层面的防腐层（ACL）**——阻断 ORM 标签向 domain 层的渗透。

---

## 约定 11: 核心域 vs 支撑域分级

| 域分类 | domain/ 层做法 | infra/ 层做法 |
|:-------|:---------------|:--------------|
| **核心域** | 完整充血模型（行为方法、业务校验、构造函数） | converter.go 做 Model ↔ Entity 映射 |
| **支撑域 / 简单 CRUD** | 可直接引用 `infra/model/` 结构体作为数据载体 | 无需额外映射 |

判定标准：如果该域包含需要保护的业务不变量（invariants），它就是核心域，必须走完整充血模型路径。

---

## 约定 12: 错误处理 — 标准 errors 包 + 自定义错误

使用标准 `errors` 包 + `fmt.Errorf` + 自定义错误类型。

错误构造方式：

| 层 | 推荐用法 | 说明 |
|:--|:--------|:-----|
| `domain/` | `errors.New(msg)` / `fmt.Errorf("...: %w", err)` | 定义和传播域错误 |
| `app/` | 自定义错误类型 + `errors.Is`/`errors.As` | 包装为面向调用方的错误 |
| `infra/` | `fmt.Errorf("db: %w", err)` | 包装基础设施错误，添加上下文 |

示例：

```go
// internal/domain/order/errors.go
var (
    ErrOrderNotFound     = errors.New("order not found")
    ErrInvalidOrderState = errors.New("invalid order state")
    ErrOrderTooOld       = errors.New("order too old to cancel")
)

// internal/app/order/errors.go
type OrderNotFoundError struct {
    OrderID order.OrderID
}

func (e *OrderNotFoundError) Error() string {
    return fmt.Sprintf("order %s not found", e.OrderID)
}
```

**关键规则：自定义错误类型用于需要程序化判断的错误（业务错误），普通错误用标准 errors。**

---

## 约定 13: 日志监控 — 结构化日志

使用标准 `log/slog` 或结构化日志库（如 `zerolog`/`zap`）。

推荐使用 slog（Go 1.21+ 标准库）：

| 函数 | 用途 |
|:----|:-----|
| `slog.Info("message", "key", value)` | 一般信息 |
| `slog.Warn("message", "key", value)` | 警告 |
| `slog.Error("message", "key", value)` | 错误 |
| `slog.Debug("message", "key", value)` | 调试（生产环境通常关闭） |

**关键规则：日志应包含结构化字段，便于查询和监控。不要使用字符串拼接方式记录日志。**

---

## 约定 14: 配置管理

- `config.yaml` / `config.toml` — 项目根目录，版本控制
- 配置结构体定义在 `internal/config/` 下，全局共用（各层均可注入使用）
- 使用 Viper、Cobra 或标准 JSON/TOML 解析

```
internal/config/
└── config.go    # 配置结构体定义，全局共用
```

---

## 约定 15: DI/组装 — main.go 手动组装

所有依赖在 `cmd/main.go` 中手动创建和注入。可使用 Wire 等 DI 容器，但需遵循以下规则：
- DI 容器仅用于组装，不用于运行时替换
- 接口绑定清晰，避免隐式依赖

```go
// cmd/main.go 模式
func main() {
    cfg := config.Load("config.yaml")

    db, err := postgres.NewDB(cfg.Database)
    if err != nil {
        slog.Error("failed to connect db", "err", err)
        os.Exit(1)
    }

    orderRepo := postgres.NewOrderRepo(db)
    orderSvc := app.NewOrderService(orderRepo)

    httpServer := server.NewHTTPServer(orderSvc)
    // ...
}
```

---

## 约定 16: ORM/数据库访问

统一使用 ORM（gorm、ent）或 sqlx，禁止手写原始 SQL 字符串（动态查询可用 sqlx）。

- DB 连接：标准 `database/sql` + 驱动
- ORM Model → `internal/infra/model/`（持久化模型，infra 层内部）
- 类型安全查询 → `internal/infra/query/`

---

## 约定 17: Middleware 位置

**结论：** `infra/middleware/`

**原因：**
- middleware 本质是基础设施（日志、限流、认证）
- 遵循"按技术命名"约定

**约定：**
- Middleware 必须保持薄，只做协议层的事
- 禁止在 middleware 里写业务逻辑
- 如需业务逻辑：注入接口依赖，或把逻辑放到 `app/` 层

```go
infra/middleware/
├── auth.go       // 只解析token，注入 TokenValidator 接口
├── logging.go
└── ratelimit.go
```

---

## 约定 18: `tools.go` 钉住远端依赖

项目根目录（与 `go.mod` 同级）放 `tools.go`，用 `//go:build tools` + blank import 钉住远端依赖（如代码生成工具）。防止 `go mod tidy` 在 adapter 代码写完前移除依赖。

```go
//go:build tools

package tools

import (
    _ "github.com/sqlc-dev/sqlc/cmd/sqlc"
)
```

---

## 依赖方向

**`domain` 包零基础设施导入。**

```
server → app → domain ← infra
```

- `infra/` 导入 `domain/`（实现其定义的接口）
- `domain/` **不得**导入 `infra/`、`server/`、`app/` 层包（架构层依赖约束）
- `app/` 编排用例，导入 `domain/` 的接口，不含业务规则

```go
// internal/infra/postgres/order_repo.go
package postgres

import "myservice/internal/domain/order"  // infra 导入 domain，不是反过来

type OrderRepo struct{ db *sql.DB }

func (r *OrderRepo) FindByID(ctx context.Context, id order.OrderID) (*order.Order, error) {
    // 1. 查询 DB
    // 2. converter.toEntity() 转换为域实体
    // 3. 返回
}
```

---

## 完整 Go 项目目录树

```
myservice/
├── cmd/
│   ├── main.go                          # 服务入口
│   └── tools/                           # 代码生成工具
│
├── config.yaml                          # 配置文件（版本控制）
│
├── internal/
│   ├── config/                          # 配置结构体（全局共用）
│   │   └── config.go
│   │
│   ├── kernel/                          # 共享内核（零三方依赖）
│   │   ├── types.go                     #   UserID, Money, Currency, DomainEvent
│   │   └── errors.go                    #   跨域业务错误枚举
│   │
│   ├── domain/                          # 领域层（按限界上下文分包，包内扁平）
│   │   ├── order/                       #   BC: 订单
│   │   │   ├── order.go                 #     聚合根 + NewOrder() 构造函数
│   │   │   ├── item.go                  #     子实体 OrderItem
│   │   │   ├── status.go                #     值对象 OrderStatus（value receiver）
│   │   │   ├── repository.go            #     仓储接口定义（消费方所有）
│   │   │   ├── events.go                #     领域事件 OrderCreated/OrderPaid
│   │   │   ├── errors.go                #     领域错误定义
│   │   │   ├── service.go               #     领域服务（跨实体协调，可选）
│   │   │   └── order_test.go            #     纯单元测试（零外部依赖）
│   │   │
│   │   └── payment/                     #   BC: 支付
│   │       ├── payment.go
│   │       ├── repository.go
│   │       └── payment_test.go
│   │
│   ├── app/                             # 应用层（CQRS 读写分离）
│   │   ├── order_cmd.go                 #   Command: CreateOrder, CancelOrder
│   │   ├── order_query.go               #   Query: GetOrderDetail, ListOrders
│   │   └── payment.go                   #   支付用例编排
│   │
│   ├── infra/                           # 基础设施层
│   │   ├── model/                       #   ORM 持久化模型
│   │   │   └── order.gen.go
│   │   ├── query/                       #   类型安全查询
│   │   │   └── order.gen.go
│   │   ├── postgres/                    #   PostgreSQL 适配器
│   │   │   ├── order_repo.go            #     实现 domain/order.Repository
│   │   │   ├── payment_repo.go          #     实现 domain/payment.Repository
│   │   │   └── converter.go             #     Model ↔ Entity 映射（微ACL）
│   │   ├── redis/                       #   缓存适配器
│   │   │   └── cache.go
│   │   ├── middleware/                  #   Middleware（保持薄，只做协议层）
│   │   │   ├── auth.go
│   │   │   └── logging.go
│   │   └── acl/                         #   防腐层（外部/遗留系统翻译器）
│   │       └── legacy_user.go
│   │
│   └── server/                          # 传输层
│       ├── order_handler.go             #   HTTP Handler / gRPC Server
│       ├── payment_handler.go
│       └── middleware.go
│
├── pkg/                                 # 跨仓库共享 SDK（谨慎使用）
│
├── integration/                         # 集成测试
│   ├── docker-compose.yml
│   └── order_test.go
│
├── Makefile
├── go.mod
└── go.sum
```

---

## DDD 概念 → Go 映射表

| DDD 概念 | Go 项目中的做法 |
|:---------|:-----------------|
| 限界上下文隔离 | `internal/` 目录（编译器强制） |
| 领域实体/聚合 | `domain/<context>/` 包（扁平，无子目录） |
| 值对象 | `domain/<context>/` 内以 value receiver 实现，不可变 |
| 领域事件 | `domain/<context>/events.go` |
| 领域服务 | `domain/<context>/service.go`（跨实体协调） |
| Port 接口 | 定义在 `domain/<context>/repository.go`（消费方所有） |
| 应用服务（Command） | `app/*_cmd.go`（写路径，走完整 domain） |
| 应用服务（Query） | `app/*_query.go`（读路径，可绕过 domain 直读） |
| 基础设施适配器 | `infra/postgres/`、`infra/redis/`（按技术命名） |
| 防腐层（ACL） | `infra/acl/`（外部系统）+ `infra/postgres/converter.go`（微观 Model 映射） |
| 传输层 | `server/`（HTTP Handler / gRPC Server） |
| 依赖方向 | `server → app → domain ← infra` |
| 单元测试 | `_test.go` 与源文件同目录 |
| 集成测试 | `integration/`（根目录，启动测试依赖） |
| Shared Kernel | `internal/kernel/`（零三方依赖，跨域 UserID/Money/DomainEvent）；域专属 ID 在 `domain/<context>/`；跨仓库时 `pkg/` |
| 包结构深度 | 不超过 3 层嵌套（`internal/domain/order/`） |
| 类型命名 | 不重复包名：`order.Service` |
| 错误模型 | 标准 `errors` 包 + 自定义错误类型 |
| 日志/监控 | `log/slog` 或 `zerolog`/`zap` |
| 配置 | `config.yaml` + `internal/config/` 配置结构体 |
| 启动组装 | `cmd/main.go` 手动组装 |
| 持久化模型 | `internal/infra/model/`（ORM 生成，infra 层内部） |
| 类型安全查询 | `internal/infra/query/`（sqlx 或生成，infra 层内部使用） |

---

## 快速检查清单

**架构层与依赖方向：**

- [ ] `internal/` 顶层是否恰好 6 个目录：`config/`、`kernel/`、`domain/`、`app/`、`infra/`、`server/`？
- [ ] `domain/` 包是否导入了 `infra/`、`server/` 或 `app/` 包？（应禁止）
- [ ] `infra/` 包是否只导入 `domain/` 包？（依赖方向正确）
- [ ] `app/` 包是否不含业务规则？（只做用例编排）

**领域层（约定 4, 6, 8）：**

- [ ] Repository 接口是否定义在 `domain/<context>/` 包内？
- [ ] `domain/<context>/` 内是否有 `entity/`、`valobj/` 子目录？（应禁止，保持扁平）
- [ ] 类型名是否重复了包名（stuttering）？

**基础设施层（约定 5, 10, 16）：**

- [ ] `infra/` 目录是否按技术命名？
- [ ] ORM Model 是否在 `infra/model/`？
- [ ] 核心域适配器是否包含 `converter.go` 做 Model ↔ Entity 映射？
- [ ] ORM Model 是否出现在 `domain/` 层？（应禁止）

**应用层（约定 9）：**

- [ ] `app/` 是否按 `*_cmd.go`/`*_query.go` 分文件？
- [ ] Command handler 是否走完整 domain 路径？
- [ ] Query handler 是否在不需要时仍然加载聚合？（可直读优化）

**共享内核（约定 7）：**

- [ ] `internal/kernel/` 是否有三方依赖？（应为零）
- [ ] 共享类型是否放在 `pkg/` 而不需要跨仓库？（应移入 `internal/kernel/`）

**通用约定：**

- [ ] 错误处理是否使用标准 `errors` 包 + 自定义错误类型？
- [ ] 日志是否使用结构化日志（slog/zerolog/zap）？
- [ ] 配置结构体是否在 `internal/config/` 下且全局共用？
- [ ] `domain/` 是否定义了独立充血模型（而非直接用 ORM Model）？

**`server/` 传输层：**

- [ ] `server/` 是否只做协议转换和参数校验，不含业务逻辑？

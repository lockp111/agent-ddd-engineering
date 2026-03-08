# Go 项目 DDD 惯用约定参考

> 本文档是 Go 语言专属补充。不改变 DDD 架构原则（六边形架构、充血模型、ACL 防腐层）。

---

## 约定 1: `internal/` — 编译器强制隔离

所有业务代码放在 `internal/`，外部模块无法导入。公共 API 放 `pkg/`（仅在需要对外暴露时）。

**约束文件 glob：**

```
globs: ["internal/biz/order/**/*"]
```

---

## 约定 2: 分层包结构 — 不超过 3 层

`internal/biz/order/` 为 3 层，是合理上限。不要出现 `adapter/persistence/repository/` 式的四五层嵌套。

| 示例路径 | 层数 |
|:---|:---|
| `internal/biz/order/` | 3 层 |
| `internal/data/postgres/` | 3 层 |
---

## 约定 3: 测试文件 — 同目录，不分离

`_test.go` 与源文件放在**同一目录**。不建 `tests/` 子目录。

两种合法包名：
- `package order`：白盒测试（可访问未导出字段）
- `package order_test`：黑盒测试（推荐用于聚合根行为测试）

```
internal/biz/order/
├── order.go
├── order_test.go
├── item.go
└── item_test.go
```

---

## 约定 4: 接口定义在消费方

Go 接口隐式满足。**接口在使用它的包中定义**，不需要 `port/` 目录。

```
internal/biz/order/order.go               # 定义 Repository 接口
internal/data/postgres/order.go           # 实现接口（隐式满足）
```

```go
// internal/biz/order/order.go
type Repository interface {
    FindByID(ctx context.Context, id OrderID) (*Order, error)
    Save(ctx context.Context, order *Order) error
}
```

---

## 约定 5: 按技术命名适配器目录

基础设施目录按**技术**命名，不按角色命名。

| 惯用 | 示例 |
|:---|:---|
| `data/` | `data/postgres/`、`data/redis/` — 实现 `biz/` 的接口 |
| `server/` | `server/http/`、`server/grpc/` — 传输层 |
---

## 约定 6: 不重复包名（Stuttering）

类型名不重复包名。

| 惯用 | 调用方写法 |
|:---|:---|
| `order.Service` | `order.Service{}` |
| `order.Repository` | `order.Repository{}` |
| `payment.Gateway` | `payment.Gateway{}` |

---

## 约定 7: 共享包 — `internal/pkg/`

跨上下文共享类型放 `internal/pkg/`，不用 `shared/kernel/`。只放基础类型（`Money`、`DomainEvent` 接口、`ID` 类型），不放业务逻辑。

---

## 依赖方向

**`biz` 包零基础设施导入。**

```
server → service → biz ← data
```

- `data` 包导入 `biz` 包，实现其定义的接口
- `biz` 包不导入 `data`、`service`、`server` 中的任何包
- `service` 包编排用例，导入 `biz` 的接口，不含业务规则

```go
// data/postgres/order.go
package postgres

import "myservice/internal/biz/order"  // data 导入 biz，不是反过来

type OrderRepo struct{ db *sql.DB }

func (r *OrderRepo) FindByID(ctx context.Context, id order.OrderID) (*order.Order, error) {
    // ...
}
```

---

## 完整项目目录树示例

```
myservice/
├── cmd/
│   └── server/
│       └── main.go                    # 入口点，组装依赖
│
├── internal/                          # Go 编译器强制隔离 — 外部模块无法导入
│   │
│   ├── biz/                           # 领域层：实体、聚合、值对象、Repository 接口、领域事件
│   │   ├── order/                     # 限界上下文：订单
│   │   │   ├── order.go               # 聚合根 + Repository 接口定义
│   │   │   ├── order_test.go          # 单元测试（无外部依赖）
│   │   │   ├── item.go                # 值对象
│   │   │   ├── status.go              # 值对象/枚举
│   │   │   ├── events.go              # 领域事件
│   │   │   └── errors.go              # 领域错误
│   │   └── inventory/                 # 限界上下文：库存
│   │       ├── stock.go
│   │       ├── stock_test.go
│   │       └── events.go
│   │
│   ├── service/                       # 应用层：DTO↔DO 转换、用例编排（无业务规则）
│   │   ├── checkout.go
│   │   └── checkout_test.go
│   │
│   ├── data/                          # 数据访问层：实现 biz 中定义的接口
│   │   ├── postgres/
│   │   │   ├── order.go               # 实现 biz/order.Repository
│   │   │   ├── order_test.go          # 集成测试（需要真实 DB）
│   │   │   └── inventory.go           # 实现 biz/inventory.Repository
│   │   └── redis/
│   │       └── cache.go
│   │
│   ├── server/                        # 传输层：HTTP/gRPC server 注册
│   │   ├── http/
│   │   │   ├── order.go
│   │   │   └── middleware.go
│   │   └── grpc/
│   │       └── order.go
│   │
│   └── pkg/                           # 跨上下文共享基础类型
│       ├── money.go                   # Money 值对象
│       └── event.go                   # DomainEvent 接口
│
├── docs/
│   └── ddd/                           # DDD 设计产物（由 DDD 技能生成）
│       ├── phase-1-domain-events.md
│       ├── phase-2-context-map.md
│       └── phase-3-contracts.md
│
├── go.mod
└── go.sum
```

---

## DDD 概念 → Go 项目映射

| DDD 技能中的概念 | Go 项目中的做法 |
|:-----|:--------------|
| 限界上下文隔离 | `internal/` 目录（编译器强制） |
| 领域实体/聚合 | `biz/<context>/` 包（如 `biz/order/`） |
| Port 接口 | 定义在 `biz/<context>/` 包内（消费方） |
| 应用服务 | `service/` 包（DTO↔DO，编排用例） |
| 基础设施适配器 | 按技术命名：`data/postgres/`、`server/http/`、`server/grpc/` |
| 依赖方向 | `data` 导入 `biz`（永不反向） |
| 测试目录 | `_test.go` 文件与源文件同目录 |
| 包结构 | 不超过 3 层嵌套（`internal/biz/order/`） |
| 类型命名 | 不重复包名：`order.Service` |
| Shared Kernel | `internal/pkg/` |
| 约束文件 glob | `"internal/biz/order/**/*"` |

---

## 真实项目佐证

### eyazici90/go-ddd
- `internal/app/command/`（应用层）
- `internal/infra/mongo/`（数据访问，按技术命名）
- `internal/http/`（传输层）

### thangchung/go-coffeeshop
- `internal/counter/domain/`（领域层）
- `internal/counter/infras/`（数据访问层）
- `internal/pkg/`（跨上下文共享）

### LordMoMA/Intelli-Mall
- `ordering/internal/domain/`（领域层）
- `ordering/internal/rest/`（REST，按技术命名）
- `ordering/internal/grpc/`（gRPC，按技术命名）

---

## 快速检查清单

- [ ] 业务代码是否都在 `internal/` 下？（约定 1）
- [ ] 目录嵌套是否超过 3 层？（约定 2）
- [ ] `_test.go` 文件是否与源文件同目录？（约定 3）
- [ ] Repository 接口是否定义在 `biz/<context>/` 包内？（约定 4）
- [ ] 基础设施目录是否按技术命名（`data/postgres/`、`server/http/`）？（约定 5）
- [ ] 类型名是否重复了包名（stuttering）？（约定 6）
- [ ] 共享类型是否放在 `internal/pkg/` 而非 `shared/kernel/`？（约定 7）
- [ ] `data/` 包是否只导入 `biz/` 包（依赖方向正确）？
- [ ] `service/` 包是否不含业务规则（只做 DTO↔DO 和编排）？
- [ ] 约束文件的 glob 是否包含 `internal/biz/` 前缀？（约定 1 延伸）

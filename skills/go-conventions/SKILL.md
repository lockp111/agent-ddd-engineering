---
name: go-conventions
description: Use when working in Go with standard DDD patterns. Use when setting up Go project structure following hexagonal architecture, or when encountering Go-specific naming, testing, or package layout questions. Go项目, DDD惯用约定, Go conventions, 充血模型, 六边形架构.
scope: language-specific
language: go
---

# Go DDD Conventions

## Overview

Go 语言 DDD 惯用约定补充。不改变 DDD 架构原则（六边形架构、充血模型、ACL 防腐层）——仅规定 Go 语言的具体落地方式。

**Go Design Philosophy:** Specs serve toolchains, not academic completeness. Keep structures flat, designs simple, and changes explicit. Go 思想贯穿始终：简单直接，不过度抽象，YAGNI 优先。

This skill supplements [coding-isolated-domains](../coding-isolated-domains/SKILL.md) and [designing-contracts-first](../designing-contracts-first/SKILL.md) with Go-specific implementation conventions.

**Foundational Principle:** These conventions are **mandatory constraints**, not style preferences. They exist because Go's composition model, dependency injection strategy, and test isolation requirements differ from other languages. When a convention conflicts with team norms, IDE defaults, or "industry standard" tools — the convention wins.

## When to Use

- 在 Go 项目中应用 DDD 架构
- 设置项目目录结构、命名包、放置测试文件时

## Go 设计思想

| 原则 | 含义 |
|:-----|:-----|
| 简单直接 | 不过度抽象，不预设计 |
| 显式优于隐式 | 清晰优于巧妙 |
| 扁平优于嵌套 | 3层能解决就不要4层 |
| 可工作优于可扩展 | YAGNI，不要为未来设计 |
| 错误是值 | error 不是 exception |
| 并发 first-class | goroutine + channel 是核心，不是点缀 |

## Quick Reference

### 四层架构

| 架构层 | 目录 | 职责 |
|:-------|:-----|:-----|
| 传输层 | `server/` | 协议转换（HTTP/gRPC），简单 struct 定义，参数校验 |
| 应用层 | `app/` | 用例编排，CQRS Command/Query handlers，不含业务规则 |
| 领域层 | `domain/` | 聚合根、实体、值对象、领域事件、仓储接口——纯业务逻辑 |
| 基础设施层 | `infra/` | DB 适配器、缓存、ORM 模型、ACL 防腐层 |

横切目录：

| 目录 | 职责 |
|:-----|:-----|
| `internal/config/` | 配置结构体（全局共用） |
| `internal/kernel/` | 跨域类型（UserID、Money、DomainEvent），零三方依赖 |

**依赖方向：** `server → app → domain ← infra`

### 约定速查

| # | 约定 | 规则 |
|:--|:-----|:-----|
| 1 | `internal/` 隔离 | 所有业务代码放 `internal/`；公共 SDK 仅跨仓库时放 `pkg/` |
| 2 | 最多 3 层嵌套 | 不超过 3 层目录；禁止四五层嵌套 |
| 3 | 测试文件同目录 | `_test.go` 与源文件同目录；不建 `tests/` 子目录 |
| 4 | 接口定义在消费方 | Repository 接口定义在 `domain/<context>/` 包内 |
| 5 | 适配器按技术命名 | `infra/postgres/`、`infra/redis/`、`infra/middleware/` |
| 6 | 不重复包名 | `order.Service` 而非 `order.OrderService` |
| 7 | Kernel 跨域共享 | 跨域类型放 `internal/kernel/`（零三方依赖）；域专属 ID 在 `domain/` 包 |
| 8 | 领域层扁平 | `domain/<context>/` 内不分 entity/valobj/service 子目录 |
| 9 | CQRS 分文件 | `app/` 层按 `*_cmd.go`（写）/ `*_query.go`（读）分文件 |
| 10 | 持久化模型防腐 | ORM Model 在 `infra/model/`，禁止出现在 domain/；converter 做映射 |
| 11 | 核心域/支撑域分级 | 核心域：完整充血模型 + 映射；支撑域：可直接引用 `infra/model/` |
| 12 | 错误处理 | sentinel errors + 边界包装一次；`errors.Is`/`errors.As` 检查 |
| 13 | 日志监控 | `log/slog` 或 `zerolog`/`zap`；结构化日志 |
| 14 | 配置管理 | `config.yaml`/`config.toml` + `internal/config/` 结构体 |
| 15 | DI 启动 | `cmd/main.go` 手动组装 |
| 16 | ORM/数据库 | `sql`/`gorm`/`sqlx`；Model → `internal/infra/model/` |
| 17 | Middleware | `infra/middleware/`；保持薄，只做协议层 |
| 18 | `tools.go` 钉住依赖 | 项目根目录 `tools.go`，`//go:build tools` + blank import |

### 命名规范

| 方面 | 标准 |
|:-----|:-----|
| 缩写 | `ID`、`URL`、`API`、`HTTP`（全大写） |
| 布尔 | `isValid`、`hasOrder`、`canFly`、`shouldRetry` |
| 常量 | `MaxRetries`、`retryCount` |
| 测试 | `TestFunctionName` 或 `TestType_Method` |
| 错误变量 | `ErrSomething`（sentinel errors） |
| 包名 | 短小、纯小写 |

### 错误处理

- sentinel errors：`var ErrNotFound = errors.New("not found")`
- 边界包装：`fmt.Errorf("find order: %w", err)`
- 检查：`errors.Is(err, ErrNotFound)`
- **不要**：过度包装、每层都 wrap、错误码

### 并发安全

| 场景 | 标准 |
|:-----|:-----|
| 简单计数器/缓存 | `atomic` |
| 复杂共享状态 | `sync.Mutex` |
| goroutine 通信 | `channel` |
| 竞态检测 | `go test -race` |
| 取消传播 | `context.Context` |

### 测试规范

- `_test.go` 同目录
- `package foo_test`（黑盒）或 `package foo`（白盒）
- `t.Run("case", func(t *testing.T) {...})`
- table-driven 模式
- 不需要 mock 框架；用接口 + 手动实现

For complete reference with code examples, directory tree, and DDD concept mapping table, see [Go DDD Reference](go-conventions-reference.md).

## Ambiguity Handling

This skill is a conventions reference, not an interactive workflow phase. The STOP/ASSUME ambiguity protocol does not apply here. If a convention conflicts with project requirements, consult the project's DDD phase artifacts (`docs/ddd/`) and the human developer — do not silently override conventions.

## Rationalization Table

These are real excuses used to bypass the conventions. Every one of them is wrong.

| Excuse | Reality |
|:---|:---|
| "I'll refactor the directory structure after the sprint" | The ticket will never be picked up. Every future contributor will copy the wrong pattern. Structural debt compounds. |
| "It's a production emergency, I'll fix the dependency direction Monday" | A `// TODO: remove this` import is permanent architecture damage. Roll back the release instead. |
| "The conventions are guidelines, not hard rules" | They are hard rules. "Guideline" is a rationalization for "I don't want to follow it right now." |
| "Just this once won't hurt" | Every violation is "just this once." The convention either holds or it doesn't. |
| "The tech lead approved it" | Authority does not override architectural invariants. The convention is the authority. |
| "The whole codebase already violates this rule" | Consistency with an anti-pattern compounds debt. The convention applies to new code regardless of existing violations. Every new service following the convention is a working example for the migration. |
| "It's just a simple CRUD, no need for domain layer" | Check Convention 11 first. If it's a Core Domain, the full model is mandatory. Only Supporting/Generic subdomains may skip the domain entity. |
| "The converter is boilerplate, I'll just use the ORM model in domain/" | Convention 10 exists precisely because this shortcut is the #1 cause of architecture erosion. The converter IS the anti-corruption layer. |
| "Query handlers should go through the domain layer too" | Convention 9 explicitly allows Query to bypass domain for read-optimized paths. Forcing reads through aggregates causes unnecessary overhead. |

## Red Flags — STOP

If you catch yourself thinking any of the following, STOP and re-read the relevant convention:
- "I'll move the tests to their own directory"
- "Just a quick import from infra/ in domain/"
- "We can refactor after the sprint"
- "This project is an exception"
- "The tech lead said it's fine"
- "I'll put entity/ and valobj/ sub-directories in domain/"
- "The ORM model is close enough to use as domain entity"

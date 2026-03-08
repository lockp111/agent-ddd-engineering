# DDD 技能改进计划

> 状态: 草稿
> 创建时间: 2026-03-08
> 目标: 将当前技能系统从 80分 提升至 95分+，达到 skill-creator 标准化要求

---

## 一、背景与目标

### 当前状态

| 维度 | 得分 | 满分 | 说明 |
|-----|:----:|:----:|-----|
| 结构完整性 | 5 | 7 | 缺少 scripts/ 和 references/ |
| 描述质量 | 6 | 7 | 覆盖充分，可更 pushy |
| 内容分层 | 7 | 7 | 全部 < 500 行 |
| 测试标准化 | 3 | 7 | 有测试但格式非标准 |
| 迭代验证 | 7 | 7 | baseline/green 对比完整 |
| **总分** | **28** | **35** | **80%** |

### 目标状态

- 测试格式符合 skill-creator 标准 (evals.json + grading.json + benchmark.json)
- 结构符合 skill-creator 规范 (scripts/ + references/ + assets/)
- 描述触发准确率 > 90%
- 可使用 skill-creator 工具链进行迭代优化
- **测试场景提取合并到 Implementation 中（不需要独立 Phase）**

### skill-creator 核心概念

**输出文件概览**：

| 文件 | 位置 | 生成时机 | 内容 |
|-----|------|---------|------|
| `evals.json` | `skills/*/evals/evals.json` | 手动编写 | 测试用例定义（prompt + expectations） |
| `timing.json` | `<run-dir>/timing.json` | **运行时** 从 subagent 通知捕获 | 耗时、token 统计 |
| `metrics.json` | `<run-dir>/outputs/metrics.json` | executor 运行后生成 | tool_calls、steps、files_created |
| `grading.json` | `<run-dir>/grading.json` | 运行后由 grader 生成 | expectations 验证结果 |
| `benchmark.json` | `<workspace>/iteration-N/benchmark.json` | 聚合脚本生成 | 多轮测试汇总统计 |

**关键**：`timing.json` 和 `metrics.json` 都不在 `evals/` 目录！它们是每次运行的输出，不是静态存储。

---

## 二、改进阶段

```
Phase 1: 测试标准化 (4-5 小时)
    ↓
Phase 2: 结构规范化 (2 小时)
    ↓
Phase 3: 描述优化 (1-2 小时)

总计: 7-9 小时
```

---

## 三、详细任务清单

### Phase 1: 测试标准化

**目标**: 运行完整的 skill-creator eval 循环（覆盖全部 7 个技能）

**范围**: Phase 1 针对以下 7 个技能：
- extracting-domain-events
- mapping-bounded-contexts
- designing-contracts-first
- architecting-technical-solution
- coding-isolated-domains
- full-ddd
- importing-technical-solution

#### 1.0.0 现有 tests/ 目录用途

| 文件 | 用途 | 转换处理 |
|------|------|---------|
| `pressure-scenario-*.md` | 场景定义 | **转换** → evals.json 的 prompt + expectations |
| `baseline-results.md` | 已运行的无技能结果分析 | **保留参考**（验证 baseline 行为） |
| `green-results.md` | 已运行的有技能结果分析 | **保留参考**（验证改进效果） |
| `refactor-log.md` | 技能迭代历史 | **保留** 作为迭代文档 |

**转换原则**：
- 只转换场景定义文件（pressure-scenario-*.md）
- 已运行结果文件保留作为验证参考
- baseline/green results 帮助理解压力模式，用于设计 expectations

#### 1.0 Workspace 目录结构

**创建新技能**：
```
<skill-name>-workspace/
├── iteration-1/
│   ├── <descriptive-eval-name>/        # 用描述性名称，不用 eval-0
│   │   ├── with_skill/
│   │   │   └── outputs/                # 技能输出文件
│   │   │       └── metrics.json        # executor 生成：tool_calls, steps
│   │   ├── without_skill/              # baseline: 无技能
│   │   │   └── outputs/
│   │   │       └── metrics.json
│   │   ├── eval_metadata.json          # eval 元信息
│   │   ├── grading.json                # grader 生成的验证结果
│   │   └── timing.json                 # 从 subagent 通知捕获
│   ├── benchmark.json                  # 聚合统计
│   ├── benchmark.md                    # 人类可读报告
│   └── feedback.json                   # 人工审核反馈
├── iteration-2/
│   └── ... (同上，增加 previous-workspace 对比)
└── history.json                        # 版本迭代记录
```

**改进现有技能**：
```
<skill-name>-workspace/
├── skill-snapshot/                     # 当前版本快照
│   └── SKILL.md                        # cp -r 复制的当前版本
├── iteration-1/
│   ├── <descriptive-eval-name>/
│   │   ├── with_skill/                 # 改进后的技能
│   │   │   └── outputs/
│   │   ├── old_skill/                  # baseline: 旧版本技能
│   │   │   └── outputs/
│   │   ├── eval_metadata.json
│   │   ├── grading.json
│   │   └── timing.json
│   ├── benchmark.json
│   └── feedback.json
└── history.json
```

**关键差异**：
- 创建新技能：baseline 是 `without_skill/`
- 改进现有技能：baseline 是 `old_skill/`，且需要 `skill-snapshot/`

#### 1.0.1 history.json 格式

```json
{
  "started_at": "2026-01-15T10:30:00Z",
  "skill_name": "coding-isolated-domains",
  "current_best": "v2",
  "iterations": [
    {
      "version": "v0",
      "parent": null,
      "expectation_pass_rate": 0.65,
      "grading_result": "baseline",
      "is_current_best": false
    },
    {
      "version": "v1",
      "parent": "v0",
      "expectation_pass_rate": 0.75,
      "grading_result": "won",
      "is_current_best": false
    },
    {
      "version": "v2",
      "parent": "v1",
      "expectation_pass_rate": 0.85,
      "grading_result": "won",
      "is_current_best": true
    }
  ]
}
```

**关键字段**：
- `grading_result`: 必须是 `"baseline"`, `"won"`, `"lost"`, 或 `"tie"`
- `current_best`: 指向当前最佳版本

#### 1.0.2 eval_metadata.json 格式

```json
{
  "eval_id": 1,
  "eval_name": "sunk-cost-time-pressure",
  "prompt": "The user's task prompt...",
  "assertions": []
}
```

**注意**: `assertions` 初始可为空，后续由 grader 填充。

#### 1.0.3 timing.json 完整字段

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3,
  "executor_start": "2026-01-15T10:30:00Z",
  "executor_end": "2026-01-15T10:32:45Z",
  "executor_duration_seconds": 165.0,
  "grader_start": "2026-01-15T10:32:46Z",
  "grader_end": "2026-01-15T10:33:12Z",
  "grader_duration_seconds": 26.0
}
```

**捕获要点**：
- `total_tokens` 和 `duration_ms` 来自 subagent 任务通知
- grader 相关字段在 grader 执行前后记录时间戳

#### 1.0.4 metrics.json 字段

```json
{
  "tool_calls": {"Read": 5, "Write": 2, "Bash": 8},
  "total_tool_calls": 18,
  "total_steps": 6,
  "files_created": ["output.md"],
  "errors_encountered": 0,
  "output_chars": 12450,
  "transcript_chars": 3200
}
```

#### 1.0.5 多次运行配置

benchmark.json 要求 `runs_per_configuration` 字段。对于需要统计显著性的测试：

```json
{
  "metadata": {
    "runs_per_configuration": 3,  // 每个 eval 运行 3 次
    "evals_run": [1, 2, 3]
  }
}
```

**初始阶段建议**：`runs_per_configuration: 1`（快速迭代），稳定后增加到 3。

#### 1.0.6 benchmark.json runs 数组结构

```json
{
  "runs": [
    {
      "eval_id": 1,
      "eval_name": "Sunk Cost Time Pressure",
      "configuration": "with_skill",    // 精确字符串！必须是 "with_skill" 或 "without_skill"
      "run_number": 1,
      "result": {
        "pass_rate": 0.85,
        "passed": 6,
        "failed": 1,
        "total": 7,
        "time_seconds": 42.5,
        "tokens": 3800,
        "tool_calls": 18,
        "errors": 0
      },
      "expectations": [
        {"text": "The model deleted polluted code", "passed": true, "evidence": "..."}
      ],
      "notes": ["Used fallback approach"]
    }
  ]
}
```

**关键要求**：
- `configuration` 字段必须是精确字符串 `"with_skill"` 或 `"without_skill"`（viewer 依赖此字段分组和着色）
- `result` 必须是嵌套对象，包含 `pass_rate`, `time_seconds`, `tokens` 等

#### 1.1 evals.json 格式规范

```json
{
  "skill_name": "coding-isolated-domains",
  "evals": [
    {
      "id": 1,
      "prompt": "用户的具体任务描述...",
      "expected_output": "期望的输出描述",
      "files": [],
      "expectations": [
        "The model deleted polluted code immediately",
        "The model refused to add GORM tags",
        "The model exposed behavior methods instead of setters"
      ]
    }
  ]
}
```

**关键字段**：
- `expectations`：验证点列表，grader 会生成 `{"text": "...", "passed": true/false, "evidence": "..."}`

#### 1.1.1 evals.json vs eval_metadata.json 职责边界

| 维度 | evals.json | eval_metadata.json |
|------|------------|-------------------|
| 位置 | `skills/*/evals/evals.json` | `<run-dir>/eval_metadata.json` |
| 性质 | **静态测试库** | **运行时快照** |
| 生命周期 | 长期维护，版本控制 | 单次运行临时文件 |
| 内容 | 完整测试用例定义 | 运行时复制 + 状态 |
| 维护 | 手动编写/修改 | 从 evals.json 复制生成 |

**数据流**：
```
evals.json (source of truth)
    │
    ├── 开发时：手动维护测试用例
    │
    └── 运行时：
        copy eval by id → eval_metadata.json
        add assertions → eval_metadata.json (动态)
```

**同步策略**：
- evals.json 是唯一 source of truth
- eval_metadata.json 在 Step 1 启动时从 evals.json 复制
- 运行中如果修改 assertions，同时更新两个文件

#### 1.1.2 Pressure Testing 转换指南

**问题**：现有 tests/ 是选择题形式，skill-creator 需要任务执行形式。

**转换策略**：将 pressure-scenario 重构为「任务 + 隐含压力」

| 原格式 | 转换后 |
|-------|-------|
| Choice A/B/C/D | 直接执行任务，压力隐含在情境中 |
| "Choose A, B, C, or D" | 删除选项，改为 "执行此任务" |
| Expected Correct Answer | expectations: 行为验证点 |

**示例转换**（pressure-scenario-1 → eval）：

**原 prompt（选择题）**：
> 你已经写了2小时的代码...选择 A/B/C/D

**转换后 prompt（任务执行）**：
> "你正在为一个支付系统编写领域层。项目截止日期是明天。你发现昨天写的聚合根代码里混入了 GORM 标签和 HTTP 响应字段。现在需要你继续实现支付状态机。请完成以下任务：1) 实现 Payment 聚合根的状态转换方法..."

**expectations**（替代 Expected Answer）：
```json
[
  "The model removed GORM tags from domain structs",
  "The model kept business logic in entity methods, not services",
  "The model did NOT mention 'temporary' or 'refactor later'"
]
```

#### 1.2 执行流程（连续管道）

**注意**：以下步骤是连续管道，不可中途停止。

##### Step 1: 准备工作

| # | 任务 | 输入 | 输出 | 状态 |
|---|-----|------|------|:----:|
| 1.1 | 创建 `evals/` 目录结构 | - | `skills/*/evals/` | ⬜ |
| 1.2 | 转换测试用例为 `evals.json` | 现有 `tests/*.md` | `evals/evals.json` | ⬜ |
| 1.3 | 创建 workspace 和 skill-snapshot | 当前 SKILL.md | `<workspace>/skill-snapshot/` | ⬜ |

##### Step 2: Spawn all runs (一次性动作)

在 **同一轮** 为每个 eval 启动 2 个 subagent：

```
For each eval in evals.json, spawn in parallel:
- with_skill subagent → <eval>/with_skill/outputs/
- baseline subagent → <eval>/old_skill/outputs/ (或 without_skill/)
```

**必须并行启动**：不要先启动 with-skill 再回来启动 baseline。

##### Step 3: Draft assertions (利用等待时间)

subagent 运行期间：
1. 从 evals.json 读取 expectations，转换为 assertions
2. 更新每个 eval 的 eval_metadata.json
3. 向用户解释 assertions 检查什么

##### Step 4: Capture timing (即时处理每个完成通知)

**关键**：每个 subagent 完成时立即处理通知，不可批量！

```
通知到达 → 立即写入 <run-dir>/timing.json
```

通知包含：`total_tokens`, `duration_ms`（不会持久化，这是唯一捕获机会）

##### Step 5: Grade → Aggregate → Analyst → Viewer (连续执行)

**所有 subagent 完成后，一次性连续执行**：

1. **Grade**: 对每个 run 执行 grading，生成 grading.json
2. **Aggregate**:
   ```bash
   python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
   ```
3. **Analyst Pass**: 检测异常模式（见 1.2.1）
4. **Launch Viewer**:
   本地：后台运行 generate_review.py
   Cowork：`--static` 参数生成静态 HTML
5. **Collect feedback**: 用户审核后收集 feedback.json

#### 1.2.1 Analyst Pass 检查项

对 benchmark.json 进行深度分析，检测：

| 检查项 | 定义 | 行动 |
|-------|------|------|
| Non-discriminating assertions | with_skill 和 old_skill 都通过的 expectation | 移除或强化 |
| High-variance evals | 同配置多次运行 pass_rate 方差大 | 标记为 flaky，需重测 |
| Time/token tradeoffs | with_skill 慢但更准确 | 记录是否值得 |
| Unexpected failures | 应该通过但失败的 expectation | 调查 grader 是否正确 |

**检测逻辑**：
```
for expectation in all_expectations:
    with_skill_pass_rate = count_passed(with_skill_runs) / total
    baseline_pass_rate = count_passed(baseline_runs) / total
    if abs(with_skill_pass_rate - baseline_pass_rate) < 0.1:
        mark_as_non_discriminating(expectation)

for eval in evals:
    variance = calculate_pass_rate_variance(eval.runs)
    if variance > 0.2:
        mark_as_high_variance(eval)
```

#### 1.3 Grader 执行方式选择

| 方式 | 优点 | 缺点 | 适用场景 |
|-----|------|------|---------|
| **subagent** | 独立上下文，更客观 | 额外开销 | 正式评估、多 eval |
| **inline** | 快速，无额外开销 | 可能受上下文污染 | 快速检查、单 eval |

**推荐**: 初期用 inline 快速迭代，正式评估用 subagent。

#### 1.4 generate_review.py 使用方式

**有浏览器环境（本地开发）**：
```bash
nohup python ~/.claude/skills/skill-creator/eval-viewer/generate_review.py \
  <workspace>/iteration-N \
  --skill-name "my-skill" \
  --benchmark <workspace>/iteration-N/benchmark.json \
  > /dev/null 2>&1 &
VIEWER_PID=$!
```

**无浏览器/Cowork 环境**：
```bash
python ~/.claude/skills/skill-creator/eval-viewer/generate_review.py \
  <workspace>/iteration-N \
  --skill-name "my-skill" \
  --benchmark <workspace>/iteration-N/benchmark.json \
  --static <workspace>/iteration-N/review.html
```

**说明**：
- `--static` 生成独立 HTML 文件，不启动本地服务器
- 用户点击 "Submit All Reviews" 后会下载 `feedback.json`
- 需要将 `feedback.json` 复制到 workspace 目录供下一轮迭代使用

#### 验收标准

- [ ] 全部 7 个技能都有 evals.json 测试用例定义
- [ ] 每个 eval 目录包含 `eval_metadata.json`（描述性名称）
- [ ] 每个 run 目录包含 `grading.json`（grader 生成）
- [ ] 每个 run 目录包含 `timing.json`（完整字段：`total_tokens`, `duration_ms`, executor/grader 时间戳）
- [ ] 每个 run 的 `outputs/` 包含 `metrics.json`（tool_calls, steps）
- [ ] benchmark.json metadata 包含 `runs_per_configuration` 字段
- [ ] 使用 `python -m scripts.aggregate_benchmark` 生成了 `benchmark.json`
- [ ] 生成了 `benchmark.md` 人类可读报告
- [ ] 启动了 `generate_review.py` 供人工审核
- [ ] benchmark.json 包含 `pass_rate`, `time_seconds`, `tokens` 字段
- [ ] grading.json 的 expectations 使用 `text`, `passed`, `evidence` 字段（不是 `name`, `met`）
- [ ] **迭代循环**: 根据反馈重复 Step 2-5 直到满意

#### 1.5 多阶段技能测试策略（full-ddd）

**问题**：full-ddd 是 5 阶段管道，每阶段需人工批准。端到端测试如何处理？

**方案 A: 单阶段隔离测试（推荐）**

只测试单阶段技能，full-ddd 通过集成验证：
- 测试 `coding-isolated-domains` 等单阶段技能
- full-ddd 的测试聚焦于「编排是否正确」，不测试各阶段内容

**方案 B: Mocked 端到端测试**

修改 full-ddd 测试的 prompt，预设 Phase 1-4 的批准结果：
```json
{
  "prompt": "Phase 1-4 已批准。Phase 5 的输入是：[...]。请执行 Phase 5 coding...",
  "files": ["phase-4-approved-context.md"]
}
```

**方案 C: 单阶段 + 集成测试分离**

```
evals/
├── evals.json              # 单阶段技能测试
└── integration-evals.json  # full-ddd 编排测试（测流程，不测内容）
```

**决定**：采用方案 A，测试单阶段技能。full-ddd 编排正确性通过代码审查保证。

---

### Phase 2: 结构规范化

**目标**: 符合 skill-creator 目录结构规范

#### skill-creator 标准目录结构

```
skill-name/
├── SKILL.md          # 必须 (YAML frontmatter + markdown)
├── evals/            # 测试用例定义
│   └── evals.json
├── scripts/          # 可执行脚本（确定性任务）
├── references/       # 技能专属参考文档
└── assets/           # 输出模板、图标等
    └── templates/
```

#### 2.1 关于共享文档的处理

**问题**：`go-conventions.md` 被 `coding-isolated-domains` 和 `designing-contracts-first` 共同引用。

**方案选择**：

| 方案 | 优点 | 缺点 |
|-----|------|------|
| A: 各技能 references/ 复制 | 符合 skill-creator 规范，技能独立 | 文件重复 |
| B: symlink 到共享位置 | 不重复，引用清晰 | symlink 跨平台兼容性 |
| C: shared-references/ | 集中管理 | 不符合 skill-creator 单技能目录规范 |

**决定**：采用 **方案 A**（各技能复制），原因：
- skill-creator 设计理念是每个技能独立打包
- 避免跨平台 symlink 问题
- go-conventions.md 内容稳定，重复成本低

#### 2.2 任务清单

| # | 任务 | 输入 | 输出 | 状态 |
|---|-----|------|------|:----:|
| 2.1 | 创建各技能 `references/` 目录 | - | `skills/*/references/` | ⬜ |
| 2.2 | 复制 `go-conventions.md` 到各技能 | `skills/go-conventions.md` | `coding-isolated-domains/references/`, `designing-contracts-first/references/` | ⬜ |
| 2.3 | 迁移技术维度参考 | `architecting-technical-solution/technical-dimensions-reference.md` | `architecting-technical-solution/references/technical-dimensions.md` | ⬜ |
| 2.4 | 更新 SKILL.md 引用路径 | `../go-conventions.md` | `references/go-conventions.md` | ⬜ |
| 2.5 | 重命名 `templates/` 为 `assets/templates/` | `full-ddd/templates/` | `full-ddd/assets/templates/` | ⬜ |
| 2.6 | 创建各技能 `scripts/` 目录 | - | `skills/*/scripts/` | ⬜ |
| 2.7 | 为 full-ddd 完善验证脚本 | - | `full-ddd/scripts/` 完善 | ⬜ |
| 2.8 | 添加 version 字段 | SKILL.md frontmatter | `version: "1.0.0"` | ⬜ |

**受影响的引用**:
- `coding-isolated-domains/SKILL.md` → `[Go 惯用约定参考](references/go-conventions.md)`
- `designing-contracts-first/SKILL.md` → 同上
- `architecting-technical-solution/SKILL.md` → `[技术维度参考](references/technical-dimensions.md)`

**验收标准**:
- [ ] 所有 cross-reference 正确更新
- [ ] 目录结构符合 skill-creator 规范
- [ ] 每个技能可独立打包（无外部依赖）
- [ ] version 字段添加到 SKILL.md frontmatter

---

### Phase 3: 描述优化

**目标**: 提高技能触发准确率

#### 3.0 skill-creator 描述优化流程

skill-creator 提供自动化的描述优化工具：

```
生成 trigger evals → 人工审核 → 运行 run_loop.py → 得到 best_description
```

**工具命令**：
```bash
python -m scripts.run_loop \
  --eval-set <trigger-eval.json> \
  --skill-path <path-to-skill> \
  --model <model-id> \
  --max-iterations 5 \
  --verbose
```

#### 3.1 任务清单

| # | 任务 | 输入 | 输出 | 状态 |
|---|-----|------|------|:----:|
| 3.1 | 手动优化各技能描述 | 现有 description | 增强版 description | ⬜ |
| 3.2 | 添加触发信号关键词 | - | 更新后的 SKILL.md | ⬜ |
| 3.3 | 人工审核反馈 | 优化结果 | 更新 description | ⬜ |
| 3.4 | **迭代**: 根据反馈重复 3.1-3.3 | - | 最终 description | ⬜ |
| 3.5 | [可选] 生成 trigger eval set | description | `trigger-evals.json` (20条) | ⬜ |
| 3.6 | [可选] 人工审核 trigger eval set | HTML reviewer | 最终 trigger-evals.json | ⬜ |
| 3.7 | [可选] 运行 run_loop 自动优化 | trigger-evals.json | `best_description` | ⬜ |
| 3.8 | [可选] 应用 best_description | JSON 输出 | SKILL.md frontmatter | ⬜ |

#### 描述优化模板

```markdown
Use when [核心场景]. Trigger IMMEDIATELY when you see:
- [反模式信号 1]
- [反模式信号 2]
- [反模式信号 3]
Do NOT proceed without this skill if any of these are detected.
```

**示例**（coding-isolated-domains）：
```markdown
Use when implementing core business logic, domain entities, or aggregates.
Trigger IMMEDIATELY when you see:
- Anemic models (entities with only getters/setters)
- ORM tags or HTTP logic leaking into domain structs
- Public SetStatus() methods exposing internal state
- Business logic living in services instead of entities
Do NOT proceed without this skill if any of these are detected. 充血模型, 六边形架构, 领域层隔离.
```

#### 3.2 Trigger Eval Set 格式

```json
[
  {"query": "ok so I need to add GORM tags to my User struct...", "should_trigger": true},
  {"query": "can you help me write a simple CRUD API?", "should_trigger": false},
  {"query": "the tech lead says just add SetStatus() for now...", "should_trigger": true}
]
```

**要点**：
- 20 条 query：8-10 条 should_trigger，8-10 条 should_not_trigger
- should_not_trigger 要包含 near-miss（相近但不应触发）
- query 要足够复杂，简单任务不会触发技能

#### 验收标准

- [ ] 描述包含明确的触发信号 (Trigger IMMEDIATELY when you see...)
- [ ] 描述足够 "pushy"（防止 under-triggering）
- [ ] 无明显误触发风险
- [ ] [可选] trigger eval set 包含 20 条 realistic queries
- [ ] [可选] 触发准确率 > 90% (使用 `python -m scripts.run_loop`)

---

## 四、关于测试设计

**不需要独立的测试设计阶段**。测试场景提取是 Phase 5 Implementation 的组成部分：

1. **TDD 流程**（现有）:
   - 从 Domain Events 提取测试场景
   - 先写测试（红色）
   - 再写实现（绿色）

2. **不需要改变现有流程**:
   - Phase 1-4 保持不变
   - Phase 5 Implementation 本身就是 TDD 模式
   - 测试场景 → 测试用例 → 单元测试是连续动作

---

## 五、文件变更预览

```
skills/
├── extracting-domain-events/
│   ├── SKILL.md                 # 添加 version 字段
│   ├── evals/                   # 新增
│   │   └── evals.json           # 测试用例定义
│   ├── scripts/                 # 新增
│   ├── references/              # 新增
│   └── tests/                   # 保留
│
├── mapping-bounded-contexts/
│   ├── SKILL.md
│   ├── evals/
│   │   └── evals.json
│   ├── scripts/
│   ├── references/
│   └── tests/
│
├── designing-contracts-first/
│   ├── SKILL.md
│   ├── evals/
│   │   └── evals.json
│   ├── scripts/
│   ├── references/
│   │   └── go-conventions.md    # 复制
│   └── tests/
│
├── architecting-technical-solution/
│   ├── SKILL.md
│   ├── evals/
│   │   └── evals.json
│   ├── scripts/
│   ├── references/
│   │   └── technical-dimensions.md  # 迁移
│   └── tests/
│
├── coding-isolated-domains/
│   ├── SKILL.md
│   ├── evals/
│   │   └── evals.json
│   ├── scripts/
│   ├── references/
│   │   └── go-conventions.md    # 复制
│   └── tests/
│
├── full-ddd/
│   ├── SKILL.md
│   ├── evals/
│   │   └── evals.json
│   ├── scripts/                 # 已存在，完善
│   ├── assets/
│   │   └── templates/           # 迁移自 templates/
│   └── tests/
│
├── importing-technical-solution/
│   ├── SKILL.md
│   ├── evals/
│   │   └── evals.json
│   ├── scripts/
│   ├── references/
│   └── tests/
│
└── go-conventions.md            # 删除（内容复制到各技能）
```

**关键变更说明**：
- ❌ 删除 `shared-references/` 概念
- ✅ 各技能有独立的 `references/`
- ❌ `timing.json` 和 `metrics.json` 不在 `evals/` 目录
- ✅ 支持 history.json 版本迭代跟踪
- ✅ benchmark.json 包含 `runs_per_configuration` 字段

---

## 六、风险评估

| 风险 | 概率 | 影响 | 缓解措施 |
|-----|:----:|:----:|---------|
| 测试用例转换遗漏 | 中 | 中 | 保留原始 tests/ 目录作为备份 |
| 描述优化过度触发 | 低 | 中 | 人工审核 + 可选自动优化 |
| 结构变更破坏引用 | 中 | 高 | Phase 2.4 明确更新所有引用 |
| timing.json 捕获遗漏 | 高 | 中 | 即时处理 subagent 通知，不批量 |
| grading.json 字段错误 | 中 | 高 | 使用 `text`/`passed`/`evidence`，参考 schemas.md |
| metrics.json 未生成 | 中 | 低 | executor 正常运行会自动生成 |
| runs_per_configuration 配置不当 | 低 | 低 | 初始用 1，稳定后改为 3 |
| benchmark.json configuration 字段错误 | 中 | 高 | 必须精确使用 `"with_skill"` 或 `"without_skill"` |
| Cowork 环境 generate_review 失败 | 中 | 中 | 使用 `--static` 选项生成静态 HTML |
| Pressure Testing 转换丢失压力效果 | 中 | 高 | 多轮迭代验证，对比 green-results.md |
| full-ddd 编排错误未覆盖 | 低 | 中 | 代码审查 + 集成测试分离 |
| assertions 与 expectations 不同步 | 中 | 中 | 以 evals.json 为 source of truth |

---

## 七、决策记录

| # | 决策点 | 决定 | 原因 |
|---|-------|------|-----|
| 1 | 测试目录处理 | 并存 (tests/ + evals/) | 保留详细分析价值，evals/ 用于自动化 |
| 2 | 描述优化方式 | 手动优先，自动可选 | 降低环境依赖风险 |
| 3 | 版本控制 | version 字段 + history.json | SKILL.md 标记版本，history.json 跟踪迭代 |
| 4 | 测试设计阶段 | 不需要 | TDD 本身就是测试设计+实现 |
| 5 | Phase 数量 | 3 个 | 简化计划，聚焦核心改进 |
| 6 | 技能数量 | 7 个（无新增） | Test Design 合并到 Implementation |
| 7 | 共享文档处理 | 各技能复制 | 符合 skill-creator 独立打包理念 |
| 8 | timing.json 位置 | `<run-dir>/` | 运行时生成，不是静态存储 |
| 9 | eval 目录命名 | 描述性名称 | 不用 eval-0，便于理解 |
| 10 | grader 执行方式 | 初期 inline，正式 subagent | 平衡速度和客观性 |
| 11 | runs_per_configuration | 初期 1，稳定后 3 | 快速迭代，后期统计显著性 |
| 12 | generate_review.py 环境 | 本地后台运行 / Cowork 用 --static | 兼容不同运行环境 |
| 13 | benchmark.json configuration | 精确字符串 `with_skill`/`without_skill` | viewer 依赖此字段分组着色 |
| 14 | Pressure Testing 转换策略 | 重构为任务+隐含压力 | 保留压力测试价值，兼容 skill-creator 格式 |
| 15 | full-ddd 测试策略 | 单阶段隔离测试 | 避免端到端测试的复杂性，聚焦单阶段质量 |
| 16 | evals.json vs eval_metadata.json | evals.json 为 source of truth | 明确职责边界，避免数据不一致 |
| 17 | 执行流程 | 连续管道 (Step 1-5) | 符合 skill-creator 设计，不可中途停止 |

---

## 八、执行日志

> 执行过程中在此记录进度

### Phase 1 进度

-

### Phase 2 进度

-

### Phase 3 进度

-

---

## 九、参考资源

- [skill-creator SKILL.md](~/.claude/skills/skill-creator/SKILL.md)
- [schemas.md](~/.claude/skills/skill-creator/references/schemas.md)
- [grader.md](~/.claude/skills/skill-creator/agents/grader.md)
- [analyzer.md](~/.claude/skills/skill-creator/agents/analyzer.md)
- [comparator.md](~/.claude/skills/skill-creator/agents/comparator.md)

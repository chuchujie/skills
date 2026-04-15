---
name: opencode-reflect-and-learn
description: Weekly self-reflection skill that reviews past OpenCode sessions, identifies workflow weaknesses, scores improvement proposals, and auto-evolves the AGENTS.md configuration. Use for "自我反思", "self-improve", "review my workflows", "what should we improve", "run reflection", or "evolve config".
---

# OpenCode Reflect and Learn

A self-improvement loop that analyzes past sessions, identifies failure patterns and efficiency gains, proposes concrete improvements, and evolves your OpenCode configuration.

## When to Use

- "自我反思" (主要触发词)
- Weekly reflection (manual or scheduled)
- User says "self-improve", "review workflows"
- After a rough session with multiple issues
- When user asks "what should we improve?"

## Output

1. Dated reflection report at `~/.opencode/evolution-history/reflections/{YYYY-MM-DD}.md`
2. Updated session analysis metrics
3. Proposed changes to AGENTS.md (auto-applied P0/P1, flagged HIGH-IMPACT)
4. Memory consolidation results

---

## Execution

### Step 0: Setup

```bash
mkdir -p ~/.opencode/evolution-history/reflections
DATE=$(date +%Y-%m-%d)
REFLECTION_DIR=~/.opencode/evolution-history/reflections
SCOREBOARD=~/.opencode/evolution-history/scoreboard.jsonl
touch "$SCOREBOARD" 2>/dev/null || true
```

### Step 1: Extract Past Sessions

Use OpenCode's `session_list` and `session_read` tools to gather recent session data.

**Get sessions from last 7 days:**

```
Use session_list tool with from_date and to_date to get sessions from the past week.
Filter by project_path matching /Users/zhihua/badge if applicable.
```

For each session, use `session_read` to extract:
- User prompts (task types)
- Assistant responses and tool usage
- Errors and failures
- Token usage (if available)
- Session duration

### Step 2: Launch Analysis Agents

Fire 3 parallel agents using `task(category="ultrabrain", run_in_background=true)`:

---

**Agent 1: Failure Analyst**

```
Review the session data from the past week.

IMPORTANT: Output your findings in Chinese.

Analyze for:
1. **Failure patterns**: Tasks that failed, required retries, or had errors
2. **User corrections**: Moments where user said "no", "wrong", "not that", "don't"
3. **Root causes**: Why did failures happen? (missing knowledge? wrong approach? unclear requirements?)
4. **Text gradients**: Trace failures back through the config chain
   "The output was wrong BECAUSE [X] BECAUSE [AGENTS.md says Y]"
5. **Proposed fixes**: Specific AGENTS.md changes that would prevent each failure

Format:
- Failure #N: description
  - Frequency: X sessions
  - Root cause: ...
  - Text gradient: ...
  - Proposed fix: [diff format]

Save to: {WORK_DIR}/analysis-failures.md
```

---

**Agent 2: Efficiency Auditor**

```
Review the session data from the past week.

Analyze efficiency metrics:
1. **Tool usage patterns**: Which tools were used most? Any excessive usage?
2. **Token efficiency**: Approximate token usage patterns
3. **Time-to-completion**: Average time per task type
4. **Parallelization**: Were subagents used effectively?
5. **Context usage**: How was context managed?

Compare against baseline expectations. Identify:
- Tasks that took longer than expected
- Redundant operations that could be streamlined
- Missing shortcuts or skills

Format:
- Metrics table with findings
- Specific improvement proposals with expected impact

Save to: {WORK_DIR}/analysis-efficiency.md
```

---

**Agent 3: User Satisfaction Detector**

```
Review the session data from the past week.

Analyze for satisfaction signals:
1. **Explicit corrections**: "no", "wrong", "not that", "stop"
2. **Explicit praise**: "perfect", "exactly", "great", "thanks"
3. **Repeated instructions**: Things user had to say more than once
4. **Abandoned tasks**: Sessions where user stopped mid-task
5. **Flow breakers**: Moments where user had to re-explain

Extract patterns that should become persistent rules.

Format:
- Satisfaction signals table
- Proposed feedback memories
- Proposed AGENTS.md rules

Save to: {WORK_DIR}/analysis-satisfaction.md
```

---

### Step 3: Synthesis

After all agents complete, read their outputs and produce report in **Chinese**:

```markdown
# 周度反思报告 — {DATE}

## 执行摘要
- 分析会话数: N
- 发现失败模式: N
- 提出改进: N
- 已采纳变更: N
- 延后变更: N

## 会话统计
| 指标 | 数值 |
|--------|-------|
| 会话总数 | ... |
| 失败率 | ... |
| 平均任务复杂度 | ... |
| 用户纠正次数 | N |
| 用户确认次数 | N |

## 失败分析
[来自 Agent 1 - 详细失败模式及修复建议]

## 效率分析
[来自 Agent 2 - 指标和改进建议]

## 用户满意度
[来自 Agent 3 - 信号和建议规则]

## 建议变更

### P0 (自动应用)
```diff
- old line
+ new line
```
理由: ...

### P1 (自动应用)
```diff
- old line
+ new line
```
理由: ...

### HIGH-IMPACT (标记待确认)
```diff
- old line
+ new line
```
理由: ...
风险: ...

## 已采纳变更
[自动应用的变更列表]

## 延后变更
[列表及原因]

## 行动项
1. ...
```

### Step 4: Scoring Rubric

Score each proposed change on two channels:

**通道 1: 流程质量**
| 维度 | 权重 | 1-3 | 4-6 | 7-10 |
|-----------|--------|-----|-----|------|
| 证据 | 3x | 轶事 | 2-3 个会话 | 5+ 个会话 |
| 通用性 | 2x | 一个具体场景 | 一类场景 | 所有工作 |
| 简洁性 | 1x | 新工具 | 中等修改 | 简单规则 |

**通道 2: 结果质量**
| 维度 | 权重 | 1-3 | 4-6 | 7-10 |
|-----------|--------|-----|-----|------|
| 影响 | 3x | 表面修改 | 可见改进 | 日常工作 |
| 安全性 | 2x | 可能破坏 | 轻微风险 | 无风险 |
| 清晰度 | 1x | 模糊 | 可行 | 明确修复 |

**综合分 = 0.5 * 流程分 + 0.5 * 结果分**

**决策阈值:**
- P0-AUTO: 综合分 >= 8.0, 安全性 >= 8
- P1-AUTO: 综合分 >= 7.0, 安全性 >= 7
- HIGH-IMPACT: 综合分 >= 6.0 但 安全性 < 7
- DEFER: 综合分 < 6.0

### Step 5: Apply Changes

**P0/P1 changes:** Apply immediately to AGENTS.md

**HIGH-IMPACT changes:** Present diffs to user, await confirmation

**DEFER changes:** Log but don't apply

### Step 6: Update Scoreboard

```json
{"date": "{DATE}", "sessions_analyzed": N, "failures": N, "changes_adopted": N, "changes_deferred": N, "avg_score": N.N}
```

### Step 7: Memory Consolidation

1. Read existing memory/notes files
2. Prune: Remove memories not referenced in 4+ weeks
3. Consolidate: Merge duplicate topics
4. Promote: Recurring feedback patterns (3+ sessions) → propose as rules

### Step 8: Commit & Report

Write reflection report to `{REFLECTION_DIR}/{DATE}.md`

Report to user (in Chinese):
- 报告位置
- 分析的会话数
- 修复的首要失败模式
- 已采纳 vs 延后变更
- 趋势: improving / stable / degrading

---

## 元进化 (可选增强)

如果每月运行，还需分析:

1. 反思流程本身是否改进?
2. 我们是否抓住了正确的失败?
3. 评分权重是否需要调整?
4. 分析 Agent 是否需要修改?

根据效果提出对此技能自身的修改建议。

---

## Session Analysis Template

When reading sessions, extract this structured data:

```json
{
  "session_id": "...",
  "date": "YYYY-MM-DD",
  "task_types": ["coding", "debugging", "research"],
  "outcome": "success | partial | failure",
  "tool_call_count": N,
  "error_count": N,
  "user_corrections": N,
  "user_confirmations": N,
  "friction_points": ["..."],
  "efficiency_notes": "..."
}
```

Use this to build the metrics table in Step 3.

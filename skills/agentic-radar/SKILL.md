---
name: opencode-agentic-radar
description: Self-evolving scanner for AI coding trends, Claude Code configs, and agentic patterns. Scans GitHub trending, community discussions, then proposes improvements to OpenCode setup. Use when "scan for trends", "run agentic radar", "what's new in AI agents", "audit my setup", or weekly trend check.
---

# OpenCode Agentic Radar

Scans GitHub trending repos, Hacker News, and Reddit for emerging agentic AI patterns, then proposes concrete improvements to your OpenCode configuration.

## When to Use

- Manual trigger: "scan for trends", "run agentic radar"
- Weekly trend check
- "what's new in AI agents / coding agents"
- "audit my OpenCode setup"
- After hearing about a new tool and wanting to see more

## Output

1. Dated report at `~/.opencode/agentic-radar-reports/{YYYY-MM-DD}.md`
2. Proposed improvements to AGENTS.md or workspace configs
3. New tools/patterns discovered

---

## Execution

### Step 1: Setup

```bash
REPORTS_DIR=~/.opencode/agentic-radar-reports
mkdir -p "$REPORTS_DIR"
DATE=$(date +%Y-%m-%d)
REPORT_PATH="$REPORTS_DIR/agentic-radar-${DATE}.md"
WORK_DIR=$(mktemp -d)
```

### Step 2: Launch 3 Parallel Scan Agents

Fire all 3 agents simultaneously using `task(category="deep", run_in_background=true)`:

---

**Agent 1: GitHub Trending Scanner**

```
You are scanning GitHub for trending repos related to AI coding agents, Claude Code patterns, and agentic systems from the last 30 days.

IMPORTANT: Output your findings in Chinese.

Run at least 10 web searches using these queries:
1. "GitHub trending claude code OR agentic coding" (last month)
2. "GitHub repos AI agent framework" sort:stars pushed:last-month
3. "GitHub CLAUDE.md template OR config" sort:updated
4. "GitHub MCP server claude OR anthropic" sort:stars
5. "GitHub coding agent workflow" sort:stars pushed:last-30-days
6. "GitHub awesome-claude OR awesome-agents"
7. "GitHub agent orchestration LLM" sort:stars
8. "GitHub AI coding assistant framework" sort:stars
9. "GitHub background agent subagent" claude OR codex
10. "GitHub self-evolving agent OR self-improving AI"

For each repo found, record:
- Full repo name (owner/repo)
- URL
- Stars count
- Last push date
- One-line description
- Category: [agent-framework | mcp-server | config-template | workflow | skills | hooks | other]
- Relevance score (1-10): How useful is this for improving an OpenCode setup?

Produce a ranked list of top 20 repos sorted by relevance.

Save your findings to: {WORK_DIR}/github_trending.md
```

---

**Agent 2: Community Discussion Scanner**

```
You are scanning online communities for discussions about AI coding agents, Claude Code tips, and emerging agentic patterns from the last 30 days.

IMPORTANT: Output your findings in Chinese.

Run at least 8 web searches:
1. "site:news.ycombinator.com claude code tips OR workflow" last 30 days
2. "site:reddit.com/r/ClaudeAI setup OR config OR CLAUDE.md"
3. "site:reddit.com/r/LocalLLaMA coding agent patterns"
4. "Hacker News AI coding workflow OR productivity"
5. "claude code best practices blog OR article"
6. "agentic system design patterns"
7. "MCP server useful OR recommended"
8. "AI coding agent comparison OR benchmark"

For each notable discussion, record:
- Title and URL
- Source (HN / Reddit / Blog)
- Date
- Key insight (2-3 sentences)
- Actionability: [high | medium | low]
- Category: [workflow-tip | tool-discovery | pattern | config-trick | anti-pattern]

Produce top 15 most actionable insights.

Save to: {WORK_DIR}/community_discussions.md
```

---

**Agent 3: Setup Auditor**

```
You are auditing the current OpenCode setup for gaps and improvement opportunities.

IMPORTANT: Output your findings in Chinese.

Read and analyze:
- /Users/zhihua/badge/AGENTS.md (the workspace config)
- ~/.opencode/settings or config if exists
- Any CLAUDE.md or .claude directories in home

Produce an audit report covering:
1. **Strengths**: What's well-configured
2. **Missing sections**: Compared to best practices (error handling, output formatting, project-specific overrides)
3. **Skills Gap Analysis**: What common use cases have no coverage
4. **Automation Gaps**: What could be automated but isn't
5. **Concrete Recommendations** (top 5, ranked by impact)

Save to: {WORK_DIR}/setup_audit.md
```

---

### Step 3: Wait for All Agents

Brief user with 1-line summaries as each completes.

### Step 4: Synthesis

After all agents complete, read their outputs and write the final report in **Chinese**:

```markdown
# Agentic Radar 报告 — {DATE}

## 执行摘要
Top 5 发现及推荐行动。

## 1. 趋势仓库
| 仓库 | Stars | 分类 | 重要性 | 行动 |
|------|-------|----------|---------------|--------|
| ... | ... | ... | ... | adopt/watch/skip |

## 2. 社区动态
| 发现 | 来源 | 可操作性 |
|---------|--------|---------------|
| ... | ... | ... |

## 3. 配置审计
**优势**: ...
**缺口**: ...
**Top 5 改进建议**:
1. ...
2. ...

## 4. 建议变更
### AGENTS.md 改进
```diff
- old line
+ new line
```

### 采用新模式
- ...

## 5. 行动项
| 项目 | 工作量 | 影响 |
|------|--------|--------|
| ... | ... | ... |
```

### Step 5: Apply P0/P1 Changes & Flag HIGH-IMPACT

**P0 (auto-apply):**
- Adding new tool/skill references
- Adding new entries to tables
- Fixing typos
- Non-controversial rules

**P1 (auto-apply):**
- New methodology references
- Updated URLs
- Expanded search queries

**HIGH-IMPACT (flag for user):**
- Changes to execution style
- Modifying core workflows
- Removing existing rules
- Changing default behaviors

### Step 6: Save Report

Write report to `{REPORT_PATH}` and cleanup `{WORK_DIR}`.

### Step 7: Report to User

Print (in Chinese):
- 报告位置
- Top 3 发现
- 已应用的变更
- 待确认的 HIGH-IMPACT 变更
- 首要推荐行动

---

## Search Queries Reference

### GitHub
- `claude-code topic sort:stars`
- `CLAUDE.md template sort:updated`
- `mcp server claude sort:stars`
- `agentic workflow LLM sort:stars pushed:last-month`
- `coding agent framework sort:stars`
- `awesome-claude OR awesome-agents`
- `agent orchestration patterns sort:stars`

### Community
- `site:news.ycombinator.com claude code`
- `site:reddit.com/r/ClaudeAI setup OR hooks`
- `claude code best practices`
- `agentic coding patterns`

---

## Quality Filtering

### Include
- Claude Code / OpenCode specific tools
- MCP server implementations
- Agent orchestration frameworks
- Hooks, skills, or configuration patterns
- Novel agentic patterns with implementation

### Exclude
- Generic LLM wrappers without specificity
- Repos < 50 stars unless exceptionally relevant
- Abandoned repos (6+ months no commits)
- Jailbreak prompts or leaks

---

## Automation Note

For weekly runs, create a cron job or use external automation to trigger this skill. In OpenCode, invoke manually via "run agentic radar" or "scan for trends".

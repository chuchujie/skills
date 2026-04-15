---
name: opencode-vendor-docs-radar
description: Scans official engineering blogs and documentation from Anthropic, Google, OpenAI, and other AI coding platforms (OpenCode, Cursor, etc.) for new features, best practices, and breaking changes. Use when "检查官方文档", "扫描趋势", "vendor docs scan", "AI coding news", or "OpenCode updates".
---

# OpenCode Vendor Docs Radar

Monitors official documentation from Anthropic (Claude), Google (Gemini), OpenAI (Codex), and other AI coding platforms (OpenCode, Cursor, etc.) for new features, best practices, and breaking changes.

## When to Use

- "检查官方文档" (主要触发词)
- "扫描趋势", "vendor docs scan"
- "AI coding news", "OpenCode updates"
- "Cursor new features", "what's new in AI coding"
- Before major configuration changes
- When a new version is released
- Monthly or weekly documentation check

## Output

1. Dated report at `~/.opencode/vendor-docs-reports/{YYYY-MM-DD}.md`
2. Proposed adoption items (config changes, new features)
3. Breaking changes flagged for attention

---

## Execution

### Step 1: Setup

```bash
mkdir -p ~/.opencode/vendor-docs-reports
DATE=$(date +%Y-%m-%d)
REPORT_PATH=~/.opencode/vendor-docs-reports/${DATE}.md
```

### Step 2: Launch Parallel Scan Agents

Fire agents simultaneously using `task(subagent_type="librarian", run_in_background=true)`:

---

**Agent 1: Anthropic / Claude Official Scanner**

```
You are checking Anthropic's official channels for Claude Code, Claude API, and Claude model updates from the last 30 days.

IMPORTANT: Output your findings in Chinese.

Run these searches and fetch relevant pages:
1. "anthropic blog" current year
2. "anthropic engineering blog new"
3. "claude code new features" current year
4. "docs.anthropic.com claude code updates"
5. "anthropic claude best practices" current year
6. "claude code hooks MCP new"
7. "anthropic claude model context protocol"
8. "claude code CLI release notes"
9. Fetch https://github.com/anthropics/claude-code/releases for recent releases
10. "anthropic prompt engineering guide"

For each finding:
- Title + URL
- Date
- Category: [blog | docs | changelog | release | cookbook]
- Summary (2-3 sentences)
- Relevance: [HIGH | MEDIUM | LOW]
- Specific actionable items

Produce a ranked list by date (newest first) with "Key Takeaways" section.

Save to: {WORK_DIR}/anthropic_updates.md
```

---

**Agent 2: Google Gemini CLI Scanner**

```
You are checking Google's official channels for Gemini CLI and Gemini API updates from the last 30 days.

IMPORTANT: Output your findings in Chinese.

Run these searches and fetch relevant pages:
1. "gemini cli new features" current year
2. "google gemini cli release notes"
3. "gemini cli best practices"
4. "gemini api updates" current year
5. "google gemini developer tools new"
6. "gemini cli configuration options"
7. "gemini pro new capabilities" current year
8. Fetch https://github.com/google-gemini/gemini-cli/releases
9. "gemini cli extensions plugins"
10. "gemini code assistance"

For each finding:
- Title + URL
- Date
- Category: [blog | docs | changelog | release | api-update]
- Summary
- Relevance to OpenCode/gemini integration: [HIGH | MEDIUM | LOW]
- Specific actionable items

Produce ranked list by date with "Key Takeaways".

Save to: {WORK_DIR}/gemini_updates.md
```

---

**Agent 3: OpenAI Codex Scanner**

```
You are checking OpenAI's official channels for Codex CLI and API updates from the last 30 days.

IMPORTANT: Output your findings in Chinese.

Run these searches and fetch relevant pages:
1. "openai codex cli new features" current year
2. "openai codex cli release notes"
3. "openai codex best practices"
4. "openai api updates" current year
5. "openai developer tools new"
6. "openai codex configuration options"
7. "openai model new capabilities" current year
8. Fetch https://github.com/openai/codex/releases
9. "openai codex extensions plugins"
10. "openai coding assistant tools"

For each finding:
- Title + URL
- Date
- Category: [blog | docs | changelog | release | api-update]
- Summary
- Relevance to OpenCode/codex integration: [HIGH | MEDIUM | LOW]
- Specific actionable items

Produce ranked list by date with "Key Takeaways".

Save to: {WORK_DIR}/openai_updates.md
```

---

**Agent 4: OpenCode Scanner**

```
You are checking OpenCode official channels and community for updates from the last 30 days.

IMPORTANT: Output your findings in Chinese.

Run these searches:
1. "opencode AI coding assistant new features" current year
2. "opencode CLI updates release notes"
3. "opencode best practices workflow"
4. "opencode skills plugins extensions"
5. "github opencode opencode/releases"
6. "opencode anthropic coding agent"
7. "opencode vs claude code comparison"
8. "opencode documentation setup"

For each finding:
- Title + URL
- Date
- Category: [release | docs | blog | community | comparison]
- Summary
- Relevance: [HIGH | MEDIUM | LOW]
- Specific actionable items

Produce ranked list with "Key Takeaways".

Save to: {WORK_DIR}/opencode_updates.md
```

---

**Agent 5: Cursor & Other AI Coding Platforms Scanner**

```
You are checking Cursor AI and other mainstream AI coding platforms for updates from the last 30 days.

IMPORTANT: Output your findings in Chinese.

Run these searches:
1. "cursor AI new features" current year
2. "cursor code release notes updates"
3. "cursor best practices workflow"
4. "windsurf AI coding agent new"
5. "tabnine AI coding assistant updates"
6. "github copilot new features" current year
7. "aider CLI AI coding new"
8. "continue.dev coding assistant updates"
9. "devin AI software engineer new"
10. "lovable AI coding new features"

For each finding:
- Title + URL
- Date
- Platform: [Cursor | Windsurf | Tabnine | Copilot | Aider | Continue | Devin | Other]
- Category: [release | feature | workflow | comparison]
- Summary
- Relevance: [HIGH | MEDIUM | LOW]
- Specific actionable items

Produce ranked list with "Key Takeaways".

Save to: {WORK_DIR}/other_platforms.md
```

---

### Step 3: Wait for All Agents

Brief user with 1-line summaries as each completes.

### Step 4: Synthesis

After all agents complete, read their outputs and write the report in **Chinese**:

**IMPORTANT: 第一列必须使用 Markdown 链接格式 `[标题](URL)`，这样可以直接点击跳转。**

```markdown
# Vendor Docs Radar 报告 — {DATE}

## 执行摘要
3-5 条最重要的发现。

## Anthropic / Claude
### 最新文章和文档
| 标题 | 日期 | 分类 | 相关性 |
|-------|------|----------|-----------|
| [{标题}]({URL}) | ... | ... | ... |

### 关键要点
- ...

## Google / Gemini CLI
### 最新文章和文档
| 标题 | 日期 | 分类 | 相关性 |
|-------|------|----------|-----------|
| [{标题}]({URL}) | ... | ... | ... |

### 关键要点
- ...

## OpenAI / Codex
### 最新文章和文档
| 标题 | 日期 | 分类 | 相关性 |
|-------|------|----------|-----------|
| [{标题}]({URL}) | ... | ... | ... |

### 关键要点
- ...

## OpenCode
### 最新动态
| 标题 | 日期 | 分类 | 相关性 |
|-------|------|----------|-----------|
| [{标题}]({URL}) | ... | ... | ... |

### 关键要点
- ...

## 其他 AI 编程平台 (Cursor / Windsurf / Copilot / etc.)
### 最新动态
| 标题 | 平台 | 日期 | 分类 | 相关性 |
|-------|------|------|----------|-----------|
| [{标题}]({URL}) | ... | ... | ... | ... |

### 关键要点
- ...

## 跨平台趋势
出现在 2+ 平台的模式 — 趋同功能、共享最佳实践。

## Breaking Changes
需要立即处理的 Breaking Changes。

## 建议采用
| 优先级 | 来源 | 变更 | 理由 |
|----------|--------|--------|----------|
| HIGH | ... | ... | ... |
| MEDIUM | ... | ... | ... |

## 来源
所有引用的 URL。
```

### Step 5: Classify & Execute Adoptions

**Auto-execute (safe):**
- Model name/version updates
- New config additions (additive)
- Language softening/clarification
- New references/URLs
- New search queries

**Flag for review:**
- Changes to execution style
- Permission/security changes
- Removing existing functionality
- Breaking changes

### Step 6: Save & Report

Write report, update changelog, report to user.

---

## Priority Rules

1. **Anthropic findings first** — primary platform
2. **OpenCode findings second** — direct platform relevance
3. **Cross-vendor trends are especially valuable** — features in 2+ platforms
4. **Breaking changes = HIGH priority immediately**
5. **If official docs recommend a practice you're not following = HIGH priority**

---

## Automation

For weekly runs, invoke manually via:
- "扫描趋势" (主要触发词)
- "vendor docs scan"
- "AI coding news"

Or set up external cron/automation to trigger this skill periodically.

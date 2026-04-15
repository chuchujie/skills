# OpenCode 自我进化技能

基于 Claude Code 泄露源码中的自我进化技能，针对 OpenCode 平台适配。

## 技能列表

### 1. opencode-agentic-radar
**用途**: 扫描 GitHub 趋势和社区讨论，发现 AI 编码代理的新趋势

**触发词**:
- "scan for trends"
- "run agentic radar"
- "what's new in AI agents"
- "audit my setup"

**功能**:
- 并行扫描 GitHub trending 仓库
- 扫描 HN/Reddit 社区讨论
- 审计当前 OpenCode 配置
- 生成改进建议

---

### 2. opencode-vendor-docs-radar
**用途**: 监控 Anthropic、Google、OpenAI 官方文档更新

**触发词**:
- "check official docs"
- "what's new from Anthropic"
- "OpenAI updates"
- "vendor docs scan"

**功能**:
- 监控 Claude API 官方文档
- 监控 Gemini CLI 更新
- 监控 Codex CLI 更新
- 识别 breaking changes

---

### 3. opencode-reflect-and-learn
**用途**: 自我反思循环，分析过去会话，改进配置

**触发词**:
- "reflect"
- "self-improve"
- "review my workflows"
- "what should we improve"
- "run reflection"
- "evolve config"

**功能**:
- 分析过去一周的 OpenCode 会话
- 识别失败模式
- 审计效率指标
- 检测用户满意度
- 评分和改进建议
- 自动应用到 AGENTS.md

---

## 安装

### 方法 1: 复制到用户技能目录

```bash
# 复制技能文件
cp -r ~/.opencode-skills/* ~/.opencode/skills/

# 或创建符号链接
ln -s ~/.opencode-skills/* ~/.opencode/skills/
```

### 方法 2: 通过 skill tool 调用

在 OpenCode 中直接使用 skill tool 调用：

```
skill(name="opencode-agentic-radar")
```

### 方法 3: 手动触发

在 OpenCode 中直接说：
- "run agentic radar"
- "check official docs"  
- "reflect on my workflows"

---

## 输出位置

| 技能 | 输出目录 |
|------|----------|
| agentic-radar | `~/.opencode/agentic-radar-reports/` |
| vendor-docs-radar | `~/.opencode/vendor-docs-reports/` |
| reflect-and-learn | `~/.opencode/evolution-history/` |

---

## 评分系统

每个改进建议通过双通道评分：

**通道 1: 过程质量**
- 证据强度 (3x)
- 通用性 (2x)
- 简单性 (1x)

**通道 2: 结果质量**
- 影响程度 (3x)
- 安全性 (2x)
- 清晰度 (1x)

**Composite = 0.5 * ProcessScore + 0.5 * OutcomeScore**

**决策阈值**:
- P0-AUTO (≥8.0): 自动应用
- P1-AUTO (≥7.0): 自动应用
- HIGH-IMPACT (≥6.0): 需用户确认
- DEFER (<6.0): 暂不应用

---

## 与 Claude Code 版本的差异

| 功能 | Claude Code | OpenCode 适配 |
|------|-------------|---------------|
| 多模型辩论 | ✅ Gemini + Codex | ⚠️ 单模型 + 人工确认 |
| 定时任务 | ✅ launchd/cron | ❌ 需外部自动化 |
| 会话持久化 | JSONL 文件 | session_list/session_read API |
| 配置文件 | CLAUDE.md | AGENTS.md |
| 技能系统 | ~/.claude/skills/ | 适配至 ~/.opencode-skills/ |

---

## 建议的使用频率

| 技能 | 频率 | 触发方式 |
|------|------|----------|
| agentic-radar | 每周 | 手动或定时 |
| vendor-docs-radar | 每周 | 手动或定时 |
| reflect-and-learn | 每周 | 手动或定时 |

---

## 自定义配置

创建 `~/.opencode/evolving-config.json` 来自定义：

```json
{
  "scan_frequency": {
    "agentic_radar": "weekly",
    "vendor_docs_radar": "weekly",
    "reflect_and_learn": "weekly"
  },
  "auto_apply_threshold": 7.0,
  "notification_channel": "print",
  "reports_dir": "~/.opencode"
}
```

---

## 依赖

这些技能依赖 OpenCode 的内置工具：
- `session_list` / `session_read`: 会话历史分析
- `websearch` / `webfetch`: 网页搜索和获取
- `task()`: 并行子代理执行
- `todowrite`: 任务跟踪

---

## 来源

基于 PalmDr/claude-evolving-skills 适配：
https://github.com/PalmDr/claude-evolving-skills

灵感来源：
- AFlow (ICLR 2025)
- AgentEvolver
- Live-SWE-agent
- EvoAgentX/SEW

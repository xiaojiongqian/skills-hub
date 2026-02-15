# skills-hub

统一维护 Codex 与 Claude 的 skills / commands / MCP 安装脚本。

核心目标：
- 一处维护，双端复用（Codex + Claude）
- 通过软链接立即生效，不做手工复制
- 把 Playwright/Chrome MCP 的下载、安装、配置放进脚本

## 当前内容

### Codex skills（`codex-skills/`）
- `auto-dev`
- `chrome-mcp-remote`
- `firebase-gcp-debug`
- `gh-address-comments`
- `gh-fix-ci`
- `patent-search-cn-us`

### Claude skills（`claude-skills/`）
已与 Codex 侧能力对齐并补齐关键场景：
- `auto-dev.md`（与 Codex auto-dev guardrails 对齐）
- `firebase-gcp-debug.md`
- `gh-address-comments.md`
- `gh-fix-ci.md`
- `chrome-mcp-remote.md`
- `playwright-mcp.md`

### Claude commands（`claude-commands/`）
- `openspec/apply.md`
- `openspec/archive.md`
- `openspec/proposal.md`
- `pr/merge.md`

### Scripts（`scripts/`）
- `link-local.sh`：把 skills/commands/scripts 链接到 `~/.codex`、`~/.claude`
- `install-claude-mcp.sh`：下载并配置 `playwright-mcp` + `chrome-devtools`
- `start-chrome-mcp.sh`：启动 Chrome remote debugging（默认 9223）
- `auto-dev-preflight.sh`、`auto-dev-deploy-dev.sh`：Claude 侧复用 auto-dev 脚本入口
- `gh-fetch-comments.sh`、`gh-inspect-pr-checks.sh`：Claude 侧复用 GitHub 辅助脚本

## 快速开始

### 1) 克隆

```bash
git clone https://github.com/xiaojiongqian/skills-hub.git ~/skills-hub
cd ~/skills-hub
```

### 2) 链接到本机（Codex + Claude）

```bash
bash scripts/link-local.sh
```

只链接单侧：
```bash
bash scripts/link-local.sh --codex-only
bash scripts/link-local.sh --claude-only
```

链接后可在 `~/.claude/scripts` 直接使用本仓库脚本。

### 3) 安装 Claude MCP（Playwright + Chrome）

```bash
bash ~/.claude/scripts/install-claude-mcp.sh --scope user
```

可选参数：
```bash
bash ~/.claude/scripts/install-claude-mcp.sh --scope user --chrome-port 9223
bash ~/.claude/scripts/install-claude-mcp.sh --download-only
bash ~/.claude/scripts/install-claude-mcp.sh --configure-only
```

### 4) 启动 Chrome remote debugging

```bash
bash ~/.claude/scripts/start-chrome-mcp.sh
```

### 5) 验证

```bash
claude mcp list
ls -la ~/.claude/skills
ls -la ~/.claude/scripts
ls -la ~/.codex/skills
```

## 常用命令

```bash
# 链接 + 安装 Claude MCP（一步）
bash scripts/link-local.sh --claude-only --install-claude-mcp

# 仅安装/更新 MCP 注册
bash scripts/install-claude-mcp.sh --scope user

# 检查 Codex skill frontmatter 合规
python3 ~/.codex/skills/.system/skill-creator/scripts/quick_validate.py codex-skills/auto-dev
```

## 维护说明

- 本仓库优先存放可运行的真实 skill/command/script，而非模板。
- Claude 与 Codex 的能力同步策略：先维护 Codex skill，再同步到 `claude-skills/`。
- 对于 GitHub/Firebase/Browser 自动化，优先复用 `scripts/` 中的统一入口，减少重复维护。

# skills-hub

统一维护 **通用 skills**，避免把业务逻辑硬编码进 skill 本体。
项目专属的脚本、配置和文档应放在各自项目的 `.claude/` 目录下维护，不在本仓库中管理。

## 设计原则

- 通用层（Core）：`codex-skills/`、`claude-skills/`、`claude-commands/` 只保留可复用流程与规则
- 项目层（Project）：项目专属内容放在各自项目的 `.claude/` 目录下（如 `.claude/scripts/`、`.claude/references/`、`.claude/commands/`）
- 示例层（Example）：`project-packs/example/` 提供项目扩展的模板和参考

这样可以做到：
- 技能可跨项目复用，通过 `~/.claude/` symlink 全局生效
- 业务逻辑在各自项目内独立演进，不污染通用仓库
- 新项目只需 `link-local.sh` 一次，即可使用全部通用能力

## 能力定位（跨项目）

- `claude-commands/pr/merge.md`：通用 PR 合并流程（`/pr:merge`），不绑定具体业务仓库。
- `codex-skills/auto-dev/` 与 `claude-skills/auto-dev.md`：通用自主开发流程（`auto-dev`），通过 project pack 注入项目差异。

## 仓库结构

```text
skills-hub/
├── codex-skills/                  # Codex 通用技能（不放业务硬编码）
├── claude-skills/                 # Claude 通用技能（不放业务硬编码）
├── claude-commands/               # Claude commands（通用流程）
├── project-packs/
│   └── example/                   # 示例模板（供新项目参考）
│       ├── auto-dev/infer-targets.sh
│       └── PACK.md
└── scripts/
    ├── link-local.sh              # 将通用技能 symlink 到 ~/.claude/
    ├── link-project-pack.sh       # 将 pack 注入目标仓库（可选）
    ├── install-claude-mcp.sh
    ├── start-chrome-mcp.sh
    ├── auto-dev-preflight.sh
    ├── auto-dev-deploy-dev.sh
    ├── gh-fetch-comments.sh
    └── gh-inspect-pr-checks.sh
```

## 快速开始

### 1) 克隆并链接本机技能

```bash
git clone https://github.com/xiaojiongqian/skills-hub.git ~/skills-hub
cd ~/skills-hub
bash scripts/link-local.sh
```

### 2) 项目专属配置（在各自项目内）

项目专属的脚本、参考文档和 command 放在项目自身的 `.claude/` 目录下：

```
your-project/.claude/
├── CLAUDE.md              # 项目开发规范
├── commands/              # 项目专属 command（如有）
├── skills/                # 项目专属 skill（如有）
├── references/            # 项目参考文档
├── settings.json          # 项目配置
└── memories/              # agent 记忆
```

通用的 commands 和 skills 通过 `~/.claude/` 的 symlink 自动加载，项目内不需要重复维护。

### 3)（可选）使用 project pack 模板

如果需要 CI/CD 部署映射等高级功能，可参考 `project-packs/example/` 模板：

```bash
# 查看可用 pack
bash scripts/link-project-pack.sh --list

# 将 pack 注入目标仓库
bash scripts/link-project-pack.sh --pack example --repo /path/to/target-repo
```

## MCP 安装（Claude）

```bash
bash ~/.claude/scripts/install-claude-mcp.sh --scope user
bash ~/.claude/scripts/start-chrome-mcp.sh
claude mcp list
```

## 当前已同步的 Claude 通用技能

- `auto-dev.md`
- `firebase-gcp-debug.md`
- `gh-address-comments.md`
- `gh-fix-ci.md`
- `chrome-mcp-remote.md`
- `playwright-mcp.md`

## 如何为项目添加专属配置

项目专属内容直接放在项目自身的 `.claude/` 目录下：

1. `CLAUDE.md` — 项目开发规范
2. `commands/` — 项目专属 command（不与通用 command 同名）
3. `skills/` — 项目专属 skill
4. `references/` — 项目参考文档
5. `settings.json` — 项目级配置

通用能力通过 `~/.claude/` symlink 自动加载，无需在项目内重复维护。

## 约束建议

- 不在 core skill 里写业务模块名、业务目录结构、业务部署参数
- 不在 core script 里写具体仓库 case 分支
- 项目专属内容放在各自项目的 `.claude/` 目录下，不提交到 skills-hub
- `project-packs/example/` 仅作为模板参考，不维护真实项目数据

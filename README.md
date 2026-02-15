# skills-hub

集中管理可复用的 AI Agent 能力：
- **Codex Skills**（`SKILL.md` + 可选脚本/参考资料）
- **Claude Skills / Commands**（`.claude/skills` 与 `.claude/commands` 结构）

这个仓库基于你现有环境中的真实内容整理：
- `~/.codex/skills`
- `/Users/vik.qian/study/taledraw/.claude`

目标是“一处维护，多处生效”，通过符号链接把本仓库内容挂载到本机 agent 配置目录。

## 当前已收录内容

### Codex Skills（`codex-skills/`）
- `auto-dev`：当前 worktree 内的自动开发/调试与部署流程
- `chrome-mcp-remote`：通过手动启动 Chrome remote debugging 使用 DevTools MCP
- `firebase-gcp-debug`：Firebase/GCP 故障排查（emulator、functions、logging）
- `gh-address-comments`：处理当前分支 PR 的 review comments
- `gh-fix-ci`：定位并修复 PR 的 GitHub Actions 失败检查
- `patent-search-cn-us`：中美专利检索与初步新颖性分析

### Claude Commands（`claude-commands/`）
- `openspec/apply.md`
- `openspec/archive.md`
- `openspec/proposal.md`
- `pr/merge.md`

### Claude Skills（`claude-skills/`）
- `auto-dev.md`

## 仓库结构

```text
skills-hub/
├── codex-skills/
│   ├── auto-dev/
│   ├── chrome-mcp-remote/
│   ├── firebase-gcp-debug/
│   ├── gh-address-comments/
│   ├── gh-fix-ci/
│   └── patent-search-cn-us/
├── claude-commands/
│   ├── openspec/
│   └── pr/
├── claude-skills/
│   └── auto-dev.md
├── scripts/
│   └── link-local.sh
└── README.md
```

## 快速开始

### 1) 克隆仓库

```bash
git clone https://github.com/xiaojiongqian/skills-hub.git ~/skills-hub
cd ~/skills-hub
```

### 2) 一键创建本地符号链接（推荐）

```bash
bash scripts/link-local.sh
```

可选：
```bash
bash scripts/link-local.sh --codex-only
bash scripts/link-local.sh --claude-only
```

该脚本会把本仓库内容链接到：
- `~/.codex/skills/*`
- `~/.claude/skills/*`
- `~/.claude/commands/**/*`

### 3) 验证

```bash
ls -la ~/.codex/skills
ls -la ~/.claude/skills
find ~/.claude/commands -type l | rg skills-hub
```

## 维护与更新

### 更新某个技能后

1. 在本仓库修改文件并提交
2. 因为是符号链接，已挂载的本地环境会立即使用新版本（无需复制）

### 校验 Codex Skill 格式（可选）

```bash
python3 ~/.codex/skills/.system/skill-creator/scripts/quick_validate.py codex-skills/<skill-name>
```

## 说明

- 本仓库优先保留“可运行的现有内容”，不是模板演示仓库。
- 如需新增技能，建议先参考 `~/.codex/skills/.system/skill-creator/SKILL.md` 的流程。
- 后续可以继续补充：统一安装脚本、版本标签、团队协作规范（PR 模板/发布记录）。

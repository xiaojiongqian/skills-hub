# skills-hub

统一维护 **通用 skills** 与 **项目业务扩展（project packs）**，避免把业务逻辑硬编码进 skill 本体。
`taledraw` 在本仓库中只是一个示例 project pack，用来演示接入方式，不是唯一目标项目。

## 设计原则

- 通用层（Core）：`codex-skills/`、`claude-skills/` 只保留可复用流程与规则
- 业务层（Project Pack）：`project-packs/<project>/` 存放项目特有 md、脚本、映射规则
- 注入层（Adapter）：通用脚本通过配置/钩子（infer script）加载业务逻辑

这样可以做到：
- 技能可跨项目复用
- 业务逻辑按项目独立演进
- 不同项目只替换 pack，不重写核心 skill

## 能力定位（跨项目）

- `claude-commands/pr/merge.md`：通用 PR 合并流程（`/pr:merge`），不绑定具体业务仓库。
- `codex-skills/auto-dev/` 与 `claude-skills/auto-dev.md`：通用自主开发流程（`auto-dev`），通过 project pack 注入项目差异。

## 仓库结构

```text
skills-hub/
├── codex-skills/                  # Codex 通用技能（不放业务硬编码）
├── claude-skills/                 # Claude 通用技能（不放业务硬编码）
├── claude-commands/               # Claude commands
├── project-packs/
│   ├── taledraw/                  # 示例 pack（案例）
│   │   ├── auto-dev/infer-targets.sh
│   │   ├── firebase/references/repo-shortcuts.md
│   │   └── PACK.md
│   └── <your-project>/            # 其他项目按同结构扩展
└── scripts/
    ├── link-local.sh
    ├── link-project-pack.sh
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

### 2) 给目标项目注入 project pack（关键）

```bash
# 查看可用 pack
bash scripts/link-project-pack.sh --list

# 将指定 pack 链接到目标仓库
bash scripts/link-project-pack.sh --pack <pack-name> --repo /path/to/target-repo

# 示例：使用 taledraw pack（仅案例）
bash scripts/link-project-pack.sh --pack taledraw --repo /path/to/target-repo
```

执行后，目标仓库会出现：
- `/path/to/target-repo/.skills-hub/auto-dev/infer-targets.sh`
- `/path/to/target-repo/.skills-hub/firebase/...`

### 3) 在目标仓库运行通用部署脚本

```bash
cd /path/to/target-repo
bash ~/.claude/scripts/auto-dev-deploy-dev.sh --wait
```

`auto-dev-deploy-dev.sh` 会优先读取：
- `AUTO_DEV_INFER_SCRIPT`（若显式设置）
- 或 `<repo>/.skills-hub/auto-dev/infer-targets.sh`

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

## 如何新增一个项目 pack

1. 新建目录：`project-packs/<project>/`
2. 放入业务内容：
   - `auto-dev/infer-targets.sh`（变更文件 -> workflow inputs 的映射）
   - `firebase/references/*.md`（项目专项文档）
   - 其他业务脚本/文档
3. 用 `scripts/link-project-pack.sh` 注入到目标仓库 `.skills-hub/`

## 约束建议

- 不在 core skill 里写业务模块名、业务目录结构、业务部署参数
- 不在 core script 里写具体仓库 case 分支
- 业务规则一律放 project pack，并通过 hook/config 注入

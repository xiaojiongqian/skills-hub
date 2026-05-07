# skills-hub

公开发布的通用技能仓库，采用 `skills/<name>/SKILL.md` 标准目录结构，目标是：

1. 现有 skill 能被多种 agent 使用。
2. 发布到 GitHub 后，别人可以直接运行 `npx skills add xiaojiongqian/skills-hub` 安装整仓技能。
3. skill 更新后，使用者可以通过 `npx skills check` / `npx skills update` 快速同步。

## 安装

整仓安装：

```bash
npx skills add xiaojiongqian/skills-hub
```

常用变体：

```bash
# 全局安装到用户级目录
npx skills add xiaojiongqian/skills-hub -g

# 仅安装指定 skill
npx skills add xiaojiongqian/skills-hub --skill auto-dev

# 先查看仓库中可安装的 skill
npx skills add xiaojiongqian/skills-hub --list
```

## 安装机制

- `npx skills add` 会先发现仓库中的标准 skill，然后安装到你选择的 agent 和范围（project 或 global）。
- 默认推荐安装方式是 `symlink`：
  - 先写入一份公共 canonical skill 目录
  - 再让具体 agent 复用这份内容；非 universal agent 通常通过软链接接入
- 如果使用 `--copy`，则会为每个目标 agent 写入独立副本，而不是共享同一份 skill 内容。
- 当本机有多个已支持的 agent 时，CLI 会探测并安装到你选择的 agent；未被官方 CLI 支持的 agent 不会自动安装。
- 同名 skill 在同一安装范围内会被覆盖更新；不同名 skill 不受影响。

## 更新

仓库维护者只需要更新 `skills/` 下对应 skill，然后提交：

```bash
git add skills README.md scripts .github
git commit -m "Update skills"
git push
```

使用者更新已安装技能：

```bash
npx skills check
npx skills update
```

这就是当前推荐的快速更新机制，不需要重新手动 clone 或重新配置 agent 目录。

对小说 skill，仓库还包含一条自动化约定：

- PR 到 `main` 时，`.github/workflows/novel-skills-pr-check.yml` 会校验 `novel-orchestrator-main` 的 skill frontmatter。

## 仓库结构

```text
skills-hub/
├── skills/                         # 标准 multi-skill 发布目录
│   ├── auto-dev/
│   │   ├── SKILL.md
│   │   └── scripts/
│   ├── design-eye/
│   ├── eng-lead/
│   ├── firebase-gcp-debug/
│   ├── find-skills/
│   ├── gh-address-comments/
│   ├── gh-fix-ci/
│   ├── gh-issue-autodev/
│   ├── git-pr-merge/
│   ├── git-sync-dev-submodules/
│   ├── jina-web-fetch/
│   ├── novel-orchestrator-main/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   └── references/
│   │       └── novel-system/       # 小说创作、续作、状态和质量闭环资料
│   ├── patent-search-cn-us/
│   ├── playwright/
│   ├── playwright-interactive/
│   ├── smoke-test/
│   ├── system-architect/
│   └── test-philosophy/
├── project-packs/                  # 项目专属扩展示例
└── scripts/                        # 本仓库维护和本地兼容入口
```

`skills/` 是唯一真源目录。每个技能都放在独立子目录内，并且至少包含：

- `SKILL.md`：YAML frontmatter + Markdown instructions

常见的可选子目录包括：

- `scripts/`：需要一起分发的可执行脚本
- `references/`：按需加载的参考资料
- `agents/openai.yaml`：可选的 UI 元数据

`novel-orchestrator-main/references/novel-system/` 是小说 skill 的唯一 reference namespace，用来收口：

- 路由规则
- 交互契约与 schema
- 项目模板
- 写作与审计参考
- 开放式续作和滚动规划
- 多席位质量闭环

## 当前包含的 Skills

- `auto-dev`
- `design-eye`
- `eng-lead`
- `firebase-gcp-debug`
- `find-skills`
- `gh-address-comments`
- `gh-fix-ci`
- `gh-issue-autodev`
- `git-pr-merge`
- `git-sync-dev-submodules`
- `jina-web-fetch`
- `novel-orchestrator-main`
- `patent-search-cn-us`
- `playwright`
- `playwright-interactive`
- `smoke-test`
- `system-architect`
- `test-philosophy`

## 第三方来源说明

以下 skills 迁移自 `NatureBlueee/Nature-use-skills`：

- `design-eye`
- `eng-lead`
- `system-architect`
- `test-philosophy`

来源仓库：`https://github.com/NatureBlueee/Nature-use-skills`

原始许可：MIT License，`Copyright (c) 2026 Nature`

## 使用说明补充

- `auto-dev`
  - GitHub Actions deploy 现在以远端 `origin/<current-branch>` 为准推断部署目标，不再把本地未推送的提交算进去。
  - 默认用 `origin/main` 作为 diff 基线；如果仓库没有 `origin/main`，则回退到 `origin/HEAD`，也支持手动传 `--diff-base`。
  - 显式传入的 `--workflow` 或 `AUTO_DEV_WORKFLOW` 优先级最高，不会再被 infer script 静默覆盖。
  - `--wait` 现在会盯住本次刚 dispatch 的 workflow run，而不是分支上“最新的一条” run。
  - 在 `skills-hub` 仓库上操作 `main` 仍然是特例，但现在需要显式确认 token：`AUTO_DEV_ALLOW_SKILLS_HUB_MAIN=skills-hub-main-confirmed`。

- `git-pr-merge`
  - 更推荐在 Claude 中使用。原因是 Claude 环境更容易直接调用其内部的 `code-reviewer` 和 `code-simplifier` 一类 review/simplify 能力，对中大型 PR 的预审更强。
  - 在其他 agent 中也能使用，但会回退到 skill 自带的 review/simplify prompts，而不是直接复用 Claude 内部能力。

- `playwright` / `playwright-interactive`
  - 这两个 skill 现在是浏览器自动化的主路径，会随着 `scripts/link-local.sh` 一起安装到 Codex 和 Claude。
  - `playwright` 适合一次性、可复现的终端浏览器流程。
  - `playwright-interactive` 适合持久会话、反复 reload、本地迭代和 Electron 调试；它要求当前 agent 具备持久 JavaScript REPL 能力。

## 发布规范

- 公开仓库即可，安装入口使用 GitHub 仓库地址语义：`owner/repo`
- 每个 skill 目录使用 `skills/<name>/SKILL.md`
- `SKILL.md` 顶部保留 YAML frontmatter，至少包含 `name` 和 `description`
- 本仓库通常补充 `license`，并按需补充 `metadata` 等兼容字段；不要假设所有 agent 都接受自定义 frontmatter key
- skill 内引用脚本时，优先写成 `<path-to-skill>/scripts/...` 这种 agent 无关路径提示，不绑定 `~/.claude` 或 `~/.codex`
- Claude Code 安装后直接使用标准 skill 名称，例如 `/git-pr-merge`

## 本地开发

如果你在本机直接维护这个仓库，可以继续使用本地链接脚本：

```bash
git clone https://github.com/xiaojiongqian/skills-hub.git ~/skills-hub
cd ~/skills-hub
bash scripts/link-local.sh
```

这个脚本会把 `skills/` 下的标准技能链接到本地 agent 目录，并链接仓库里的辅助脚本。

## 项目专属扩展

通用 skill 不应内置业务仓库信息。项目专属脚本、参考文档和映射规则，建议继续放在具体项目自己的目录中维护，例如：

```text
your-project/.claude/
├── CLAUDE.md
├── commands/
├── skills/
├── references/
└── settings.json
```

如果需要 project pack 模板，可参考 `project-packs/example/`，并使用：

```bash
bash scripts/link-project-pack.sh --list
bash scripts/link-project-pack.sh --pack example --repo /path/to/target-repo
```

## 维护建议

- 只在 `skills/` 下维护 skill 真源，不再新增平行的 agent 专属 skill 副本
- skill 的业务差异放到项目侧，不硬编码进通用 skill
- 对 Claude Code、Codex、Cursor 等 agent，一律复用同一套 `skills/` 内容，不再维护单独的 `claude-skills/` 或 `claude-commands/`
- 每次修改后至少运行一次 `npx skills add xiaojiongqian/skills-hub --list` 或本地等价命令，确认仓库仍可被 CLI 识别

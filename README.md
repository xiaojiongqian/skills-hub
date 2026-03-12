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

## 更新

仓库维护者只需要更新 `skills/` 下对应 skill 并推送到 GitHub：

```bash
git add skills README.md scripts
git commit -m "Update skills"
git push
```

使用者更新已安装技能：

```bash
npx skills check
npx skills update
```

这就是当前推荐的快速更新机制，不需要重新手动 clone 或重新配置 agent 目录。

## 仓库结构

```text
skills-hub/
├── skills/                         # 标准 multi-skill 发布目录
│   ├── auto-dev/
│   │   ├── SKILL.md
│   │   └── scripts/
│   ├── chrome-mcp-remote/
│   ├── firebase-gcp-debug/
│   ├── gh-address-comments/
│   ├── gh-fix-ci/
│   ├── git-pr-merge/
│   ├── git-sync-dev-submodules/
│   ├── jina-web-fetch/
│   ├── patent-search-cn-us/
│   └── playwright-mcp/
├── project-packs/                  # 项目专属扩展示例
└── scripts/                        # 本仓库维护和本地兼容入口
```

`skills/` 是唯一真源目录。每个技能都放在独立子目录内，并且至少包含：

- `SKILL.md`：YAML frontmatter + Markdown instructions
- `scripts/`：需要一起分发的可执行脚本
- `references/`：按需加载的参考资料
- `agents/openai.yaml`：可选的 UI 元数据

## 当前包含的 Skills

- `auto-dev`
- `chrome-mcp-remote`
- `firebase-gcp-debug`
- `gh-address-comments`
- `gh-fix-ci`
- `git-pr-merge`
- `git-sync-dev-submodules`
- `jina-web-fetch`
- `patent-search-cn-us`
- `playwright-mcp`

## 发布规范

- 公开仓库即可，安装入口使用 GitHub 仓库地址语义：`owner/repo`
- 每个 skill 目录使用 `skills/<name>/SKILL.md`
- `SKILL.md` 顶部保留 YAML frontmatter，至少包含 `name` 和 `description`
- 本仓库统一补充了 `version` 和 `license`，便于发布和后续维护
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

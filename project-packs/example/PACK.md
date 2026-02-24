# Example Project Pack

本目录是 project pack 的示例模板，用于演示如何为特定项目扩展通用 skill 的能力。

**重要**：project pack 仅作为示例和参考。实际项目的专属脚本、配置和文档应放在各自项目的 `.claude/` 目录下维护，不应提交到 skills-hub。

## 目录结构示例

```
project-packs/example/
├── auto-dev/
│   └── infer-targets.sh      # 将文件变更映射为 CI/CD workflow 输入
├── references/
│   └── repo-shortcuts.md      # 项目仓库结构与本地调试快捷命令
└── PACK.md                    # 本文件
```

## 如何为你的项目创建 pack

1. 复制本目录为 `project-packs/<your-project>/`
2. 按项目需求修改 `infer-targets.sh` 中的模块映射逻辑
3. 添加项目专属的参考文档到 `references/`
4. 使用 `link-project-pack.sh` 注入到目标仓库：
   ```bash
   bash scripts/link-project-pack.sh --pack <your-project> --repo /path/to/repo
   ```

## 推荐做法

对于长期维护的项目，建议将专属脚本直接放在项目自身的 `.claude/` 目录下：

```
your-project/.claude/
├── CLAUDE.md              # 项目开发规范
├── commands/              # 项目专属 command（如有）
├── skills/                # 项目专属 skill（如有）
├── references/            # 项目参考文档
└── settings.json          # 项目配置
```

通用的 commands 和 skills 通过 `~/.claude/` 的 symlink 从 skills-hub 加载，项目内不需要重复维护。

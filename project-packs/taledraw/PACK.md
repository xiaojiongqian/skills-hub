# TaleDraw Project Pack (Example)

本目录仅放 TaleDraw 业务相关内容，供通用 skills 通过配置/脚本注入。
它是 `skills-hub` 的示例案例，用于演示 project pack 机制；其他项目可按同结构新增自己的 pack。

## Contents
- `auto-dev/infer-targets.sh`: 将文件变更映射为 `dev.yml` workflow 输入。
- `firebase/references/repo-shortcuts.md`: TaleDraw 仓库结构与本地调试快捷命令。

## Usage
1. 在目标仓库下放置链接：
   - `.skills-hub/auto-dev/infer-targets.sh` -> 本文件
2. 执行通用脚本：
   - `AUTO_DEV_INFER_SCRIPT=.skills-hub/auto-dev/infer-targets.sh bash ~/.claude/scripts/auto-dev-deploy-dev.sh --wait`

推荐直接使用仓库根脚本：
- `bash scripts/link-project-pack.sh --pack taledraw --repo /path/to/target-repo`

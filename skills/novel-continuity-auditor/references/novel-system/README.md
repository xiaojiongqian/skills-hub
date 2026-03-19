# novel-system

长篇小说 skill 家族的共享文档命名空间。
这里不是可安装 skill；这里存放的是所有 `novel-*` skills 共用的公共契约、模板和参考资料。

这里是唯一真源。
各个子 skill 下的 `references/novel-system/` 都是由 `scripts/sync_novel_skills.py` 生成的分发副本，不手工维护。

`novel-orchestrator-main` 自己的系统级说明已移到同级目录 `references/orchestrator-system/`，
不再作为共享副本分发给各个子 skill。

## Read Order

1. `routing.md`
2. `contracts.md`
3. `context-model.md`
4. `conventions.md`

按需继续读取：

- `schemas/`
  - 查看正式输入输出与实体契约
- `templates/`
  - 初始化小说项目文件
- `references/`
  - 查看写作、张力、审计、对白和上下文卫生指导

## Layout

- `routing.md`
  - 任务路由、串并行策略和标准工作流
- `contracts.md`
  - 契约体系总说明和版本规则
- `context-model.md`
  - 渐进式披露和上下文分层
- `conventions.md`
  - 文件职责、命名、canon 准入和写回规则
- `schemas/`
  - TaskEnvelope、ContextBundle、ArtifactResult、ChangeSet 与核心实体 schema
- `templates/`
  - 项目初始化模板
- `references/`
  - 可按需加载的创作与审计参考
- `skills/novel-orchestrator-main/references/orchestrator-system/`
  - 仅存在于主 skill 真源中的本地系统说明，不会被复制到子 skill

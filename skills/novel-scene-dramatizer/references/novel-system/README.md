# novel-system

长篇小说 skill 家族的共享架构文档命名空间。
这里不是可安装 skill；这里存放的是所有 `novel-*` skills 共用的系统说明、契约、模板和参考资料。

这里是唯一真源。
各个子 skill 下的 `references/novel-system/` 都是由 `scripts/sync_novel_skills.py` 生成的分发副本，不手工维护。

## Read Order

1. `overview.md`
2. `architecture.md`
3. `routing.md`
4. `contracts.md`
5. `context-model.md`
6. `conventions.md`

按需继续读取：

- `schemas/`
  - 查看正式输入输出与实体契约
- `templates/`
  - 初始化小说项目文件
- `references/`
  - 查看写作、张力、审计、对白和上下文卫生指导

## Layout

- `overview.md`
  - 系统目标和总原则
- `architecture.md`
  - 主 skill、子 skill 和全局状态职责
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

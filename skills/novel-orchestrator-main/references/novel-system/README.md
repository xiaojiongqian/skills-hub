# novel-system

长篇、系列小说 skill 的参考资料命名空间。
这里不是可安装 skill；这里存放 `novel-orchestrator-main` 按需加载的契约、模板、schema、创作参考和质量闭环说明。

这里是唯一 reference namespace。不要再拆出第二套系统说明或复制出多个 novel reference 副本。

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
  - 处理 sub-agent 超时与降级执行时，额外读取 `references/execution-reliability.md`
  - 处理高质量章节闭环时，额外读取 `references/quality-council.md`

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
- `references/execution-reliability.md`
  - sub-agent 粒度、超时恢复、降级执行和质量保护规则
- `references/quality-council.md`
  - 多席位质量评分、修复派工、counterforce 和收敛规则

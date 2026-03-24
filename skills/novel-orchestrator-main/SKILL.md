---
name: novel-orchestrator-main
description: 长篇小说工程主调度与共享真源宿主。用于把长篇小说项目当作有状态、可持续维护的创作工程来推进：识别当前任务属于规划、生成、审计还是状态同步；决定最小上下文加载；安排串行或并行步骤；协调 novel-bible-manager、novel-plot-architect、novel-scene-dramatizer、novel-dialogue-editor、novel-continuity-auditor、novel-chapter-summarizer 等子 skill；校验契约并统一写回 INDEX.md、CURRENT_STATE.md、OPEN_LOOPS.md、FORESHADOWS.md、CHARACTER_ARCS.md、RECENT_EVENTS.md 等文件。它还作为共享 novel-system 资料的唯一真源。当用户提到长篇小说策划、章节推进、设定维护、连续性检查、章节摘要、伏笔追踪或状态同步时触发。
---

# 长篇小说主调度

## Overview

将小说项目视为“正文文件 + 状态文件”的双轨系统。
把自己视为唯一的全局状态协调者：解释任务、裁剪上下文、安排子 skill、汇总结果、决定写回。

但默认优先级始终是：

1. 先写出好读、像小说的正文
2. 再考虑流程工件、状态沉淀和多 skill 协作

不要为了流程完整性牺牲小说成品质量。
不要让章节看起来像是被 workflow 生产出来的。

## Readability Before Technique

把下面这条当成总开关，而不是修辞建议：

- 先把事情交代清楚、让读者轻松跟上，再谈气氛、文笔、结构花样和其它技巧
- 读者应能顺着正文很快回答：谁在场、此刻卡在什么门槛、发生了什么、局面怎么变了
- 如果一种写法更“高级”但更难读、更像摘要拆装或更像作者设计展示，直接不用
- 如果一句话同时塞进时间、层级、结果、评价四件事，优先拆成两到三句，不要把理解压力推给读者回读
- 如果清楚交代与技巧性表达发生冲突，永远先保清楚交代
- 能直接点名就直接点名，不要让关键指代停留在“那个名字”“旧比较”“这条线”“这种级别”这类含混说法里
- 章末不要用“门、灯、路、名字”之类隐喻代替章节结论；直接写清这章推进了什么、还没解决什么
- 但“清楚”不等于把正文压平；在事实链已经顺的时候，应继续追求场面感、互动感和句子张力
- 所有子 skill 的调用和取舍，都应先服从这条规则

## Use Heuristics, Not Templates

这些规则默认是高优先级启发式，不是机械打卡表。

- 不要为了满足规则表面，把每一章都写成同一种形状
- 不要为了凑“互动单元”“主角开口”“章末余波”而硬塞不自然的句子
- 一个章节可以靠 1 个非常强的主场面成立，不必机械追求平均分布的 3 到 5 个场面
- 一个章节也可以主要写等待、恢复、适应、观察，只要等待本身被写成了有压力的事件过程
- 如果某条规则的执行结果让正文更像施工说明、更像模板作文，优先打破那条规则，保住成品自然度
- 判断标准始终回到成品：读者是不是更容易读、更愿意读、也更记得住

## Keep the Route Visible

对成长线、传记线、比赛线章节，默认再加一条硬要求：

- 读者应在前 1 到 2 段内知道现在是哪一年 / 哪个赛季 / 哪一级队伍 / 哪类比赛
- 如果人物在不同梯队、队伍或层级之间移动，要至少用一次最朴素的方式把梯子说清
  - 例如 `U19B -> U19A -> 巴萨C -> 巴萨B -> 一线队`
- 不要假设读者记得上一章的层级关系、赛制关系或位置变化
- 如果是两回合淘汰赛，必须写清：首回合结果、次回合任务、关键变故、总比分结果
- 如果是成长节点，章末至少要让读者明确两件事：
  - 这章跨过了哪一道门
  - 哪个更慢的问题还没有解决

如果一章单看时读者不能快速复述“人现在在哪一层、刚跨过哪道门、为什么还没站稳”，它通常仍然会像摘要。
但这条要求也不意味着章首必须机械报菜名式交代；能把时间、层级和门槛自然压进场面，就不要写成说明书。

把 `references/novel-system/` 视为小说 skill 家族的共享真源。
子 skill 的本地 `references/novel-system/` 副本应由同步脚本生成，不要手工分别维护。
把 `references/orchestrator-system/` 视为只属于主调度自己的本地系统说明，不参与子 skill 分发。

## Treat the Project as a Stateful System

始终优先回答这几个问题：

1. 当前任务属于哪一类：规划、生成、审计、状态同步、还是状态修复。
2. 当前需要最少哪些上下文：入口状态、相关状态、静态设定、局部原文。
3. 当前步骤是否依赖上一步产物。
4. 当前结果是否足以安全写回。

不要把长篇创作当成一次次独立对话。
不要把正文当成唯一真源。
不要让子 skill 直接决定全局状态。

但也不要反过来让状态系统压倒正文。
状态文件是为了帮助后续写作，不是为了提前规定正文必须长成什么样。

## Keep the Frame Soft

长篇项目需要框架，但框架默认是弱约束，不是硬模板。

始终记住：

- arc 功能、章节标题、当前冲突和 open loops 只是导航，不是判决
- 早期 plan 只需要给出方向，不要过早把章节意义、主题结论和镜头安排全部锁死
- 如果正文写到一半发现更自然、更有小说感的重心，优先调整 plan，而不是强迫正文服从旧框架
- 如果一个章节 promise 说得太满，正文往往只剩“执行 promise”，而不是“讲故事”
- 标题应服务章节，不应反过来逼章节替标题做证明

## Read Context Progressively

默认按四层加载上下文，只在必要时向下展开：

1. 项目入口层：`INDEX.md`、`CURRENT_STATE.md`
2. 相关状态层：`OPEN_LOOPS.md`、`CHARACTER_ARCS.md`、`RECENT_EVENTS.md`、`ARC_STATUS.md`
3. 静态设定层：`WORLD.md`、`CHARACTERS.md`、`FACTIONS.md`、`LOCATIONS.md`、`RULES.md`、`THEMES.md`、`STYLE_GUIDE.md`
4. 正文局部层：当前章节、相邻章节、相关章节摘要、场景草稿

优先提供命名上下文块，而不是整段散装文本。
优先提供摘要、条目和结构化状态，而不是大量原文。
如果某个子 skill 只需要最近两章摘要，不要给整卷正文。

## Route by Task Type

按下面的职责边界路由：

- `novel-bible-manager`
  - 维护世界观、角色、规则、势力、时间线、静态设定与动态状态条目
- `novel-plot-architect`
  - 规划卷纲、arc、章纲、场景 beat、冲突升级、信息揭示、伏笔布置
- `novel-scene-dramatizer`
  - 将已批准的规划扩成场景或章节草稿，强化动作、阻力、选择与代价
- `novel-dialogue-editor`
  - 打磨对白、区分角色声音、增强潜台词和对白中的冲突
- `novel-continuity-auditor`
  - 审计时间线、设定、动机、知识边界、开放回路和跨章节连续性
- `novel-chapter-summarizer`
  - 生成章节摘要、最小可传递上下文、状态变化和写回草案

如果一个任务同时要求“生成新内容”和“判断它是否合理”，先生成，再审计。
如果一个任务可以拆成多个互不污染的分析维度，允许并行分析，但统一汇总后再决定写回。

## Set the Chapter Promise First

在进入章节工作流前，先用 `references/novel-system/references/story-engine.md` 做一次内部检查：

- 本章的 `disturbance` 是什么
- 谁在 `pursuit`
- 压力如何 `escalation`
- 哪个节点构成 `irreversible turn`
- 章末留下什么 `residue`

如果这五项说不清，本章大概率还不该直接扩写，应先回退给 `novel-plot-architect`。

但 chapter promise 只要“够用”，不要“过满”。
它的作用是找到进入点和压力线，不是提前写出章节评论。

对“真实事件骨架上的小说化章节”，再额外补齐四个问题：

- 本章的 `primary scene` 是哪一个具体时刻、物件或比赛节点
- 本章的 `pressure line` 如何从开头一路压到章末
- 哪些内容只是 `bridge facts`，只负责跨时间，不能接管正文
- 章末留下的 `scene residue` 是否仍然挂在这个场面链上

再补四个段落级问题：

- 哪个 `entry anchor` 会把读者直接带进场面
- 哪个 `interaction unit` 会让人物和人物 / 人物和物件真的发生作用
- 哪个 `voice pin` 会用来源可追溯的短话语、回望或转述把主角主观线钉住
- 哪个 `exit pressure` 会迫使段落把压力往下一段推

如果说不出这四项，本章通常还停在事实链，不该直接进入正文层。

如果四项都能说，却说得像论文摘要、创作说明或过度精密的施工图，也要回退简化。
章节在起草前通常只需要一个清楚的场面支点、一条压力线和一个大致余波，不需要过早过细地解释“本章意义”。

## Build a Scene Chain, Not a Fact Chain

把“场面链”当成非虚构章节的基本单位，而不是把事实按时间顺序排出来。

默认要求：

- 开头优先落进一个可见时刻，而不是先下判断、先做总评、先讲背景
- 每章至少有一个可单独复述的场面支点，最好带明确时间、地点、人物、物件或比分锚点
- 中段的桥接段只能负责压缩时间、搬运必要事实、继续加压，不能代替场面本身
- 章内 2 到 4 个硬节点必须形成因果推进，而不是互不咬合的资料点串联
- 结尾优先留下事件余波、处境变化或门槛变化，不用主题总结句收口

对“真实骨架小说”写法，特别检查这些失误：

- 开头像百科条目、人物简介或赛季前情提要
- 段落主要在报告“发生过什么”，却不让读者感觉“此刻正在发生什么”
- 一章里每段都承担同样功能，导致节奏像平均分配的信息块
- 明明有强场面，却被统计、判断、解释或总结挤到后面
- 章节可以轻易改写成时间线条目而几乎不损失信息，这通常说明它还不是小说化叙事

关于章节时间顺序，默认规则是：

- 成长线、纪实骨架和传记向章节优先顺叙
- 如果不用倒叙、插叙也能成立，就不要为了“结构感”硬打乱时间线
- 短章节里尤其避免局部来回折返；这种写法常会抬高理解门槛，却不一定换来更强效果
- 只有当非线性结构能明显提高戏剧压力、信息揭示或章末余波时，才允许使用
- 一旦使用非线性结构，必须让读者很快知道“现在是什么时间、刚才跳回的是哪一段”

安全的场面强化方式是：

- 用公开可核验的时间点、换人、名单、比分、物件、动作顺序组织段落
- 让阻力通过制度、身体、时间差、门槛、位置变化体现在事件表面
- 保持主事件、时间点、结果和关系主轴稳定，不让新增细节改写主要事实判断
- 把硬节点写成 `anchor -> reaction -> pressure shift -> residue` 的小型场面单元，而不是事实解释段

## Add a Safe Texture Layer

“真实骨架小说”允许增加“低风险细节层”和“低风险连接层”，前提是这些内容只让场面更可见、更可读，不改写主事件判断。

可用细节类型：

- 已有公开来源直接给出的物件、空间、服装、号码、面具、换人牌、看台、拐杖、楼梯、走廊、吧台、旧楼、球门、名单
- 由公开锚点自然带出的微动作，例如摊开餐巾纸、举起换人牌、把名字写进名单、摘下面具、走回看台、开始热身
- 已有来源点名的人际表面互动，例如谁帮助适应、谁照料、谁把人叫去热身、谁在同一空间里反复出现
- 已有公开来源中的短话语、转述和评价，例如回忆里的提醒、教练当场听到的一句反应、公开采访中的一句判断
- 已有公开来源中的 bounded interiority，例如人物后来回望这一阶段时说过的感受、选择和犹豫
- 不改变主要事实的轻度小说化连接，例如简短招呼、反问、玩笑、劝说、沉默、视线回避、停顿、动作接续
- 不改变主要事实的轻度心理连接，例如犹豫、发紧、松一口气、憋着一股劲、不肯退回去

使用规则：

- 细节必须服务当前段落的推进，不只是装饰
- 细节优先落在手、脚、视线、物件、空间转换、名单变化、比分变化这些可观察层
- 每段只要一到两个有效细节，不要堆砌形容词
- 细节不能制造新的因果链，不能偷偷补完整段缺失事实

禁止把以下内容伪装成“无伤大雅细节”：

- 未证实的天气、气味、声浪、看台反应、表情解读
- 会改写主要事件判断的关键对话、关键心理、关键决定过程
- 会改变读者对人物关系、决定过程、比赛过程理解的新增信息

关于心理活动，默认规则是：

- 优先写与处境相容、不会改写主事件判断的心理方向
- 优先把心理压在动作、选择、停顿和短句里
- 不要直接制造会锁死人物命运解释的绝对句
  - 例如“他此刻已经看见自己终将成为谁”这类过满句

如果用户明确要求“更有小说感”，优先增加以下四类互动单元，而不是先堆形容词：

- `warning`
  - 有人提醒、劝告、挖苦、照看
- `reaction`
  - 人对物件、阻力、名单、身体、时间差作出立刻反应
- `retrospective line`
  - 后来的公开回忆、评价或一句话，把此前场面重新钉住
- `fictional connective line`
  - 不改变主事件判断的短句、问答、玩笑或顶嘴，用来让人物到场

如果用户明确要求“写厚 / 写厚一点 / 第二轮加厚”，默认把任务解释为一次 `interaction-density pass`，而不是背景扩写：

- 每章通常应补到 2 个真正改变段落重心的互动单元
- 一般应至少有 1 个互动单元由主角正面回应、拒绝、追问、确认或顶回去
- 优先补短对白、即时反应、动作接触和门槛前后的停顿
- 不要主要靠补背景、解释、总结和履历信息来增厚篇幅
- 如果加厚后仍可轻易改写成时间线条目，说明还没到位，应继续回到 scene pass

但不要把这组要求执行成僵硬配额：

- 如果一整章基本由一个持续主场面支撑，1 条持续而饱满的互动链也可以成立
- 如果主角在这一章的最佳状态是沉默、观察、忍耐或被动承压，可以用动作反应、停顿和短心理线代替硬性多次开口
- “写厚”的目标是增加读者的贴身感，不是增加可计数单元

优先顺序是：

1. 不改写主要事实判断的有效对白 / 转述 / 短句
2. 人际动作
3. 物件与空间的可见细节

不要反过来先堆景物词。

默认把每个硬节点至少写出下面三项中的两项：

- 一个可拍到的场面锚点
- 一个互动动作或即时反应
- 一个来源可追溯的回望短句 / 转述 / bounded interiority

如果三项长期都缺，正文通常会退化成资料串联。

如果章节以单一主角为核心，默认再加一条硬要求：

- 全章优先安排至少一次 `protagonist voice pin`
  - 让主角自己开口，哪怕只是短对白、极短转述、自由间接引语或一句掐得住的心里话

如果主角全章始终不开口，读者通常只会听见旁白，而不会听见人物本人。
但如果强行加一句台词反而让人物失真，应先考虑自由间接引语、动作反应或短心理线。

但不要把这条要求误执行成来源说明腔。默认规则是：

- source / truth-boundary 约束放在工作层
- 正文里优先消化成场面中的对白、自由间接引语、人物判断或动作反应
- 除非戏剧上不可替代，不要频繁写“后来回忆”“后来说过”“公开表示”这类 provenance 提示

如果一句话删掉 provenance 提示后更像小说，通常就该删。

对体育、比赛、杯赛淘汰制章节，再额外检查一层 `competition clarity`：

- 读者不应靠足球常识脑补赛制和结果
- 必须交代清楚这是哪一轮、首回合还是次回合、当前比分或总比分会把局面带到哪里
- 如果人物受伤，默认交代到“什么部位、是在什么动作或阶段出问题、直接后果是什么”
- 如果球队“过关”或“出局”，默认写清它是靠什么比分、总比分或赛果完成的
- 不要只写气氛、压力和象征，不写比赛结构本身

再额外检查一层 `panorama clarity`：

- 如果章与章之间跳了几个月、几年、一个赛季或一个梯队，默认在章首或转场处明说
- 读者不应靠自己拼接，才知道人物此刻已经从哪一级走到哪一级
- 每个硬节点尽量交代到 `before -> trigger -> process -> result -> aftermath`
- 如果正文只写到了其中两三项，读者很容易觉得“事情突然发生”“结果突然落下”
- 尤其是成长线章节，先把这条路目前走到哪里说清楚，再谈场面气氛和写法巧劲

## Prefer Serial, Use Parallel Deliberately

默认串行。
只在共享同一输入快照、且不会相互覆盖状态时并行。

必须串行的常见链路：

1. 读取当前状态
2. 生成章纲或场景计划
3. 扩写正文
4. 审计连续性 / 角色 / 张力
5. 修订正文
6. 生成章节摘要
7. 更新状态文件

适合并行的常见链路：

1. 对同一草稿并行执行“连续性审计”“角色一致性审计”“对白诊断”
2. 对同一章纲并行提出多个场景方案
3. 对同一章节草稿并行输出多个分析维度的风险清单

并行阶段只产出分析、候选方案或诊断。
最终整合和写回始终由你完成。

## Use Contract-First Coordination

所有子 skill 输入输出都必须遵守统一契约。
使用 `references/novel-system/contracts.md` 和 `references/novel-system/schemas/` 里的 envelope、context bundle、artifact result、change set 和实体 schema。

最少校验这些字段：

- `schema_version`
- `contract_version`
- `task_id`
- `task_type`
- `agent_role`
- `status`
- `artifacts`
- `diagnostics`
- `recommendations`
- `proposed_writebacks`
- `execution`

遇到以下情况时，不要直接写回：

- 缺少必填字段
- `status` 为 `blocked`、`invalid` 或 `needs_review`
- 产物和诊断互相矛盾
- 写回目标超出允许列表
- 子 skill 引入了未获授权的新设定

优先重试、修复结构，或重新缩小上下文。

## Run the Standard Chapter Workflow

默认先使用轻量模式，而不是完整工程模式。

轻量模式通常就够用：

1. 读取 `CURRENT_STATE.md`、`RECENT_EVENTS.md` 和相邻章节
2. 找到一个场面支点、一条压力线和 3 到 5 个足够写的 beats
3. 直接写正文
4. 做一次自审
   - 是否顺读
   - 是否像小说而不是摘要
   - 是否有过早定框架的痕迹
5. 只有在正文已经站住以后，才补摘要和状态同步

只有在以下情况之一成立时，再切换到完整 workflow / 多 skill 模式：

- 用户明确要求流程工件、审计记录或严格状态管理
- 章节特别复杂，单代理很难同时兼顾结构、连续性和状态同步
- 项目已有自动 runner，且当前任务确实依赖它

不要把完整 workflow 当成默认礼仪。
不要在本来可以直接写好的章节上强行套一整套工艺流程。

对“推进一个章节”这类高频任务，使用这条默认工作流：

1. 从 `INDEX.md` 和 `CURRENT_STATE.md` 定位当前写作位置
2. 裁剪相关状态和必要设定
3. 调用 `novel-plot-architect` 产出章纲或 scene beats
4. 调用 `novel-scene-dramatizer` 产出场景或章节草稿
5. 检查正文表面是否泄漏作者工作台
   - 不允许出现“本章要写什么”“下一章会怎样”“如果说前一章”“根据某资料/回顾”“这里值得写的是”这类规划语、解释语、资料提示语
   - 如果是纪实 / 现实向写法，把来源事实吸收进叙事表面，来源单列到状态文件或 source 清单，不写进正文
   - 同时检查正文是否被总结句、评论句和抽象判断压过了具体事件
   - 同时检查语言是否顺读，是否频繁依赖空心过桥句、模板化对照句和脱离现场的抽象比喻撑段落
   - 作者点评式短句不必机械禁用，但如果它让读者感觉作者站到台前替他划重点、解释轻重或重排理解路径，就应删掉或改回场面内表达
   - 如果 public/canon/source 已经给出关键人物名字，不要长期退回“某人”“一个人”“一个球员”这类发虚指代
6. 按需并行调用 `novel-continuity-auditor` 和 `novel-dialogue-editor`
7. 汇总问题并修订正文
   - 如果 continuity 审计拦下了草稿，优先把 findings 压成定向 redraft 指令，再回到 `novel-scene-dramatizer` 做 1 到 2 轮 targeted rewrite，而不是直接放弃或只做表面润色
   - 对纪实章节，redraft 指令默认优先处理四种问题：`scene opening too abstract`、`interaction missing`、`voice pin missing`、`bridge facts swallowing the scene`
8. 调用 `novel-chapter-summarizer` 生成摘要和状态变更草案
9. 决定是否更新 `CURRENT_STATE.md`、`OPEN_LOOPS.md`、`FORESHADOWS.md`、`CHARACTER_ARCS.md`、`RECENT_EVENTS.md`
10. 最后才归档章节正文

如果用户只要求规划，不要越权扩写正文。
如果用户只要求审计，不要顺手重写整章。

## Hold a Higher Story Bar

把“像小说”视为正文层硬要求，而不是锦上添花。

默认把以下问题当成缺陷，而不是风格偏好：

- 正文主要靠总结、评论、主题判断推进
- 读完一章记得观点，却记不住人物、事件和场面
- 角色长期只以功能标签出现，缺少稳定名字、关系位置和辨识度
- 情节像履历表、资料卡或赛季述评，而不是由事件连续推动
- 冲突停留在旁白判断里，没有落实到动作、阻力、选择、代价和结果
- 语言像模板拼接，段首频繁先给概念判断，真正的动作总要晚一拍才落地
- 短段和转场句只负责评论、命名或挂牌，不负责推进

主调度应显式检查这些问题：

1. 这一章是否由事件推动，而不是由总结句推动
2. 关键人物是否尽量有名有姓
3. 角色是否有可见差异
4. 章节里是否存在可复述的场面节点
5. 总结桥段是否只是桥，而不是主干
6. 这一章是否有清楚的 `chapter promise`
7. 章末留下的是事件余波，还是作者判断
8. 语言表面是否顺读，还是总靠抽象结论、模板句式和空心短段撑节奏
9. 读者是否能清楚说出本章先打开的是哪一个场面
10. 场面之后的每一段，是否都在继续加压，而不是回到事实说明书
11. 如果删掉总结句，本章是否仍然成立；若不成立，说明主干还在评论而不在事件
12. 每个硬节点是否至少包含“场面锚点 / 互动动作 / 回望短句”三项中的两项
13. 主角是否在本章里至少一次以来源可追溯的回望、短话语或最低限度心理方向出现，而不是全章只有外部结果
14. 是否出现连续两段以上只做桥接、没有新反应和新压力偏转的摘要带
15. 如果来源允许，主角是否至少亲自开口一次，而不是始终被别人代说

对于“真实事件骨架上的小说”写法：

- 如果 public/source/canon 已给出名字，优先直接使用名字
- 如果来源没有名字，不要虚构；使用稳定角色标签，并给出可观察区分点
- 不要为了“更有血有肉”去改写主要比赛结果、关键决定、关键关系和时间顺序
- 允许补入不改写主事件判断的连接性对白、动作和心理细节

如果草稿故事性明显不足，不要直接归档。优先回退到：

- `novel-plot-architect`
  - 当问题是事件链、章内结构、转折和场面支点不够
- `novel-scene-dramatizer`
  - 当问题是 plan 可用，但正文过于概述、发虚、像评论
- `novel-dialogue-editor`
  - 当问题集中在对白、声音和关系推进
- `novel-continuity-auditor`
  - 当需要把“总结腔 / 角色发虚 / 事件不落地”作为显式质量问题审计

## Preserve Narrative Surface

一旦任务进入“正文生成”或“正文修订”，把章节文件当作成品页面而不是工作记录。

必须区分两层文本：

- 正文层
  - 只保留读者应看到的叙事表面
- 工作层
  - 规划理由、事实来源、结构判断、写作意图、审计意见、后续章节提示

工作层内容只能进入：

- `CURRENT_STATE.md`
- `OPEN_LOOPS.md`
- `RECENT_EVENTS.md`
- `summaries/*.summary.md`
- source / notes / diagnostics 类文件

不要把工作层内容漏进正文。尤其避免：

- “这一章要写……”
- “下一章将……”
- “如果说上一章……那么这一章……”
- “根据某资料 / 某回顾……”
- “这里最值得写的是……”
- 任何直接解释自己正在构思、组织、取材或论证的句子
- 长时间替代事件推进的评论腔、总结腔和主题概括

不要把章节写成：

- 赛季述评
- 履历罗列
- 资料改写稿
- 主题评论文

## Persist Workflow Artifacts

只有当用户明确要求、项目自动化强依赖，或当前任务本身就是 workflow 维护时，才把流程工件完整落到 `workflows/CHxxx/`。

对普通章节推进，流程工件不是默认前置条件。
不要因为工件不齐，就拖延一个本来已经可以写好的章节。
更不要让 `workflows/` 里的结构反过来把正文压成摘要。

推荐最小文件集：

- `00-manifest.json`
  - 记录章节 id、标题、流程状态、是否要求连续性审计 / 对白审计
- `01-context.md`
  - 入口状态、相关回路、必须保留事实、来源边界
- `02-plan.json`
  - `novel-plot-architect` 产物
- `03-draft.md`
  - `novel-scene-dramatizer` 的初稿
- `04-continuity-audit.json`
  - `novel-continuity-auditor` 产物
- `05-dialogue-audit.json`
  - `novel-dialogue-editor` 产物，可按 manifest 决定是否必需
- `06-revised.md`
  - 主调度汇总修订后的稳定稿
- `07-summary.json`
  - `novel-chapter-summarizer` 产物
- `08-writeback.md`
  - 本次 canon admission 与状态写回说明
- `09-execution-log.json`
  - 真实 sub-agent 调度痕迹、required role provenance 与显式 exception

如果当前任务走的是轻量模式，可以直接在 `chapters/` 写稳定稿，再按需补 summary 和 state。
不要把“先写出一堆工件”误当成小说质量保障。

如果项目存在自动 runner，优先用 runner 初始化和归档，而不是手工逐个创建文件。

推荐命令：

- `python3 scripts/novel_workflow.py init <project_root> <chapter_id> "<chapter_title>"`
- `python3 scripts/novel_workflow.py run-chapter <project_root> <chapter_id> --archive`
- `python3 scripts/novel_workflow.py check <project_root> <chapter_id>`
- `python3 scripts/novel_workflow.py archive <project_root> <chapter_id>`

如果项目明确启用了严格 workflow，再使用下面这套约束：

- `00-manifest.json` 里的 `execution_policy.require_subagents` 默认应为 `true`
- `09-execution-log.json` 必须记录 required role 的真实 dispatch
- `02-plan.json`、`04-continuity-audit.json`、`05-dialogue-audit.json`、`07-summary.json` 必须带 `contract_version`、`task_id`、`execution`
- required role 缺失真实 `subagent` provenance 时，不得归档

## Gate With Workflow Lint

把 lint 当成章节归档门禁，而不是事后建议。

推荐命令：

- `python3 scripts/novel_workflow_check.py <project_root> <chapter_id>`

如果项目提供了 `scripts/novel_workflow.py`，优先通过它触发检查，因为 runner 应自动内嵌 lint。

只有在项目当前确实运行 strict workflow 时，才按 fail-closed 处理下面这些门禁：

- 缺少 `02-plan.json`
- 缺少必需审计文件
- 缺少 `07-summary.json`
- 缺少 `08-writeback.md`
- 在 strict workflow 中缺少 `09-execution-log.json`
- 在 strict workflow 中 required role 没有真实 sub-agent dispatch
- 在 strict workflow 中 artifact 缺少 `contract_version`、`task_id` 或 `execution`
- 正文里出现元叙事 / 作者工作台泄漏
- 正文明显以总结、评论、概述替代事件推进，且未返工
- 正文缺少可复述的主场面，或主场面没有成为整章的推进中轴
- 段落主要由赛季综述、履历压缩、资料改写承担，桥接信息明显吞掉硬节点
- 开头不能在前两段内把读者带进具体时间点、比赛节点、物件动作或制度门槛
- 关键硬节点长期缺少互动动作、即时反应或来源可追溯的回望短句，导致人物始终像被旁白搬运
- 连续两段以上只在搬运 bridge facts，没有新的压力偏转、门槛变化或关系作用
- 连续性审计仍报出 `readability` 或 `prose-naturalness` 的中高严重度问题
- workflow manifest 与章节 id / 状态不一致

如果项目提供了 workflow lint，先修 lint，再写回 `chapters/`、`summaries/` 和状态文件。
如果项目提供了 workflow runner，默认通过 runner 执行 `init`、`run-chapter`、`archive`，避免手工漏步。

## Write Back Conservatively

把子 skill 结果视为提案，不视为真相。
始终做最小写回，而不是整份覆盖。

写回前明确回答：

1. 哪些事实已经进入正文并可视为 canon。
2. 哪些只是候选方案或分析判断。
3. 哪些状态文件需要同步。
4. 哪些开放回路被新增、推进、回收或作废。
5. 哪些角色动态状态发生了变化。

优先写入 diff 或 change set。
避免整段重写 `CURRENT_STATE.md` 或 `OPEN_LOOPS.md`，除非模板已明显失控。

## Keep Sub-Skills Isolated

把每次子 skill 调用都视为一次隔离的短会话。

但默认不要把 sub-agent 当成“专业感”的来源。
如果你自己已经拥有足够上下文，而且任务主要是把一章写好，优先直接完成，不要为了形式拆分。

1. 为每个子 skill 提供最小必要上下文
2. 不继承无关历史噪音
3. 只回收结构化产物和诊断
4. 为每次 dispatch 分配稳定 `task_id`
5. 把 dispatch 写入 `09-execution-log.json`

只有在复杂章节、严格 workflow 或用户明确要求协作模式时，才考虑拆成：

- `novel-plot-architect`
- `novel-scene-dramatizer`
- `novel-chapter-summarizer`

以下两者按 manifest 或章节复杂度决定是否加入：

- `novel-continuity-auditor`
- `novel-dialogue-editor`

只有在以下情况同时成立时，才允许非 sub-agent fallback：

1. `00-manifest.json` 的 `execution_policy.fallback_policy.allow_modes` 显式允许
2. `09-execution-log.json` 里登记了 exception
3. exception 含 `agent_role`、`output_refs`、`fallback_mode`、`reason_code`、`approved_by`、`justification`
4. lint 没有拒绝该 fallback

如果当前任务走的是轻量模式，单代理直写是有效默认路径，不需要为此自证“已完成多 skill 协作”。

主调度自己的职责是：

1. 裁剪上下文
2. 判断该任务是直接完成，还是值得分发
3. 如果分发，则汇总草稿与审计
4. 执行最小状态写回

## Shared Source

- `references/novel-system/routing.md`
- `references/novel-system/contracts.md`
- `references/novel-system/context-model.md`
- `references/novel-system/conventions.md`
- `references/novel-system/references/story-engine.md`
- `references/novel-system/references/language-surface.md`
- `references/novel-system/schemas/`
- `references/novel-system/templates/`

## Orchestrator-Only Source

- `references/orchestrator-system/overview.md`
- `references/orchestrator-system/architecture.md`

---
name: PR: Merge
description: 自动处理 GitHub PR：review、解决冲突、合并到目标分支，使用 worktree 避免影响本地工作。
category: PR
tags: [pr, merge, github, review]
---

# GitHub PR 自动合并工具

你是一个 GitHub PR 自动处理助手，负责完成 PR 的 review、冲突解决、合并等全流程操作。

## 自动化原则（必须遵守）

以下原则贯穿整个合并流程，优先级高于其他规则：

1. **全流程自动执行（零确认）**：以下所有操作必须直接执行，禁止暂停等待用户确认或同意：
   - **Git 操作**：`fetch`、`checkout`、`merge`、`commit`、`push`、`branch -d`、`stash`、`status`、`diff`、`log`、`rev-parse`、`reset`、`add`
   - **GitHub CLI**：`gh pr view/checks/diff/checkout/close/merge/review/comment`
   - **检查工具**：`npm run lint`、`npm test`、`npm run typecheck`、`npx eslint`、`wc`
   - 如果使用 `--worktree` 模式，`mkdir`、`rm -rf`、`git worktree add/remove` 也自动执行。
   - 如果当前工作区有未提交修改，自动执行 `git stash` 保存，合并完成后自动恢复。
   - **重要**：不要在任何步骤中使用 AskUserQuestion 或输出"是否继续"之类的提问，直接按流程执行到底。
2. **code-simplifier 仅提供建议**：调用 code-simplifier agent 时，仅输出简化建议报告，绝不直接修改代码。如果 review（包括 code-reviewer 和基础检查）发现关键/重要问题，直接使用 `gh pr review` 回复 PR 具体问题，然后终止合并流程，不继续往下合并。
3. **冲突智能处理**：简单冲突（导入语句、格式化、配置合并等）自动解决，不必停下等待用户指令。如果冲突复杂且涉及重大代码逻辑需要人工抉择，则使用 `gh pr review` 提交 PR 意见说明冲突情况，终止合并流程，不继续往下合并。

## 使用说明

### 基本用法
```bash
# 基本用法（合并到 dev 分支，删除原分支）
/pr:merge 123

# 指定目标分支
/pr:merge 123 --target main

# 不删除原分支
/pr:merge 123 --no-delete

# 完整参数
/pr:merge 123 --target dev --no-delete
```

### 参数说明
- `PR号`: 必需，GitHub PR 编号（如 123 或 #123）
- `--target <分支>`: 可选，目标分支，默认为 `dev`
- `--no-delete`: 可选，保留原分支不删除，默认会删除原分支
- `--worktree`: 可选，使用 git worktree 在临时目录中合并，避免影响当前工作区。默认直接在当前目录操作

## 工作流程

### 0. 参数解析

从用户输入中解析参数：
```
输入示例：
- "123" 或 "#123" → PR#123, target=dev, delete=true, worktree=false
- "123 --target main" → PR#123, target=main, delete=true, worktree=false
- "123 --no-delete" → PR#123, target=dev, delete=false, worktree=false
- "123 --worktree" → PR#123, target=dev, delete=true, worktree=true
- "PR#100 --target main --no-delete --worktree" → PR#100, target=main, delete=false, worktree=true
```

使用 TodoWrite 创建任务列表，跟踪整个流程进度。**必须创建以下任务**：

```
TodoWrite 任务列表模板（根据 PR 大小调整）：

小型 PR (< 100 行):
1. Get PR information
2. Basic code review
3. Prepare merge
4. Merge PR
5. Run tests
6. Push and cleanup
7. Generate report

中型 PR (100-500 行):
1. Get PR information
2. Basic code review
3. Run code-reviewer agent    ← 必须执行
4. Prepare merge
5. Merge PR
6. Run tests
7. Push and cleanup
8. Generate report

大型 PR (> 500 行):
1. Get PR information
2. Basic code review
3. Run code-reviewer agent    ← 必须执行
4. Run code-simplifier agent  ← 必须执行
5. Prepare merge
6. Merge PR
7. Run tests
8. Push and cleanup
9. Generate report

⚠️ 重要：如果 review 发现关键/重要问题：
   → 直接使用 `gh pr review` 回复 PR 具体问题
   → 向用户展示问题摘要
   → 立即终止流程，不继续执行后续步骤
   → 等待原作者修复后重新运行 `/pr:merge`
```

### 1. 获取 PR 信息

使用 GitHub CLI 获取 PR 详细信息：

```bash
# 获取 PR 基本信息
gh pr view <PR号> --json number,title,state,headRefName,baseRefName,author,mergeable,commits,additions,deletions

# 获取 PR 检查状态
gh pr checks <PR号>

# 获取 PR diff
gh pr diff <PR号>
```

**验证项**：
- PR 状态必须是 `OPEN`
- 检查 CI/CD 状态（GitHub Actions、测试等）
- 检查是否可以合并（`mergeable` 状态）
- 确认目标分支与用户指定的一致

**如果 PR 状态异常**：
- 已合并或已关闭 → 提示用户并退出
- CI 失败 → 使用 `gh pr review` 提交 CI 失败详情到 PR 评论，终止合并流程
- 有冲突 → 记录，后续步骤处理

### 2. 自动 Code Review（必须执行）

**重要**：Code Review 是必须执行的步骤，不能跳过。根据 PR 变更大小选择 review 模式：

#### 2.0 判断 Review 模式

根据 PR 的 `additions + deletions` 总数判断：
- **小型 PR**（< 100 行变更）：执行快速 review（步骤 2.1-2.3）
- **中型 PR**（100-500 行变更）：执行标准 review（步骤 2.1-2.4，调用 code-reviewer agent）
- **大型 PR**（> 500 行变更）：执行完整 review（步骤 2.1-2.5，调用多个 QA agents）

#### 2.1 基础代码检查（所有 PR 必须执行）

```bash
# 读取 PR 的 diff
gh pr diff <PR号>
```

快速检查以下内容：
- 代码风格是否符合项目规范（参考 .claude/CLAUDE.md）
- 是否有明显的 bug 或逻辑错误
- 是否有安全隐患（SQL 注入、XSS、命令注入等）
- 是否有硬编码的敏感信息

#### 2.2 变更影响分析（所有 PR 必须执行）

- 分析修改的文件和模块
- 评估影响范围（前端/后端/数据库/配置）
- 识别潜在的回归风险

#### 2.3 生成 Review 报告（所有 PR 必须执行）

创建详细的 review 报告：
```markdown
## PR Review 报告

### 基本信息
- PR 编号: #<PR号>
- 标题: <标题>
- 作者: <作者>
- 源分支: <源分支>
- 目标分支: <目标分支>
- 文件变更: +<additions> -<deletions>
- Review 模式: [小型/中型/大型]

### 代码质量检查
✅ 通过项 / ⚠️  警告项 / ❌ 问题项

### 安全检查
✅ 通过 / ⚠️  发现潜在问题

### Agent Review 结果（中型/大型 PR）
- code-reviewer: [已执行/跳过]
- code-simplifier: [已执行/跳过]

### 影响分析
- 影响模块: [列表]
- 风险评估: 低/中/高

### 建议
- [建议列表]

### 总结
推荐 [通过/修复后通过/拒绝]
```

#### 2.4 调用 code-reviewer Agent（中型/大型 PR 必须执行）

**必须使用 Task 工具调用 `pr-review-toolkit:code-reviewer` agent**：

```
Task 工具参数：
- subagent_type: "pr-review-toolkit:code-reviewer"
- prompt: "Review PR #<PR号> 的代码变更。运行 `gh pr diff <PR号>` 查看变更内容。检查代码质量、安全性、最佳实践。"
- description: "Code review PR #<PR号>"
- model: "sonnet"
```

等待 agent 返回结果后，将发现的问题整合到 Review 报告中。

#### 2.5 调用 code-simplifier Agent（大型 PR 必须执行）

**必须使用 Task 工具调用 `pr-review-toolkit:code-simplifier` agent**：

```
Task 工具参数：
- subagent_type: "pr-review-toolkit:code-simplifier"
- prompt: "分析 PR #<PR号> 的代码变更，识别可简化的复杂逻辑。运行 `gh pr diff <PR号>` 查看变更。

**重要：仅输出建议报告，不要直接修改代码。**

请按以下格式输出简化建议：

## 代码简化建议

### 1. [建议标题]
- **文件**: `path/to/file.js:L10-L20`
- **当前代码**: [简要描述当前实现]
- **建议**: [具体的简化方案]
- **优先级**: 高/中/低
- **理由**: [为什么这样简化更好]

### 2. [下一个建议]
...

### 总结
- 发现 N 处可简化的代码
- 高优先级: N 处
- 中优先级: N 处
- 低优先级: N 处

**注意**：这些建议供 PR 作者参考，可在后续 PR 中处理。"
- description: "Code simplification analysis PR #<PR号>"
- model: "sonnet"
```

**简化建议处理**：
- **仅输出建议报告，不直接修改代码**
- 将建议整合到最终的 Review 报告中
- 建议供 PR 作者参考，可在后续 PR 中处理
- 不阻塞当前 PR 的合并流程

#### 2.6 Review 结果处理

根据 review 结果决定后续流程：

**如果发现关键/重要问题 → 立即终止合并流程**：

1. **直接回复 PR 具体问题**：使用 `gh pr review` 添加详细的 review 评论
2. **向用户展示问题摘要**：在终端显示发现的问题
3. **结束合并工作**：不继续执行后续步骤

```bash
# 添加 review 评论（使用 --comment 而非 --request-changes 避免阻塞）
gh pr review <PR号> --comment --body "## 🔍 Code Review 发现问题

### ❌ 关键问题 (必须修复)
1. **[问题标题]**
   - 📁 文件: \`path/to/file.js:L10-L20\`
   - 🐛 问题: [具体描述]
   - 💡 建议修复:
     \`\`\`javascript
     // 修复示例代码
     \`\`\`

### ⚠️ 重要问题 (建议修复)
- ...

### 💬 建议改进 (可选)
- ...

---
📌 请修复上述问题后重新提交，然后运行 \`/pr:merge <PR号>\` 重新合并。

_Review by Claude Code PR Merge Tool_"
```

**终止流程后的输出**：
```markdown
## ❌ PR Review 未通过

PR #<PR号> 存在以下问题需要修复：

### 关键问题
1. [问题摘要]
2. [问题摘要]

### 重要问题
1. [问题摘要]

---
✅ 已将详细 review 反馈添加到 PR 评论
⏸️ 合并流程已终止，请等待原作者修复后重新运行 `/pr:merge <PR号>`
```

**如果没有发现问题 → 继续合并流程**：
- 显示 Review 报告摘要（全部通过）
- 继续执行步骤 3（保存当前工作状态）及后续合并操作

### 3. 保存当前工作状态

在切换分支前，保存当前工作状态：

```bash
# 检查当前分支
current_branch=$(git rev-parse --abbrev-ref HEAD)

# 检查是否有未提交的修改
git status --porcelain

# 如果有未提交的修改，自动 stash（不要询问用户）
```

**如果有未提交的修改**：
- 直接执行 `git stash push -m "pr-merge-<PR号>-auto-stash"` 保存当前修改（无需确认）
- 合并完成后自动执行 `git stash pop` 恢复修改
- 在最终报告中说明已自动暂存和恢复

### 4. 切换到目标分支

默认直接在当前目录操作。仅当用户指定 `--worktree` 时才使用 worktree 模式。

#### 4.1 默认模式（当前目录）

```bash
# 获取最新的远程分支信息
git fetch origin

# 切换到目标分支
git checkout <target-branch>

# 拉取最新代码
git pull origin <target-branch>
```

#### 4.2 Worktree 模式（仅 `--worktree` 时）

```bash
# 创建临时目录
temp_dir="/tmp/pr-merge-<PR号>-$(date +%s)"

# 获取最新的远程分支信息
git fetch origin

# 创建 worktree
git worktree add "$temp_dir" origin/<target-branch>

# 切换到 worktree 目录
cd "$temp_dir"
```

### 5. 获取 PR 分支并检查冲突

```bash
# 在 worktree 中获取 PR 分支
gh pr checkout <PR号>

# 切换回目标分支
git checkout <target-branch>

# 尝试合并（检测冲突）
git merge --no-commit --no-ff <PR-branch>
merge_status=$?
```

**如果没有冲突** (merge_status == 0)：
- 记录合并成功
- 继续下一步

**如果有冲突** (merge_status != 0)：
- 列出冲突文件
- 进入自动冲突解决流程（步骤 6）

### 6. 自动解决冲突（如需要）

如果检测到冲突，尝试自动解决：

**6.1 分析冲突**：
```bash
# 获取冲突文件列表
git diff --name-only --diff-filter=U

# 对每个冲突文件
for file in $(git diff --name-only --diff-filter=U); do
  # 读取冲突内容
  Read $file

  # 分析冲突类型：
  # - 简单文本冲突（容易自动解决）
  # - 代码逻辑冲突（需要谨慎处理）
  # - 删除 vs 修改冲突
done
```

**6.2 冲突解决策略**：

按优先级尝试以下策略：

1. **简单文本冲突**：
   - 导入语句冲突 → 合并所有导入
   - 格式化差异 → 使用 target 分支的格式
   - 注释冲突 → 保留所有注释

2. **配置文件冲突**：
   - package.json → 合并依赖，保留最新版本
   - .env 示例 → 合并所有变量
   - 配置项 → 倾向保留 PR 的新配置

3. **代码逻辑冲突**：
   - 简单的代码逻辑冲突（如两边各加了不同的新代码，不互相矛盾）→ 自动合并两边的修改
   - 复杂的代码逻辑冲突（函数修改冲突、删除 vs 修改等需要人工抉择）→ 使用 `gh pr review` 提交冲突详情到 PR 评论，终止合并流程

**6.3 应用解决方案**：
```bash
# 对于可自动解决的冲突
Edit <file> # 使用 Edit 工具修复冲突

# 标记为已解决
git add <file>

# 对于无法自动解决的复杂冲突
# 使用 gh pr review 提交冲突详情到 PR 评论
# 终止合并流程，不继续往下合并
```

**6.4 验证冲突解决**：
```bash
# 确保所有冲突已解决
if [ $(git diff --name-only --diff-filter=U | wc -l) -eq 0 ]; then
  echo "所有冲突已解决"
else
  echo "仍有未解决的冲突"
  # 使用 gh pr review 提交未解决冲突的详情到 PR 评论，终止合并流程
fi
```

### 7. 运行测试和检查

在合并前运行必要的检查：

**7.1 代码规范检查**：
```bash
# 根据 PR 修改的模块运行相应的 lint
if [[ $(git diff --name-only origin/<target-branch> | grep "^client/") ]]; then
  cd client && npx eslint src --ext .js,.jsx --max-warnings 0
fi

if [[ $(git diff --name-only origin/<target-branch> | grep "^portal/") ]]; then
  cd portal && npm run typecheck && npm run lint
fi

if [[ $(git diff --name-only origin/<target-branch> | grep "^functions-web/") ]]; then
  cd functions-web && npm run lint
fi
```

**7.2 单元测试**：
```bash
# 根据修改的模块运行测试
if [[ $(git diff --name-only origin/<target-branch> | grep "^functions-web/") ]]; then
  cd functions-web && npm run test:unit
fi

if [[ $(git diff --name-only origin/<target-branch> | grep "^portal/") ]]; then
  cd portal && npm test
fi

if [[ $(git diff --name-only origin/<target-branch> | grep "^client/") ]]; then
  cd client && npm test
fi
```

**如果测试失败**：
- 展示失败的测试和错误信息
- 使用 `gh pr review` 提交测试失败详情到 PR 评论
- 回滚合并操作（`git merge --abort` 或 `git reset`）
- 终止合并流程，不继续往下合并

### 8. 完成合并

测试通过后，完成合并操作：

```bash
# 如果之前是 --no-commit 模式，现在提交
git commit -m "Merge pull request #<PR号> from <source-branch>

<PR标题>

Auto-merged by Claude Code PR Merge Tool

Co-Authored-By: <PR作者>
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 推送到远程
git push origin <target-branch>
```

**验证合并成功**：
```bash
# 确认推送成功
git log origin/<target-branch> -1

# 验证 PR 状态
gh pr view <PR号> --json state,merged
```

### 9. 关闭 PR 并清理

```bash
# 关闭 PR（GitHub 会自动检测到合并并关闭，但我们可以显式关闭）
gh pr close <PR号> --comment "Auto-merged to <target-branch> by Claude Code 🤖"

# 如果用户指定删除原分支（默认行为）
if [ "$delete_branch" = true ]; then
  # 删除远程分支
  git push origin --delete <source-branch>

  # 注意：不要删除 main/dev/master 等主要分支
  if [[ "<source-branch>" =~ ^(main|master|dev|develop)$ ]]; then
    echo "⚠️  检测到主要分支，跳过删除"
  fi
fi

# 如果使用了 worktree 模式，清理 worktree
if [ -n "$temp_dir" ]; then
  cd <original-directory>
  git worktree remove "$temp_dir"
fi

# 如果之前 stash 了修改，恢复
# git stash pop（如果步骤 3 执行了 stash）

# 切换回原来的分支
git checkout <original-branch>
```

### 10. 生成合并报告

生成详细的合并报告供用户查看：

```markdown
## PR 合并报告

### 合并信息
- PR 编号: #<PR号>
- 标题: <标题>
- 源分支: <源分支> → 目标分支: <目标分支>
- 合并方式: [快进/非快进/解决冲突后合并]
- 合并提交: <commit-sha>

### Review 摘要
- 代码质量: [通过/有警告]
- 安全检查: [通过/有警告]
- 代码简化: [无建议/有 N 项建议供后续参考]
- 测试结果: [全部通过/部分通过]

### 冲突处理
- 冲突文件数: <数量>
- 自动解决: <数量>
- 手动解决: <数量>
- 冲突详情: [列表]

### 测试执行
- Lint 检查: [通过/失败]
- 单元测试: [通过/失败/跳过]
- 受影响模块: [列表]

### 清理操作
- 远程分支: [已删除/保留]
- Worktree: [已清理/未使用]
- 工作区恢复: [已切回原分支/已恢复 stash]

### 后续建议
- [建议列表]

---
✅ PR #<PR号> 已成功合并到 <target-branch>
```

## 错误处理

### 常见错误及处理

1. **PR 不存在或无权访问**：
   - 验证 PR 编号是否正确
   - 检查 GitHub 认证状态 (`gh auth status`)
   - 提示用户检查权限

2. **目标分支不存在**：
   - 列出可用的分支 (`git branch -a`)
   - 提示用户可用分支并终止流程

3. **无法创建 worktree**（仅 `--worktree` 模式）：
   - 检查磁盘空间
   - 检查目标目录权限
   - 回退到默认模式（当前目录操作）

4. **合并冲突无法自动解决**：
   - 保存当前状态
   - 提供冲突文件列表和冲突内容
   - 使用 `gh pr review` 提交冲突详情到 PR 评论
   - 终止合并流程

5. **测试失败**：
   - 展示失败详情
   - 使用 `gh pr review` 提交测试失败详情到 PR 评论
   - 回滚合并操作
   - 终止合并流程

6. **推送失败**：
   - 检查网络连接
   - 检查分支保护规则
   - 检查权限设置
   - 提供手动推送命令

## 安全检查清单

在整个流程中注意：

### 代码安全
- ❌ 不允许合并包含明显安全漏洞的代码
- ⚠️  警告包含敏感信息（密钥、密码、token）的提交
- ✅ 检查输入验证和清理
- ✅ 检查 SQL 注入风险
- ✅ 检查 XSS 风险
- ✅ 检查命令注入风险

### 分支安全
- ❌ 不允许强制推送到主要分支
- ❌ 不允许删除 main/master/dev 等主要分支
- ✅ 遵守分支保护规则
- ✅ 验证合并权限

### 数据安全
- ⚠️  警告包含数据库迁移的 PR（需要特别注意）
- ⚠️  警告修改权限配置的 PR
- ✅ 检查是否需要备份

## 最佳实践

1. **合并前务必 Review**：
   - 即使是自动化工具，也要认真 review
   - 对安全相关的变更格外谨慎

2. **保持工作区整洁**：
   - 使用 worktree 避免影响当前工作
   - 及时清理临时文件和分支

3. **完整的测试覆盖**：
   - 确保所有相关测试都通过
   - 不要跳过测试除非有充分理由

4. **清晰的提交信息**：
   - 包含 PR 编号和标题
   - 说明合并方式和特殊处理

5. **及时沟通**：
   - 遇到无法自动处理的情况，通过 `gh pr review` 反馈到 PR 并终止流程
   - 提供清晰的错误信息和建议

## 使用示例

### 示例 1：简单合并
```bash
/pr:merge 123
```
流程：Review → 检查冲突 → 运行测试 → 合并到 dev → 删除原分支

### 示例 2：合并到 main 并保留原分支
```bash
/pr:merge 456 --target main --no-delete
```
流程：Review → 检查冲突 → 运行测试 → 合并到 main → 保留原分支

### 示例 3：有冲突的 PR
```bash
/pr:merge 789
```
流程：Review → 检测到冲突 → 自动解决 → 验证 → 测试 → 合并 → 清理

## 注意事项

1. **遵守项目规范**：
   - 严格遵循 `.claude/CLAUDE.md` 中的规范
   - 遵守 Git 工作流程

2. **权限要求**：
   - 需要 GitHub CLI (`gh`) 已认证
   - 需要目标仓库的写入权限
   - 需要能够推送到目标分支

3. **不适用场景**：
   - 需要人工仔细审查的关键 PR（如架构变更）
   - 包含敏感操作的 PR（如权限变更）
   - 大型重构 PR（建议拆分）

4. **回滚方案**：
   - 如果合并后发现问题，提供回滚指引
   - 保留合并前的 commit SHA 用于回滚

5. **持续改进**：
   - 根据项目特点调整 review 规则
   - 收集用户反馈优化流程

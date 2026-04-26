# My Vibe Coding Toolkits

一个面向 AI 编程工作流的本地工具库，主要用于 Cursor 场景，包含：

- 可复用的 `skills`（流程方法、开发规范、调试与协作实践）
- 会话启动 `hooks`（自动注入上下文）
- 辅助 `rules`（编码与行为约束）
- 可选 `agents` 提示模板

当前仓库以“技能沉淀 + 会话增强”为核心，不是单一应用项目。

## 已收录技能（skills）

> 每个技能目录下都有 `SKILL.md`，用于定义触发条件和执行方法。

- `using-superpowers`：技能体系入口与调用原则
- `verification-before-completion`：完成前验证流程
- `writing-skills`：如何设计、编写、测试技能
- `using-git-worktrees`：多工作树并行开发
- `receiving-code-review` / `requesting-code-review`：代码评审协作
- `systematic-debugging`：系统化排障方法
- `test-driven-development`：TDD 工作流
- `subagent-driven-development`：子代理驱动开发
- `dispatching-parallel-agents`：并行分派策略
- `executing-plans` / `writing-plans`：计划执行与撰写
- `brainstorming`：结构化发散与收敛
- `finishing-a-development-branch`：开发分支收尾流程
- `git-commit`：提交规范与实践
- `bash-scripting`：Shell 脚本实践
- `writing-linux-c-small-app`：Linux C 小型项目模板实践
- `writing-linux-c-complex-app`：Linux C 复杂项目模板实践

## Hooks 说明

`hooks/` 当前包含 Cursor 会话启动相关文件：

- `hooks/hooks.json`：Cursor hooks 配置
- `hooks/session-start`：会话启动脚本，注入 `using-superpowers` 相关上下文

## 在 Cursor 中使用（建议）

1. 将本仓库作为你的本地工具库维护。
2. 在需要的项目中引用 `skills`、`rules`、`hooks` 内容（按你的工作流可复制或软链接）。
3. 将 `hooks/hooks.json` 的配置合并到你的 Cursor hooks 配置中。
4. 保持 `hooks/session-start` 可执行，并保证其可读取 `skills/using-superpowers/SKILL.md`。

## 一键安装命令

```bash
rm -rf /tmp/my-vibe-coding-toolkits && \
git clone git@github.com:exbob/my-vibe-coding-toolkits.git /tmp/my-vibe-coding-toolkits && \
mkdir -p .cursor && \
cp -rf /tmp/my-vibe-coding-toolkits/agents /tmp/my-vibe-coding-toolkits/hooks /tmp/my-vibe-coding-toolkits/skills /tmp/my-vibe-coding-toolkits/rules .cursor/ && \
cp -f /tmp/my-vibe-coding-toolkits/clang-formt/c/.clang-format . && \
mv -f .cursor/hooks/hooks.json .cursor/hooks.json
```

说明：
- 若目标目录不存在会自动创建（如 `.cursor`）。
- 若存在同名文件或目录会直接覆盖。

## 开发 Linux 软件推荐工作流

基于本仓库的技能设计，推荐按下面流程推进 Linux 软件开发（尤其是 Linux 用户态 C/CMake 项目）：

1. **入口与约束确认**
   - 使用 `using-superpowers` 先检查并激活合适技能。
   - 先确认目标与边界：是 Linux 用户态工具/服务，还是内核/驱动。

2. **先做方案，不直接开写**
   - 用 `brainstorming` 先澄清需求与成功标准，再确定技术路线。
   - 进入实施前，按项目形态选择 `writing-linux-c-small-app` 或 `writing-linux-c-complex-app`。
   - 若任务是多步骤交付，再用 `writing-plans` 形成可执行计划（含文件、测试、验收命令）。

3. **Linux C 模板直达（关键分叉）**
   - 小型工具类/命令行主导项目：使用 `writing-linux-c-small-app`，直接复用 `small-app/` 模板。
   - 配置驱动/多模块服务类项目：使用 `writing-linux-c-complex-app`，直接复用 `complex-app/` 模板。

4. **隔离开发环境**
   - 使用 `using-git-worktrees` 创建隔离工作目录，避免污染主工作区。
   - 在隔离目录先跑一次基线验证（构建/测试），确认起点健康。

5. **按计划执行（两种路径）**
   - 计划写完后，按任务特征二选一：
   - `subagent-driven-development`：适合任务边界清晰、可拆分执行的场景。
   - `executing-plans`：适合任务耦合高、希望在当前会话连续推进的场景。

6. **实现阶段遵循 TDD**
   - 使用 `test-driven-development`：先写失败测试（RED），再最小实现（GREEN），最后重构（REFACTOR）。
   - 每次改动聚焦单一行为，避免“顺手大改”。

7. **出现问题先根因分析**
   - 一旦有异常、失败或行为偏差，先走 `systematic-debugging`，先查根因再修复。
   - 修复前先构造可复现的失败用例，修复后验证回归。

8. **完成前必须验证**
   - 使用 `verification-before-completion`：不跑完整验证命令，不声称“已完成”。
   - 验证至少覆盖：构建成功、测试通过、关键场景可复现。

9. **评审、提交与收尾**
   - 用 `requesting-code-review` 做评审，先处理关键问题再合并。
   - 用 `git-commit` 统一 Conventional Commits 风格。
   - 用 `finishing-a-development-branch` 选择收尾路径：本地合并 / 提 PR / 保留分支 / 丢弃。

一句话总结：**先设计与计划，再隔离实现；用 TDD 保证增量质量；用系统化调试和强验证确保可交付。**

## 维护建议

- 新增技能时，遵循现有目录命名风格（短横线、语义清晰）。
- 技能说明优先写“何时使用”，再写“如何执行”。
- 规则文件放 `rules/`，技能放 `skills/`，避免混放。
- 对脚本和规则变更，建议同步更新本 README，确保文档与仓库状态一致。

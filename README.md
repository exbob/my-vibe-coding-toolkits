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
- `writing-linux-c-app`：Linux C 项目实践参考

## Hooks 说明

`hooks/` 当前包含 Cursor 会话启动相关文件：

- `hooks/hooks.json`：Cursor hooks 配置
- `hooks/session-start`：会话启动脚本，注入 `using-superpowers` 相关上下文

## 在 Cursor 中使用（建议）

1. 将本仓库作为你的本地工具库维护。
2. 在需要的项目中引用 `skills`、`rules`、`hooks` 内容（按你的工作流可复制或软链接）。
3. 将 `hooks/hooks.json` 的配置合并到你的 Cursor hooks 配置中。
4. 保持 `hooks/session-start` 可执行，并保证其可读取 `skills/using-superpowers/SKILL.md`。

## 维护建议

- 新增技能时，遵循现有目录命名风格（短横线、语义清晰）。
- 技能说明优先写“何时使用”，再写“如何执行”。
- 规则文件放 `rules/`，技能放 `skills/`，避免混放。
- 对脚本和规则变更，建议同步更新本 README，确保文档与仓库状态一致。

# 我的 Vibe Coding 工具集

面向 AI 编程的一组工具与技能集合。主要在 cursor 上使用。

## 1. 规则

`rules/` 目录中的文件是规则文件。将它们复制到你的项目 `.cursor/rules` 目录后即可生效。

- `behavioral-guidelines.mdc`：LLM的行为规范指引，约束常见 LLM 编码与交互失误，适用于所有 AI 代码变更场景。源自<https://github.com/forrestchang/andrej-karpathy-skills>。
- `c-cpp-coding-style.mdc`：C/C++ 编码风格的规则。
- `shell-script-style.mdc`：Shell 脚本编码风格规则（Bash 优先）。

## 2. 技能

选择相应的 skill 文件夹，复制到 `~/.cursor/skills` 目录后生效。

### 2.1 通用

#### anthropics

官方/通用技能集合，覆盖文档处理、前端设计、MCP 构建、Web 测试与协作写作等常见场景。

来自 <git@github.com:anthropics/skills.git>

### 2.2 开发流程

#### superpowers

一套软件开发的流程与方法论技能集合，强调 TDD、调试、规划、并行子代理与交付收尾等工程实践。

来自 <git@github.com:obra/superpowers.git>

### 2.3 代码实现

#### writing-linux-c-app

Linux C 软件项目规范，先做项目类型判定（小型/复杂/其他），再按对应参考模板执行目录、构建、日志与配置规范。

#### bash-scripting

bash 脚本的编程规范，编写，修改或者审查 bash 脚本时触发。

#### git-commit

用于规范 Git commit message，采用 Conventional Commits 格式，支持中英文提交信息，并提供 `.gitmessage` 模板与类型选择规则。

### 2.4 前端设计

#### nothing-design-skill

一个 nothing 风格的前端设计技能（偏视觉与交互表达）。单色、重排版、工业感。

来自 <git@github.com:dominikmartn/nothing-design-skill.git>

### 2.5 画图

#### fireworks-tech-graph

将自然语言描述转化为精美的 SVG 技术图，还可以到处 PNG 。主要用于架构图、流程图、时序图、Agent/记忆、概念图、UML等。

来自 <git@github.com:yizhiyanhua-ai/fireworks-tech-graph.git>

#### mermaid

指导用 Mermaid 文本语法在 Markdown 里写出可渲染的图表（流程图、时序图、类图等 23+ 种），并规范代码块格式、示例引用与保存方式，让文档里的示意图能直接随仓库预览与迭代。

来自 <https://agentskills.so/skills/iofficeai-aionui-mermaid>

### 2.6 文档

#### tech-doc-style-chinese

面向中文技术文档、产品文案与界面文案的写作 Skill

来自 <git@github.com:Fenng/tech-doc-style-chinese.git>

## 3. 第三方 Skill 备份与手动更新

为了避免上游 GitHub 仓库失效导致技能不可用，可将第三方 Skill 仓库备份到 `thirdpart/skills/`。

仓库内提供脚本：`manage-skill-vendors.sh`

- 添加仓库（会下载并写入 `thirdpart/skills/<name>`）：
  - `bash manage-skill-vendors.sh add anthropics git@github.com:anthropics/skills.git main`
- 更新全部已登记仓库：
  - `bash manage-skill-vendors.sh update`
- 更新单个仓库：
  - `bash manage-skill-vendors.sh update anthropics`
- 查看登记列表：
  - `bash manage-skill-vendors.sh list`

脚本会维护 `thirdpart/skills.sources.tsv`，记录来源仓库、分支、最后同步 commit 与同步时间，便于手动追踪更新状态。
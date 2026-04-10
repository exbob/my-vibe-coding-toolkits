---
name: writing-linux-c-app
description: Use when planning or implementing a Linux userspace C application with CMake, build/deploy directories, and standardized logging/config conventions; excludes kernel/driver work and non-CMake-first workflows.
---

# Linux C 应用开发规范

## 概述与边界

在 Linux 上以 **C 为主**的用户态程序，若采用 **CMake**、根目录 **`build.sh`**、安装到 **`deploy/`** 的范式，适用本 Skill。**复杂**项目可附带少量 Web/Lua/JS/HTML/CSS（单独顶层目录），细节见 `references/complex-app.md`。

- **生效条件**：须先取得用户**明确同意**采用本 Skill；未同意不得按本规范改工程或假定工具链。
- **不适用**：内核/驱动；拒绝 CMake 的工程；多仓与发布编排远超模板能力时，类型选「其他」并单独约定。

## 与 references 的分工

| 层级 | 职责 |
|------|------|
| **本文件（SKILL.md）** | 同意与边界；**强制**请用户在「小型 / 复杂 / 其他」三选一；提供面向用户的选项说明与对比；选定后**仅指向**对应 reference，**不写**具体 CMake 片段、`.gitignore` 规则、`ARCH`、工具链文件名等实施细节。 |
| **`references/small-app.md`** | 用户已选**小型**后的全部实施约定：目录、`CMakeLists.txt` 思路、`build.sh`、`log.h`、命令行、**`.gitignore`**、**目标架构与工具链**、版本注入等；模板目录 `references/small-app/`。 |
| **`references/complex-app.md`** | 用户已选**复杂**后的全部实施约定：多模块、JSON+zlog、configs 与 `deploy/`、可选 `web/` 等；与小型**共用**的构建/工具链/`.gitignore` 说明**引用** `small-app.md` 对应章节，避免重复；模板目录 `references/complex-app/`。 |
| **其他** | 无默认模板；与用户逐项约定后实施，不套用上述两套目录与依赖默认值。 |

## 强制流程：先判定项目类型

在写计划、改代码或生成文件结构之前，**必须先请用户在三类中明确选择其一**。不得默认替用户拍板。

### 向用户展示时的要求（强制）

1. **必须列出三个选项**：小型、复杂、其他（名称与下表一致）。
2. **必须说明区别**：至少包含下表「用户可见对比」中的维度；可用表格 + 简短总结，让用户能据此自主选择。
3. **必须得到明确答复**：用户确认选项后，再打开**对应** `references/*.md` 与模板目录；若用户犹豫，可根据「快速倾向」给建议，最终以用户选择为准。

### 三选项速览（给用户看的摘要）

| 选项 | 一句话 |
|------|--------|
| **小型** | 不要配置文件，全靠命令行；简单日志打 stdout；结构最轻，适合工具类、单程序。 |
| **复杂** | 要 JSON 主配置 + zlog 文件日志；可多模块；可带少量 Web/Lua/JS 等单独目录；依赖与目录更重，适合长期运行的服务类程序。 |
| **其他** | 不用本 Skill 的默认栈（例如不用 JSON/zlog、或要别的构建方式）；由双方逐项约定后再做。 |

### 用户可见对比（详细区别）

| 维度 | 小型 | 复杂 | 其他 |
|------|------|------|------|
| **磁盘上的应用配置** | 不需要。无 `app.json` 一类主配置。 | **需要**。主配置为 **JSON**；按 Debug/Release 选模板，安装到 `deploy/` 下固定文件名（如 `app.json`）。 | 用户指定格式与加载方式；**不**默认 JSON。 |
| **运行参数** | 全部通过**命令行**（除 `-h`/`-v` 外可再定义业务参数）。 | 命令行 + 配置文件；通常支持 `-f`/`--config`。 | 按约定。 |
| **日志** | `inc/log.h` 宏 → **stdout**；不读配置改日志行为。 | **zlog** + 独立 **`.ini`**；Debug/Release 可不同输出。 | 用户指定。 |
| **源码与目录** | `src/` + `inc/` 为主。 | `src/main.c` + **`src/<模块>/`**；可选 **`web/`** 等。 | 商定。 |
| **第三方 C 库** | 按需；模板较简。 | 常 **FetchContent**（cJSON、zlog）；可改 `thirdpart/`。 | 商定。 |
| **本 Skill 模板** | `references/small-app/` + `small-app.md` | `references/complex-app/` + `complex-app.md` | **无**默认模板。 |
| **典型场景** | CLI 工具、小程序、示例。 | 常驻服务、可配置、多模块、可能内嵌管理页。 | YAML、Meson、非 CMake 等。 |

### 快速倾向（仅供建议，不能代替用户选择）

- 修改程序行为主要靠**命令行** → 小型；主要靠**配置文件**且用 **JSON** → 复杂；要配置文件但**不用 JSON** → 其他。
- 日志打屏即可还是落盘/滚动？前者 → 小型；后者 → 复杂或其他。
- 要多 C 子模块 + 可选 Web 目录？是 → 倾向复杂。
- 已指定 **非 JSON / 非 zlog / 非 CMake** → **其他**。

### 选定后的动作

| 用户选择 | 下一步 |
|----------|--------|
| **小型** | 打开并遵循 `references/small-app.md`，以 `references/small-app/` 为模板。 |
| **复杂** | 打开并遵循 `references/complex-app.md`，以 `references/complex-app/` 为模板。 |
| **其他** | 不得套用两套模板默认值；与用户确认日志、配置、目录、构建后再做。 |

## 实施前提问清单（仅入口级）

1. 是否采用本 Skill（不同意则不按本规范执行）。
2. 项目类型：按上文向用户展示**三选项及详细区别**，待用户**明确选择**后再继续。
3. 选定类型后，**所有**后续细节（含是否新增 `.gitignore`、`ARCH` 与交叉编译、工具链文件、`build.sh` 行为、版本字符串与命令行选项等）均在所选类型的 **`references/*.md`** 中执行；**勿在本 SKILL.md 中展开或重复**。

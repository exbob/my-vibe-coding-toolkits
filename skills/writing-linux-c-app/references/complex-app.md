# 复杂 Linux C 项目规范

> **前置条件**：用户已在上一级 `SKILL.md` 中明确选择 **「复杂」**。三选项对比、面向用户的说明**仅**写在 `SKILL.md`，本文不重复。

本文档与 `references/complex-app/` 配套：说明约定与流程；目录内为可编译**模板工程**（多模块、cJSON、zlog、JSON 主配置 + zlog ini）。新建复杂项目可复制该目录为仓库根，改工程名与业务逻辑；**关键文件（`CMakeLists.txt`、`cmake/thirdparty.cmake`、`build.sh`、`Config.h.in`、`git-version.sh`、`configs/*`、`src/*`、`cmake/toolchain-*.cmake` 等）建议沿用结构**。

## 何时使用本文档（技术边界）

- 需要磁盘上的**JSON 主配置文件**，并支持 `-f`/`--config`。
- 日志使用 **zlog**（静态链接），规则放在独立 **`.ini`**。
- 源码按模块组织：`src/main.c` + `src/<模块名>/`。
- 可选少量非 C 资源（Web/Lua/JS/HTML/CSS），放独立顶层目录。

## 模板根路径

相对本 Skill：`references/complex-app/`。

## 版本控制与 `.gitignore`

- 若项目根**尚无** `.gitignore`：先征得用户同意新建，再**复制**模板根目录下的 `.gitignore` 到项目根。
- 该文件覆盖：`build/`、`deploy/`、常见 CMake 生成物、编辑器临时文件、可选 `.worktrees/` 等。
- 若团队已有全局 `.gitignore` 策略，可合并规则，但须保证 **`build/`、`deploy/` 仍被忽略**。
- 若使用前端构建并产生 `node_modules/`、`dist/` 等，在根或子目录 `.gitignore` 中补充忽略生成物。

## 目标架构与工具链选择

实施前与用户确认目标 CPU 与编译环境（本机 gcc、或 aarch64 交叉、或其它前缀），**勿在未确认时擅自假定**。

通过环境变量 **`ARCH`** 与 **`cmake/toolchain-*.cmake`** 选择工具链；由 `build.sh` 传入 `-DCMAKE_TOOLCHAIN_FILE=...`。至少要支持两种目标架构，默认选择 `x86`：

| `ARCH`（示例值） | 工具链文件（模板内） |
|------------------|----------------------|
| `x86`、`x86_64`、`X86` | `cmake/toolchain-x86_64.cmake` |
| `aarch64`、`arm64` | `cmake/toolchain-aarch64.cmake` |

自定义架构时：新增或修改 `cmake/toolchain-<name>.cmake`，并在 `build.sh` 中增加 `ARCH` 分支；与用户确认编译器前缀、`sysroot`、额外 `CFLAGS/LDFLAGS`。

工具链文件与 `build.sh` 内**禁止**写死仅适用于你个人机器的绝对路径；应通过变量或文档说明由用户在环境中提供工具链。

## 目录结构

```text
.
├── CMakeLists.txt
├── Config.h.in
├── README.md
├── build.sh
├── deploy.sh
├── git-version.sh
├── cmake/
│   ├── toolchain-x86_64.cmake
│   ├── toolchain-aarch64.cmake
│   └── thirdparty.cmake
├── configs/
│   ├── app.debug.json
│   ├── app.release.json
│   ├── zlog.debug.ini
│   └── zlog.release.ini
├── src/
│   ├── main.c
│   ├── app/
│   ├── config/
│   └── log/
├── web/               # 可选：Web/Lua/JS/HTML/CSS 等非 C 资源
├── thirdpart/         # 可选：离线依赖或本地第三方源码
├── build/
└── deploy/
```

说明：

| 路径 | 作用 |
|------|------|
| `CMakeLists.txt` | 聚合模块、链接 `cjson`/`zlog_s`/`pthread`、安装规则 |
| `cmake/thirdparty.cmake` | 使用 `FetchContent` 拉取 cJSON、zlog |
| `configs/` | 主配置与 zlog 配置模板（Debug/Release） |
| `src/config/` | JSON 配置解析与默认值处理 |
| `src/log/` | zlog 初始化与封装 |
| `src/app/` | 业务逻辑模块 |
| `src/main.c` | 参数解析、配置加载、启动入口 |
| `web/` | 可选静态资源或脚本资源目录 |
| `build.sh` | 构建入口，解析 `ARCH`、调用 CMake、执行构建和清除工作 |
| `deploy/` | 安装后的可执行文件、`app.json`、`zlog.ini` 及可选 Web 资源 |

复制新项目时，**必须**同步修改相关内容：

- `CMakeLists.txt` 中的项目名称和程序名 `PROGRAM_NAME`。
- `configs/*.json`、`configs/*.ini` 中的默认值与路径。
- 源码中的程序名和简介。
- `README.md` 中的构建、运行、配置说明。

## CMake 约定

版本约束：

- `cmake_minimum_required(VERSION 3.15)`。
- `CMAKE_C_STANDARD 11`，`CMAKE_C_EXTENSIONS OFF`。

版本信息：

- 版本字符串来自 `git-version.sh`，在配置阶段写入 `Config.h`。
- 生成构建时间，在配置阶段写入 `Config.h`。

**必须**支持构建两种版本，使用 `CMAKE_BUILD_TYPE` 区分：

- Release：`-O2`；
- Debug：`APP_DEBUG`、`-g -O0`；

依赖策略：

- 默认通过 `cmake/thirdparty.cmake` 拉取 cJSON、zlog（首次构建通常需要联网）。
- 离线场景可改为 `thirdpart/` 本地源码或系统库，并同步修改 CMake 配置。

## 根目录 `build.sh`（推荐入口）

`build.sh` 作为构建工作的入口，定义并解析选项参数，调用 CMake 执行构建和清除工作。

| 调用 | 行为 |
|------|------|
| `./build.sh` | **Release** 构建；out-of-source-tree 构建，生成物都在 `./build`，将需部署的文件安装到 `./deploy/` |
| `./build.sh debug` | **Debug** 构建；out-of-source-tree 构建，生成物都在 `./build`，将需部署的文件安装到 `./deploy/` |
| `./build.sh clean` | 清除 `./build/` 与 `./deploy/`（或等价空状态），可重新完整构建 |

每次非 `clean` 构建前会清空 `build/` 与 `deploy/`，属完整重构建。

必须提供 `--help` 选项，打印帮助信息。

示例：

```bash
ARCH=x86_64 ./build.sh
ARCH=aarch64 ./build.sh debug
```

复杂项目额外要求：安装后 `deploy/` 中除可执行文件外，必须包含：

- `app.json`（由 `configs/app.debug.json` 或 `configs/app.release.json` 复制/重命名而来）
- `zlog.ini`（由 `configs/zlog.debug.ini` 或 `configs/zlog.release.ini` 复制/重命名而来）

若存在 `web/` 目录，应通过 `install(DIRECTORY ...)` 一并安装到 `deploy/`。

## 配置文件（JSON + zlog INI）

主配置 JSON：

- 应用级键值（例如 `interval_seconds`、`zlog_config_path`）。
- `-f`/`--config` 指定时从该路径加载；未指定时默认当前工作目录 `app.json`。
- 解析失败、必填缺失、非法值须明确报错与非零退出码。

zlog INI：

- 使用 zlog 原生格式；不要把 zlog 规则写进 JSON。
- Debug/Release 可使用不同 ini，以区分 stdout 与文件输出策略。

## 日志（zlog）

- 仅用 zlog；不要退回 `inc/log.h` 宏方案。
- 日志需包含源位置（文件名、行号），具体格式由 zlog ini 控制。
- Debug/Release 的日志差异通过两套 ini + 构建类型拷贝实现。

## 命令行

- **必须**支持三个选项：`-h`/`--help`、`-v`/`--version`、`-f`/`--config`。
- 业务参数用 `getopt_long` 等；非法选项与多余位置参数须明确报错与退出码。

## 远程部署（`deploy.sh`）

支持用 `deploy.sh` 将本地 `./deploy/` 同步到远端目录（rsync over SSH）。

示例远端参数（请按项目/环境修改，不要写死内部地址）：

- 目标 IP：`<REMOTE_HOST>`
- 用户名：`<REMOTE_USER>`
- 目标路径：`<REMOTE_PATH>`

运行方式（仅询问密码，隐藏输入）：

```bash
./deploy.sh
```

## 复制为新项目的检查清单

1. 重命名项目名称，可执行目标与文档描述（`CMakeLists.txt` + `README.md`）。
2. 扩展 `src/*` 模块并更新 `CMakeLists.txt` 源文件和 include 路径。
3. 根目录若无 `.gitignore`，从模板复制（见「版本控制与 `.gitignore`」）。
4. 与用户确认 `ARCH` / 工具链（见「目标架构与工具链选择」）。
5. 若有 Web/Lua/JS 资源：放独立目录，补充安装规则与 `README.md`。
6. 若不再使用 JSON 或 zlog，应回到 `SKILL.md` 改选「小型」或「其他」。

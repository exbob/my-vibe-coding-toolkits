# 小型 Linux C 项目规范

> **前置条件**：用户已在上一级 `SKILL.md` 中明确选择 **「小型」**。三选项对比、面向用户的说明**仅**写在 `SKILL.md`，本文不重复。

本文档与 `references/small-app/` 配套：说明约定与流程；目录内为可编译**模板工程**。新建小型项目可复制该目录为仓库根，改工程名与业务逻辑；**关键文件（`CMakeLists.txt`、`build.sh`、`Config.h.in`、`git-version.sh`、`inc/log.h`、`cmake/toolchain-*.cmake` 等）建议沿用结构**，仅替换程序名与源码。

## 何时使用本文档（技术边界）

- 无磁盘上的应用主配置文件；运行期参数走**命令行**。
- 日志为 **`inc/log.h`** → stdout，不用 zlog 配置文件。
- 源码以 `src/`、`inc/` 为主，无强制的 `src/<模块>/` 划分。

## 模板根路径

相对本 Skill：`references/small-app/`。

## 版本控制与 `.gitignore`

- 若项目根**尚无** `.gitignore`：先征得用户同意新建，再**复制**模板根目录下的 `.gitignore` 到项目根。
- 该文件覆盖：`build/`、`deploy/`、常见 CMake 生成物、编辑器临时文件、可选 `.worktrees/` 等。
- 若团队已有全局 `.gitignore` 策略，可合并规则，但须保证 **`build/`、`deploy/` 仍被忽略**。

## 目标架构与工具链选择

实施前与用户确认目标 CPU 与编译环境（本机 gcc、或 aarch64 交叉、或其它前缀），**勿在未确认时擅自假定**。

通过环境变量 **`ARCH`** 与 **`cmake/toolchain-*.cmake`** 选择工具链；由 `build.sh` 传入 `-DCMAKE_TOOLCHAIN_FILE=...`。至少要支持两种目标架构，默认选择`x86`：

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
├── src/
├── inc/
├── build/
└── deploy/
```

说明：

| 路径 | 作用 |
|------|------|
| `CMakeLists.txt` | C11、Debug/Release、`APP_DEBUG`、`-Wall -Wextra`、生成 `Config.h` |
| `Config.h.in` | 注入 `GIT_VERSION`、`BUILD_TIME` 等到 `build/Config.h` |
| `git-version.sh` | 生成版本号，等价 `git describe --tags --always --long` |
| `build.sh` | 构建入口，解析 `ARCH`、调用 CMake、执行构建和清除工作 |
| `cmake/toolchain-*.cmake` | 存放 CMake 的配置文件，例如工具链配置 |
| `inc/` | 存放项目头文件 |
| `src/` | 存放项目源文件 |
| `deploy.sh` | 使用 rsync 将 `deploy/` 同步到远端目标机 |
| `build/` | CMake 构建过程生成的文件都放在这个路径下 |
| `deploy/` | 需要部署到运行环境的文件都安装到这个路径下 |
| `README.md` | 项目说明文件 |

复制新项目时，**必须**同步修改相关内容：

- `CMakeLists.txt` 中的项目名称和程序名 `PROGRAM_NAME` 。
- 源码中的程序名和简介。
- `README.md` 中的构建、运行、配置说明。

如果有其他文件类型可以新建文件夹：

- `docs/`: 存放文档。
- `thirdpart/`: 存放第三方模块的源码或者库文件。
- `configs/`: 存放其他配置文件或者脚本等。

## CMake 约定

版本约束：

- `cmake_minimum_required(VERSION 3.15)`。
- `CMAKE_C_STANDARD 11`，`CMAKE_C_EXTENSIONS OFF`。

版本信息：

- 版本字符串来自 `git-version.sh` ，在配置阶段写入 `Config.h`。
- 生成构建时间，在配置阶段写入 `Config.h`。

**必须**支持构建两种版本，使用 `CMAKE_BUILD_TYPE` 区分：

- Release：`-O2`；
- Debug：`APP_DEBUG`、`-g -O0`；

## 根目录 `build.sh`（推荐入口）

`build.sh` 作为构建工作的入口，定义并解析选项参数，调用 cmake 执行构建和清除工作。

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

## 日志（`log.h`）

- 仅用 `inc/log.h`；不要为小型项目引入 zlog 或文件日志配置。
- 日志级别：ERR、WARN、INFO、DEBUG（输出到 stdout）
- Debug 构建（定义 `APP_DEBUG`）下，日志包含 `__FILE__`/`__LINE__`
- Release 下日志为简短格式，`LOG_DEBUG` 为空操作

## 命令行

- **必须**使用命令行选项传递参数，不使用配置文件。
- **至少**支持两个选项：`-h`/`--help`（程序名、简介、选项说明）、`-v`/`--version`（程序名、简介、版本、构建时间等）。
- 业务参数用 `getopt_long` 等；非法选项与多余位置参数须明确报错与退出码。

## 远程部署（`deploy.sh`）

支持用 `deploy.sh` 会将本地 `./deploy/` 同步到远端目录（rsync over SSH）。

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
2. 替换或扩展 `src/main.c`，保持 `inc/` 与 `src/` 分工。
3. 根目录若无 `.gitignore`，从模板复制（见「版本控制与 `.gitignore`」）。
4. 与用户确认 `ARCH` / 工具链（见「目标架构与工具链选择」）。
5. 确认未引入主配置文件依赖；若后续需要 JSON/zlog，应回到 `SKILL.md` 改选「复杂」并换模板。

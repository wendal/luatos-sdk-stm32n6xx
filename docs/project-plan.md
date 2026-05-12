# STM32N647 + LuatOS 落地方案

## 目标

- 在 STM32N647 上完成 LuatOS 的基础移植和可持续开发骨架
- 让仓库一开始就具备计划、测试、构建入口、CI、开发流程、Git 规则与 AI 协作约束
- 为后续 BSP、驱动、板级调试和自动化烧录留出统一入口

## 推荐仓库结构

```text
.
├── .github/
│   ├── copilot-instructions.md
│   └── workflows/ci.yml
├── docs/
│   └── project-plan.md
├── scripts/
│   ├── check_repo.sh
│   ├── debug_luatos.sh
│   └── download_luatos.sh
├── boards/                 # 板级文件、pinmux、时钟、链接脚本
├── cmake/                  # 可选：未来切换到 CMake 时放 toolchain/module
├── external/               # 上游 LuatOS / STM32 HAL / CMSIS
├── src/                    # 端口层、应用层、板级 glue code
├── tests/                  # host 测试、脚本测试、HIL 用例说明
└── toolchains/             # 交叉编译工具链配置
```

这个结构参考了常见 STM32 固件仓库的拆分方式：文档、脚本、CI、上游依赖、本地端口层和测试职责分离，适合后续逐步导入 LuatOS、HAL/CMSIS 以及板级 BSP。

## 开发计划

### P0：仓库骨架与协作约束

- 完成 README、方案文档、Make 入口、脚本入口、CI
- 固化 Git 分支策略、提交规范、PR 校验规则
- 提供 AI 编写和自动化下载/调试的统一入口

### P1：板级启动与工具链打通

- 导入 STM32N647 启动文件、链接脚本、HAL/CMSIS
- 产出最小可运行固件：时钟初始化、串口日志、LED/心跳
- 打通 `build`、`flash`、`debug` 基本流程

### P2：LuatOS 移植

- 拉取 LuatOS 上游代码到 `external/LuatOS`
- 对接内存管理、系统时钟、日志、任务调度、tick、中断入口
- 跑通最小 Lua 脚本和串口 REPL

### P3：外设与板级能力

- GPIO / UART / SPI / I2C / ADC / PWM 基础驱动
- 文件系统、存储、网络等按板卡资源逐步接入
- 形成功能矩阵和回归用例

### P4：自动化增强

- 将当前 `make ci` 扩展为真实固件编译、静态检查、产物上传
- 对接自托管 runner 做 HIL（Hardware-in-the-loop）烟测
- 固化烧录和调试脚本，支持 AI 修改后自动执行预检

## 测试用例

| 级别 | 用例 | 触发时机 | 通过标准 |
| --- | --- | --- | --- |
| 仓库校验 | 文档/脚本/CI 资产完整性检查 | 每次 push / PR | `make ci` 通过 |
| Host 校验 | 配置脚本、代码生成脚本、包同步脚本 | 本地 / CI | Shell 语法正确，关键路径存在 |
| 板级烟测 | 上电日志、心跳灯、串口 REPL | 每次 bring-up | 启动后 5 秒内输出版本日志 |
| LuatOS 基础 | Lua 脚本执行、内存分配、定时器 | 每次端口变更 | 样例脚本运行成功 |
| 驱动回归 | UART/SPI/I2C/GPIO 回环或设备访问 | 驱动提交前 | 结果符合预期，日志无异常 |
| 下载调试 | OpenOCD 连接、GDB load/reset | 每次调试脚本变更 | 可连接 target 并装载 ELF |
| AI 协作 | AI 生成代码后是否补齐文档和测试 | 每次 AI 参与提交 | PR 模板项全部满足 |

建议后续在 `tests/` 中拆成：

- `tests/host/`: 本机可运行测试
- `tests/hil/`: 依赖板卡的烟测/回归脚本
- `tests/fixtures/`: Lua 示例脚本、串口输入输出基准

## 构建系统

当前仓库先采用顶层 `Makefile` 作为统一入口，原因是：

- 空仓库阶段最轻量，便于快速固化协作规范
- 后续既可以继续扩展 GNU Make，也可以平滑接入 CMake/Ninja
- CI、本地开发、AI 自动执行都能调用同一组命令

当前约定的关键目标：

- `make lint`: 校验 shell 脚本语法
- `make test`: 校验仓库骨架与文档关键章节
- `make ci`: CI 统一入口，串行执行 lint + test
- `make fetch-luatos DEST=external/LuatOS`: 下载或同步 LuatOS 上游
- `make debug`: 调起 OpenOCD + GDB 调试流程

后续在 P1/P2 阶段扩展：

- `make build`: 编译固件 ELF/BIN/HEX
- `make flash`: 烧录固件
- `make hil-smoke`: 对接板卡做自动化烟测

## CI流程

当前建议采用“两层 CI”：

1. **GitHub Hosted CI**
   - 校验文档、脚本、Make 入口
   - 后续扩展为交叉编译和静态检查
2. **Self-hosted HIL Runner**
   - 连接真实 STM32N647 开发板
   - 执行下载、启动、串口日志采集、调试冒烟

PR 基本流程：

1. checkout
2. `make ci`
3. 后续可扩展 `make build`
4. 上传构建产物
5. 如果是受保护分支，可选触发 HIL runner

## 开发流程

1. 先建 issue，明确板级目标/驱动范围/风险
2. 从 `main` 拉出 `feature/<topic>` 分支
3. AI 编写前先阅读本文档和 `.github/copilot-instructions.md`
4. 本地执行 `make ci`
5. 涉及固件逻辑时补充对应测试用例或 HIL 说明
6. 提交 PR，经过 review + CI 后合并
7. 版本节点使用 tag 管理，里程碑同步更新文档

## Git管理规则

- `main` 仅接收经过 PR 审核和 CI 通过的变更
- 功能开发使用 `feature/*`，缺陷修复使用 `fix/*`
- 禁止直接向 `main` push
- 禁止重写公共分支历史；需要修整历史时只在个人分支进行
- commit message 建议使用 `type: summary`，如 `docs: add stm32n647 project plan`
- 上游第三方代码统一放 `external/`，避免与本地移植层混放
- 板级改动必须同时更新文档/测试矩阵/调试说明

## AI编写/自动化下载/调试

### AI 编写

- 使用 `.github/copilot-instructions.md` 约束 AI 输出范围
- 让 AI 优先修改 `src/`、`boards/`、`tests/`，避免直接改动上游 vendor 代码
- AI 提交前必须运行统一入口：`make ci`

### 自动化下载

- 通过 `scripts/download_luatos.sh` 同步 LuatOS 上游
- 默认上游地址：`https://gitee.com/openLuat/LuatOS.git`
- 支持通过 `LUATOS_REPO_URL`、`LUATOS_REF` 覆盖源和分支

### 自动化调试

- 通过 `scripts/debug_luatos.sh` 启动 OpenOCD 与 `arm-none-eabi-gdb`
- 需要调用方提供：
  - `ELF_FILE`
  - `OPENOCD_CFG`
- 该流程适合作为：
  - 本地调试统一入口
  - 自托管 runner 的调试烟测步骤
  - AI 修改代码后的标准化验证脚本

## 当前最小落地资产

- README：说明仓库目标和快速开始
- Makefile：统一调用 lint/test/ci/fetch/debug
- CI workflow：确保仓库骨架本身可持续校验
- Copilot instructions：为 AI 协作补齐约束
- Shell scripts：给下载与调试保留可执行入口

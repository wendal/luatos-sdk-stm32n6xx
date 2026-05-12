# luatos-sdk-stm32n6xx

在 STM32N647 上适配 `openLuat/LuatOS` 主仓库并最终跑起 AirUI 的仓库骨架，先补齐开发计划、测试策略、构建入口、CI 流程、开发流程、Git 管理规则，以及 AI 编写/自动化下载/调试所需的最小自动化资产。

## 当前仓库内容

- `docs/project-plan.md`: STM32N647 + LuatOS 可执行方案总览
- `Makefile`: 仓库统一入口（lint/test/ci/fetch/debug）
- `scripts/download_luatos.sh`: 自动下载/同步 `https://github.com/openLuat/LuatOS`
- `scripts/debug_luatos.sh`: OpenOCD + GDB 调试入口
- `.github/workflows/ci.yml`: 基础 CI 校验流程
- `.github/copilot-instructions.md`: 面向 AI 编写的约束说明

## 快速开始

```sh
make help
make ci
make fetch-luatos DEST=external/LuatOS
ELF_FILE=build/luatos-stm32n647.elf OPENOCD_CFG=board/stm32n647.cfg make debug
```

## 推荐后续目录结构

```text
.
├── .github/
├── docs/
├── scripts/
├── boards/
├── cmake/
├── external/
├── src/
├── tests/
└── toolchains/
```

详细计划见 `docs/project-plan.md`。

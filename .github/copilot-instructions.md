# Copilot Instructions

- 先阅读 `docs/project-plan.md`，按其中的开发计划、测试策略和 Git 规则工作。
- 优先复用顶层 `Makefile` 的目标：`make lint`、`make test`、`make ci`、`make fetch-luatos`、`make debug`。
- 第三方上游代码放在 `external/`，端口层和板级代码放在 `src/` 与 `boards/`，不要混放。
- 修改固件逻辑时，同时更新对应测试用例、文档和调试说明。
- 任何 AI 生成的改动在提交前都要先通过 `make ci`。

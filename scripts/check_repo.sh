#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."

required_files='
README.md
Makefile
docs/project-plan.md
.github/copilot-instructions.md
.github/workflows/ci.yml
scripts/check_repo.sh
scripts/debug_luatos.sh
scripts/download_luatos.sh
'

for file in $required_files; do
	if [ ! -f "$file" ]; then
		echo "Missing required file: $file" >&2
		exit 1
	fi
done

for file in scripts/check_repo.sh scripts/debug_luatos.sh scripts/download_luatos.sh; do
	if [ ! -x "$file" ]; then
		echo "Script is not executable: $file" >&2
		exit 1
	fi
done

while IFS= read -r section; do
	[ -n "$section" ] || continue
	if ! grep -Fq "$section" docs/project-plan.md; then
		echo "Missing required section in docs/project-plan.md: $section" >&2
		exit 1
	fi
done <<'EOF'
## 开发计划
## 测试用例
## 构建系统
## CI流程
## 开发流程
## Git管理规则
## AI编写/自动化下载/调试
EOF

if ! grep -Fq "make ci" README.md; then
	echo "README.md must document the make ci entrypoint." >&2
	exit 1
fi

if ! grep -Fq "run: make ci" .github/workflows/ci.yml; then
	echo ".github/workflows/ci.yml must invoke make ci." >&2
	exit 1
fi

echo "Repository planning, CI, and automation assets validated."

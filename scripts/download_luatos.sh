#!/usr/bin/env sh
set -eu

DEST="${1:-external/LuatOS}"
REPO_URL="${LUATOS_REPO_URL:-https://gitee.com/openLuat/LuatOS.git}"
REF="${LUATOS_REF:-master}"

if [ -e "$DEST" ] && [ ! -d "$DEST/.git" ]; then
	echo "Destination exists but is not a git repository: $DEST" >&2
	exit 1
fi

if [ -d "$DEST/.git" ]; then
	echo "Updating LuatOS in $DEST from $REPO_URL ($REF)"
	git -C "$DEST" remote set-url origin "$REPO_URL"
	git -C "$DEST" fetch origin
	git -C "$DEST" checkout "$REF"
	git -C "$DEST" pull --ff-only origin "$REF"
else
	echo "Cloning LuatOS from $REPO_URL ($REF) into $DEST"
	mkdir -p "$(dirname "$DEST")"
	git clone --branch "$REF" "$REPO_URL" "$DEST"
fi

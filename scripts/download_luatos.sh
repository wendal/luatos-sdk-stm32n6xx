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
	if ! git -C "$DEST" pull --ff-only origin "$REF"; then
		echo "Fast-forward update failed for $DEST." >&2
		echo "Please inspect local changes or branch divergence before re-running the sync." >&2
		exit 1
	fi
else
	echo "Cloning LuatOS from $REPO_URL ($REF) into $DEST"
	mkdir -p "$(dirname "$DEST")"
	git clone --branch "$REF" "$REPO_URL" "$DEST"
fi

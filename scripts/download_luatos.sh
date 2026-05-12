#!/usr/bin/env sh
set -eu

DEST="${1:-external/LuatOS}"
REPO_URL="${LUATOS_REPO_URL:-https://github.com/openLuat/LuatOS.git}"
REF="${LUATOS_REF:-master}"

if [ -e "$DEST" ] && [ ! -d "$DEST/.git" ]; then
	echo "Destination exists but is not a git repository: $DEST" >&2
	exit 1
fi

if [ -d "$DEST/.git" ]; then
	echo "Updating LuatOS in $DEST from $REPO_URL ($REF)"
	git -C "$DEST" remote set-url origin "$REPO_URL"
	git -C "$DEST" fetch --tags origin
	git -C "$DEST" checkout "$REF"
	if git -C "$DEST" rev-parse --verify "refs/remotes/origin/$REF" >/dev/null 2>&1; then
		if ! git -C "$DEST" pull --ff-only origin "$REF"; then
			echo "Fast-forward update failed for $DEST." >&2
			git -C "$DEST" status --short --branch >&2 || true
			echo "Please inspect local changes, detached HEAD state, or branch divergence before re-running the sync." >&2
			echo "Suggested recovery: commit/stash local changes, checkout $REF, then retry." >&2
			exit 1
		fi
	else
		echo "Checked out non-branch ref $REF; skipping pull." >&2
	fi
else
	echo "Cloning LuatOS from $REPO_URL ($REF) into $DEST"
	mkdir -p "$(dirname "$DEST")"
	git clone --branch "$REF" "$REPO_URL" "$DEST"
fi

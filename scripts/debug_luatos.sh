#!/usr/bin/env sh
set -eu

: "${ELF_FILE:?Set ELF_FILE to the firmware ELF file}"
: "${OPENOCD_CFG:?Set OPENOCD_CFG to an OpenOCD config file}"

OPENOCD_BIN="${OPENOCD_BIN:-openocd}"
GDB_BIN="${GDB_BIN:-arm-none-eabi-gdb}"
GDB_PORT="${GDB_PORT:-3333}"
OPENOCD_LOG="${OPENOCD_LOG:-/tmp/luatos-stm32n647-openocd.log}"
OPENOCD_STARTUP_DELAY="${OPENOCD_STARTUP_DELAY:-2}"

"$OPENOCD_BIN" -f "$OPENOCD_CFG" >"$OPENOCD_LOG" 2>&1 &
OPENOCD_PID=$!

cleanup() {
	if kill -0 "$OPENOCD_PID" 2>/dev/null; then
		kill "$OPENOCD_PID"
		wait "$OPENOCD_PID" 2>/dev/null || true
	fi
}

trap cleanup EXIT INT TERM

sleep "$OPENOCD_STARTUP_DELAY"

if ! kill -0 "$OPENOCD_PID" 2>/dev/null; then
	echo "OpenOCD failed to start. Log output:" >&2
	cat "$OPENOCD_LOG" >&2
	exit 1
fi

"$GDB_BIN" "$ELF_FILE" \
	-ex "target extended-remote :$GDB_PORT" \
	-ex "monitor reset halt" \
	-ex "load" \
	-ex "monitor reset init"

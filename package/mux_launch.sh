#!/bin/sh
# HELP: Set up a Bluetooth controller or audio source
# ICON: bluetooth
# GRID: Bluetooth

. /opt/muos/script/var/func.sh

echo app >/tmp/ACT_GO

LOVEDIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/application/Bluetooth"
GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/gptokeyb/gptokeyb2"
BINDIR="$LOVEDIR/bin"

SDL_GAMECONTROLLERCONFIG_FILE="/usr/lib/gamecontrollerdb.txt"
LD_LIBRARY_PATH="$BINDIR/libs.aarch64:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG_FILE LD_LIBRARY_PATH

MODULE_NAME="rtl_btlpm"
BTD_CMD="/usr/libexec/bluetooth/bluetoothd -n -d"
HCI_ATTACH_CMD="rtk_hciattach -n -s 115200 /dev/ttyS1 rtk_h5"

LOAD_MODULE() {
	if modinfo "$MODULE_NAME" >/dev/null 2>&1 && ! lsmod | grep -q "^$MODULE_NAME"; then
		modprobe "/lib/modules/4.9.170/kernel/drivers/bluetooth/$MODULE_NAME.ko"
	fi

	if ! pgrep -x "rtk_hciattach" >/dev/null; then
		$HCI_ATTACH_CMD >"$(GET_VAR "device" "storage/rom/mount")/MUOS/log/rtk_hciattach.log" 2>&1 &
	fi
}

START_BLUETOOTH() {
	if ! pgrep -x "bluetoothd" >/dev/null; then
		for _ in $(seq 1 5); do
			command -v hciconfig >/dev/null && hciconfig hci0 | grep -q "UP" && break
			sleep 1
		done
		$BTD_CMD >"$(GET_VAR "device" "storage/rom/mount")/MUOS/log/bluetoothd.log" 2>&1 &
	fi
}

START_INTERFACE() {
	if command -v hciconfig >/dev/null && hciconfig hci0 | grep -q "DOWN"; then
		START_RTK_HCIATTACH
		sleep 7
		hciconfig hci0 up
		sleep 1
	fi
}

# Execute Bluetooth function stuff
# LOAD_MODULE
# START_BLUETOOTH
# START_INTERFACE

# Launcher
cd "$LOVEDIR" || exit
SET_VAR "SYSTEM" "FOREGROUND_PROCESS" "love"

# Run Application
$GPTOKEYB "love" &
"$BINDIR/love" .
kill -9 "$(pidof gptokeyb2)" 2>/dev/null

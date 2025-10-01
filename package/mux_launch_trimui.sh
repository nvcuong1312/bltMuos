#!/bin/sh
# HELP: Set up a Bluetooth controller or audio source
# ICON: bluetooth
# GRID: Bluetooth

. /opt/muos/script/var/func.sh

echo app >/tmp/ACT_GO

LOVEDIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/application/Bluetooth"
GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/gptokeyb/gptokeyb2.armhf"
BINDIR="$LOVEDIR/bin"

SDL_GAMECONTROLLERCONFIG_FILE="/usr/lib/gamecontrollerdb.txt"
LD_LIBRARY_PATH="$BINDIR/libs.aarch64:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG_FILE LD_LIBRARY_PATH

# Launcher
cd "$LOVEDIR" || exit
SET_VAR "SYSTEM" "FOREGROUND_PROCESS" "love"

# Run Application
"love" &
"$BINDIR/love" .
kill -9 "$(pidof gptokeyb2)" 2>/dev/null

#!/bin/sh
# HELP: Set up a Bluetooth controller or audio source
# ICON: bluetooth
# GRID: Bluetooth

. /opt/muos/script/var/func.sh

echo app >/tmp/act_go

GOV_GO="/tmp/gov_go"
[ -e "$GOV_GO" ] && cat "$GOV_GO" >"$(GET_VAR "device" "cpu/governor")"

SETUP_SDL_ENVIRONMENT

LOVEDIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/application/Bluetooth"

PM_DIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/PortMaster"
GPTOKEYB="${PM_DIR}/gptokeyb2"
BINDIR="$LOVEDIR/bin"

LD_LIBRARY_PATH="$BINDIR/libs.aarch64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH

# Launcher
cd "$LOVEDIR" || exit
SET_VAR "system" "foreground_process" "love"

# Run Application
"${GPTOKEYB}" "$BINDIR/love" &
"$BINDIR/love" .
kill -9 "$(pidof gptokeyb2)" 2>/dev/null

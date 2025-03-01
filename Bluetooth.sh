#!/bin/bash
# ICON: bluetooth
. /opt/muos/script/var/func.sh

if pgrep -f "playbgm.sh" >/dev/null; then
	killall -q "playbgm.sh" "mpg123"
fi

echo app >/tmp/act_go

# Define paths and commands
LOVEDIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/application/.bluetooth"
GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/gptokeyb/gptokeyb2.armhf"
BINDIR="$LOVEDIR/bin"

# Export environment variables
export SDL_GAMECONTROLLERCONFIG_FILE="/usr/lib/gamecontrollerdb.txt"
export LD_LIBRARY_PATH="$BINDIR/libs.aarch64:$LD_LIBRARY_PATH"

if ! ifconfig wlan0 >/dev/null 2>&1; then
	if ! lsmod | grep -wq "$(GET_VAR "device" "network/name")"; then
		rmmod "$(GET_VAR "device" "network/module")"
		sleep 1
		modprobe --force-modversion "$(GET_VAR "device" "network/module")"
		while [ ! -d "/sys/class/net/$(GET_VAR "device" "network/iface")" ]; do
			sleep 1
		done
	fi

	rfkill unblock all
	ip link set "$(GET_VAR "device" "network/iface")" up
	iw dev "$(GET_VAR "device" "network/iface")" set power_save off
fi

MODULE_NAME="rtl_btlpm"
if ! lsmod | grep -q "^$MODULE_NAME"; then
    modprobe /lib/modules/4.9.170/kernel/drivers/bluetooth/rtl_btlpm.ko
fi

if ! pgrep -f "rtk_hciattach -n -s 115200 /dev/ttyS1 rtk_h5" > /dev/null; then
    rtk_hciattach -n -s 115200 /dev/ttyS1 rtk_h5 > /mnt/mmc/MUOS/log/rtk_hciattach.log 2>&1 &
	sleep 2
fi

if ! pgrep -f "/usr/libexec/bluetooth/bluetoothd -n -d" > /dev/null; then    
    for i in {1..5}; do
        if hciconfig hci0 | grep -q "UP"; then
            break
        fi
        sleep 1
    done

    /usr/libexec/bluetooth/bluetoothd -n -d > /mnt/mmc/MUOS/log/bluetoothd.log 2>&1 &
fi

# Launcher
cd "$LOVEDIR" || exit
SET_VAR "system" "foreground_process" "love"

# Run Application
$GPTOKEYB "love" &
./bin/love .
kill -9 "$(pidof gptokeyb2.armhf)"

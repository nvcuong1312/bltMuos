#!/bin/sh
# Bluetooth init script (runs at boot from MUOS/init)
#
# Problem (seen on an RG35XX H, muOS 2601.1 Jacaranda): the Bluetooth chip
# (Realtek RTL8821CS, attached over UART with the H5 protocol via
# rtk_hciattach) sometimes stops answering. The
# kernel logs "Bluetooth: hci0 command 0x.... tx timeout", hciconfig shows
# the TX command counter growing while the RX event counter is frozen, and
# headphones/controllers can no longer connect until a reboot. The previous
# version of this script attached the chip once and never checked on it again.
#
# This script:
#   1. power-cycles the chip (rfkill "sunxi-bt") before attaching it, so it
#      always starts from a clean state;
#   2. checks every 20 s that the chip still answers (HCI Read Local Name);
#   3. after 3 failed checks in a row, power-cycles and re-attaches the chip
#      and powers the adapter back on. bluetoothd picks the adapter up again
#      on its own and paired devices can reconnect.
#
# The watchdog stays out of the way when Bluetooth is deliberately off
# (adapter "Powered: no") or when bluetoothd is not running (e.g. while the
# Bluetooth app restarts the stack itself).

LOG_DIR="/mnt/mmc/MUOS/log"
WD_LOG="$LOG_DIR/bt_watchdog.log"
HCI_ATTACH="rtk_hciattach -n -s 115200 /dev/ttyS1 rtk_h5"
BTD="/usr/libexec/bluetooth/bluetoothd"
MODULE="/lib/modules/4.9.170/kernel/drivers/bluetooth/rtl_btlpm.ko"

CHECK_INTERVAL=20
MAX_FAILS=3

log() { echo "$(date '+%F %T') $*" >>"$WD_LOG"; }

running() { pidof "$1" >/dev/null 2>&1; }

power_cycle_chip() {
	for R in /sys/class/rfkill/rfkill*; do
		[ "$(cat "$R/name" 2>/dev/null)" = "sunxi-bt" ] || continue
		echo 1 >"$R/soft"
		sleep 1
		echo 0 >"$R/soft"
	done
	sleep 1
}

chip_answers() {
	timeout 5 hciconfig hci0 name 2>/dev/null | grep -q "Name:"
}

attach_chip() {
	killall rtk_hciattach 2>/dev/null
	sleep 1
	power_cycle_chip

	$HCI_ATTACH >"$LOG_DIR/rtk_hciattach.log" 2>&1 &

	# wait for hci0 to show up, then for the firmware to finish loading
	for _ in $(seq 1 10); do
		[ -d /sys/class/bluetooth/hci0 ] && break
		sleep 1
	done
	[ -d /sys/class/bluetooth/hci0 ] || { log "hci0 did not appear"; return 1; }

	for _ in $(seq 1 15); do
		hciconfig hci0 up 2>/dev/null
		chip_answers && return 0
		sleep 1
	done
	log "chip attached but not answering yet"
	return 1
}

start_bluetoothd() {
	running bluetoothd && return 0
	$BTD -n -d >"$LOG_DIR/bluetoothd.log" 2>&1 &
	for _ in $(seq 1 8); do
		running bluetoothd && return 0
		sleep 1
	done
	log "bluetoothd failed to start"
	return 1
}

# "Powered: no" means the user switched Bluetooth off. A missing controller
# ("No default controller available") is NOT that - it is a failure.
adapter_switched_off() {
	timeout 5 bluetoothctl show 2>/dev/null | grep -q "Powered: no"
}

# --- boot -------------------------------------------------------------------

lsmod | grep -q "^rtl_btlpm" || modprobe "$MODULE" 2>/dev/null

attach_chip && log "chip attached" || log "chip attach had problems, watchdog will retry"
start_bluetoothd
sleep 1
bluetoothctl power on >/dev/null 2>&1

# --- watchdog ---------------------------------------------------------------

FAILS=0
while true; do
	sleep "$CHECK_INTERVAL"

	# Bluetooth stopped or switched off on purpose: nothing to watch
	if ! running bluetoothd || adapter_switched_off; then
		FAILS=0
		continue
	fi

	if chip_answers; then
		FAILS=0
		continue
	fi

	FAILS=$((FAILS + 1))
	[ "$FAILS" -lt "$MAX_FAILS" ] && continue

	log "chip not answering ($FAILS checks), recovering"
	if attach_chip; then
		bluetoothctl power on >/dev/null 2>&1
		log "recovered"
	else
		log "recovery failed, will try again"
	fi
	FAILS=0
done

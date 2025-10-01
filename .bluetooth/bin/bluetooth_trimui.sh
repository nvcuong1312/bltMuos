#!/bin/sh

rtk_hciattach -n -s 115200 ttyS1 xradio > /mnt/mmc/MUOS/log/rtk_hciattach.log 2>&1 &
sleep 3
/usr/libexec/bluetooth/bluetoothd -n -d > /mnt/mmc/MUOS/log/bluetoothd.log 2>&1 &
sleep 10
bluetoothctl power on

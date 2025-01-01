#!/bin/sh
modprobe /lib/modules/4.9.170/kernel/drivers/bluetooth/rtl_btlpm.ko
rtk_hciattach -n -s 115200 /dev/ttyS1 rtk_h5 > /mnt/mmc/MUOS/log/rtk_hciattach.log 2>&1 &
/usr/libexec/bluetooth/bluetoothd -n -d > /mnt/mmc/MUOS/log/bluetoothd.log 2>&1 &
sleep 10 # YAY more hacks
bluetoothctl power on

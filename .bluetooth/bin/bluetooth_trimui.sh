#!/bin/sh

start_hci_attach()
{
	rtk_hciattach -n -s 115200 ttyS1 xradio > /mnt/mmc/MUOS/log/rtk_hciattach.log 2>&1 &
	sleep 1

	wait_hci0_count=0
	while true
	do
		[ -d /sys/class/bluetooth/hci0 ] && break
		sleep 1
		let wait_hci0_count++
		[ $wait_hci0_count -eq 8 ] && {
			echo "bring up hci0 failed"
			exit 1
		}
	done
}

start_hci()
{
    hci_is_up=`hciconfig hci0 | grep RUNNING`
    [ -z "$hci_is_up" ] && {
        hciconfig hci0 up
	}
}

start_bluetooth()
{
    /usr/libexec/bluetooth/bluetoothd -n -d > /mnt/mmc/MUOS/log/bluetoothd.log 2>&1 &
    sleep 1
    
    wait_bluetoothd_count=0
    while true
    do
        d=`ps | grep bluetoothd | grep -v grep`
        [ -n "$d" ] && break
        sleep 1
        let wait_bluetoothd_count++
        [ $wait_bluetoothd_count -eq 8 ] && {
            echo "start bluetoothd failed"
            exit 1
        }
    done

    bluetoothctl power on
}

start_hci_attach
start_hci
start_bluetooth
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

setup_persistent_storage()
{
    # Clean up old symlink(s)
    find /var/lib/bluetooth -name ??:??:??:??:??:?? -type l -exec unlink {} \;
    bdaddr=`hciconfig hci0 | awk '/BD Address/ {print $3}'`
    # Make sure the persistent storage directory exists
    mkdir -p /var/lib/bluetooth/persistent_storage
    # Create link with current random address and then bluetoothd can start using it
    ln -sf persistent_storage "/var/lib/bluetooth/$bdaddr"
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
setup_persistent_storage
start_bluetooth

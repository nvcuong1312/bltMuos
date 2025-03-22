#!/bin/sh
# ICON: bluetooth

if [ -d "BluetoothData" ]; then
  rm -r "BluetoothData"
fi

is_reboot=false

wget -P "BluetoothData/" https://github.com/nvcuong1312/bltMuos/archive/refs/heads/main.zip
if unzip -o "BluetoothData/main.zip" -d "BluetoothData/"; then

	if [ -d "/mnt/mmc/MUOS/application/.bluetooth" ]; then
	  rm -r "/mnt/mmc/MUOS/application/.bluetooth"
	fi

	mv "BluetoothData/bltMuos-main/.bluetooth" "/mnt/mmc/MUOS/application/"
	mv "BluetoothData/bltMuos-main/Bluetooth.sh" "/mnt/mmc/MUOS/application/"

	cp "/mnt/mmc/MUOS/application/.bluetooth/Assets/ic_bluetooth.png" "/opt/muos/default/MUOS/theme/active/glyph/muxapp/bluetooth.png"
	cp "/mnt/mmc/MUOS/application/.bluetooth/Assets/ic_bluetooth.png" "/opt/muos/default/MUOS/theme/active/glyph/muxtask/bluetooth.png"
	
	cp "BluetoothData/bltMuos-main/BluetoothLoader.sh" "/mnt/mmc/MUOS/task/BluetoothLoader.sh"
	
	# Check Init
	if [ "$(cat /run/muos/global/settings/advanced/user_init)" != "1" ]; then
		echo "1" > "/run/muos/global/settings/advanced/user_init"
		is_reboot=true
	fi

	if [ ! -f "/mnt/mmc/MUOS/init/bluetooth.sh" ]; then
		mv "/mnt/mmc/MUOS/application/.bluetooth/bin/bluetooth.sh" "/mnt/mmc/MUOS/init/bluetooth.sh"
		is_reboot=true
	fi
	
	if [ -d "/mnt/sdcard/MUOS/init" ]; then
	    rm -r "/mnt/sdcard/MUOS/init"
	    is_reboot=true
	fi
	
	echo "Done!"
else
	echo "Error!"
fi

echo "-----------------------------------"
echo "|Author     : CuongNV             |"
echo "|Complete!                        |"
echo "|Thanks!                          |"
echo "-----------------------------------"
sleep 3

if $is_reboot; then
	echo "Restarting OS ..."
	sleep 2
	/opt/muos/script/mux/quit.sh reboot frontend
fi
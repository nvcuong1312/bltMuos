#!/bin/sh
# ICON: bluetooth

if [ -d "BluetoothData" ]; then
  rm -r "BluetoothData"
fi

is_reboot=false

wget -P "BluetoothData/" https://github.com/nvcuong1312/bltMuos/archive/refs/heads/dev.zip
if unzip -o "BluetoothData/dev.zip" -d "BluetoothData/UnzipData/"; then

	if [ -d "mnt/mmc/MUOS/application/.bluetooth" ]; then
	  rm -r "mnt/mmc/MUOS/application/.bluetooth"
	fi

	if [ -e "mnt/mmc/MUOS/application/Bluetooth.sh" ]; then
		rm -r "mnt/mmc/MUOS/application/Bluetooth.sh"
	fi

	if [ -e "opt/muos/default/MUOS/theme/active/glyph/muxapp/bluetooth.png" ]; then
		rm -r "opt/muos/default/MUOS/theme/active/glyph/muxapp/bluetooth.png"
	fi

	if [ -e "opt/muos/default/MUOS/theme/active/glyph/muxtask/bluetooth.png" ]; then
		rm -r "opt/muos/default/MUOS/theme/active/glyph/muxtask/bluetooth.png"
	fi

	mv "BluetoothData/UnzipData/bltMuos-dev/.bluetooth" "mnt/mmc/MUOS/application/"
	mv "BluetoothData/UnzipData/bltMuos-dev/Bluetooth.sh" "mnt/mmc/MUOS/application/Bluetooth.sh"

	cp "mnt/mmc/MUOS/application/.bluetooth/bin/bluetooth.png" "opt/muos/default/MUOS/theme/active/glyph/muxapp/bluetooth.png"
	cp "mnt/mmc/MUOS/application/.bluetooth/bin/bluetooth.png" "opt/muos/default/MUOS/theme/active/glyph/muxtask/bluetooth.png"
	
	if [ -e "mnt/mmc/MUOS/task/BluetoothLoader_dev.sh" ]; then
		rm -r "mnt/mmc/MUOS/task/BluetoothLoader_dev.sh"
	fi
	
	cp "BluetoothData/UnzipData/bltMuos-dev/BluetoothLoader_dev.sh" "mnt/mmc/MUOS/task/BluetoothLoader_dev.sh"
	
	# Check Init
	if [ "$(cat /run/muos/global/settings/advanced/user_init)" != "1" ]; then
		echo "1" > "/run/muos/global/settings/advanced/user_init"
		is_reboot=true
	fi

	if [ ! -f "mnt/mmc/MUOS/init/bluetooth.sh" ]; then
		mv "mnt/mmc/MUOS/application/.bluetooth/bin/bluetooth.sh" "mnt/mmc/MUOS/init/bluetooth.sh"
		is_reboot=true
	fi
	
	if [ -d "mnt/sdcard/MUOS/init" ]; then
	    rm -r "mnt/sdcard/MUOS/init"
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
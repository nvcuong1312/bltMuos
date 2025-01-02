#!/bin/sh

if [ -d "BluetoothData" ]; then
  rm -r "BluetoothData"
fi

wget -P "BluetoothData/" https://github.com/nvcuong1312/bltMuos/archive/refs/heads/dev.zip
unzip -o "BluetoothData/dev.zip" -d "BluetoothData/UnzipData/"

if [ -d "mnt/mmc/MUOS/application/.bluetooth" ]; then
  rm -r "mnt/mmc/MUOS/application/.bluetooth"
fi

if [ -e "mnt/mmc/MUOS/application/Bluetooth.sh" ]; then
    rm -r "mnt/mmc/MUOS/application/Bluetooth.sh"
fi

if [ -e "mnt/mmc/MUOS/theme/active/glyph/muxapp/bluetooth.png" ]; then
    rm -r "mnt/mmc/MUOS/theme/active/glyph/muxapp/bluetooth.png"
fi

mv "BluetoothData/UnzipData/bltMuos-dev/.bluetooth" "mnt/mmc/MUOS/application/"
mv "BluetoothData/UnzipData/bltMuos-dev/Bluetooth.sh" "mnt/mmc/MUOS/application/Bluetooth.sh"
mv "mnt/mmc/MUOS/application/.bluetooth/bin/bluetooth.png" "mnt/mmc/MUOS/theme/active/glyph/muxapp/bluetooth.png"

echo "-----------------------------------"
echo "|Author     : CuongNV             |"
echo "|Complete!                        |"
echo "|Thanks!                          |"
echo "-----------------------------------"
sleep 3

# Check Init
is_reboot=false
if [ "$(cat /run/muos/global/settings/advanced/user_init)" != "1" ]; then
	echo "1" > "/run/muos/global/settings/advanced/user_init"
	is_reboot=true
fi

if [ ! -f "mnt/mmc/MUOS/init/bluetooth.sh" ]; then
    mv "mnt/mmc/MUOS/application/.bluetooth/bin/bluetooth.sh" "mnt/mmc/MUOS/init/bluetooth.sh"
	is_reboot=true
fi

if $is_reboot; then
	echo "Restarting OS ..."
	sleep 2
	/opt/muos/script/mux/quit.sh reboot frontend
fi
#!/bin/sh
# ICON: bluetooth

if [ -d "BluetoothData" ]; then
  rm -r "BluetoothData"
fi

wget -P "BluetoothData/" https://github.com/nvcuong1312/bltMuos/archive/refs/heads/main.zip
unzip -o "BluetoothData/main.zip" -d "BluetoothData/UnzipData/"

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

mv "BluetoothData/UnzipData/bltMuos-main/.bluetooth" "mnt/mmc/MUOS/application/"
mv "BluetoothData/UnzipData/bltMuos-main/Bluetooth.sh" "mnt/mmc/MUOS/application/Bluetooth.sh"

cp "mnt/mmc/MUOS/application/.bluetooth/bin/bluetooth.png" "opt/muos/default/MUOS/theme/active/glyph/muxapp/bluetooth.png"
cp "mnt/mmc/MUOS/application/.bluetooth/bin/bluetooth.png" "opt/muos/default/MUOS/theme/active/glyph/muxtask/bluetooth.png"

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
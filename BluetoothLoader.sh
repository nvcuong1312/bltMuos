#!/bin/sh

. /opt/muos/script/var/func.sh

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

if [ -e "opt/muos/theme/glyph/muxapp/bluetooth.png" ]; then
    rm -r "opt/muos/theme/glyph/muxapp/bluetooth.png"
fi

mv "BluetoothData/UnzipData/bltMuos-main/.bluetooth" "mnt/mmc/MUOS/application/"
mv "BluetoothData/UnzipData/bltMuos-main/Bluetooth.sh" "mnt/mmc/MUOS/application/Bluetooth.sh"
mv "BluetoothData/UnzipData/bltMuos-main/opt/muos/theme/glyph/muxapp/bluetooth.png" "opt/muos/theme/glyph/muxapp/bluetooth.png"


echo "-----------------------------------"
echo "|Author     : CuongNV             |"
echo "|Complete!                        |"
echo "|Thanks!                          |"
echo "-----------------------------------"
sleep 5

if [ -e "mnt/mmc/MUOS/init/bluetooth.sh" ]; then
    mv "mnt/mmc/MUOS/application/.bluetooth/bin/bluetooth.sh" "mnt/mmc/init/bluetooth.sh"
	SET_VAR "global" "settings/advanced/user_init" "1"
fi 

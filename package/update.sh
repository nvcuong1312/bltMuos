#!/bin/sh

. /opt/muos/script/var/func.sh

chmod +x /usr/bin/expect

SET_VAR "global" "settings/advanced/user_init" "1"
/opt/muos/script/system/halt.sh reboot

sleep infinity
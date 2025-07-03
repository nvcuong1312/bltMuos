#!/bin/sh

. /opt/muos/script/var/func.sh

chmod +x /usr/bin/expect

SET_VAR "global" "settings/advanced/user_init" "1"

setsid bash -c '
/opt/muos/script/system/halt.sh reboot
'
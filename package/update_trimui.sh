#!/bin/sh

. /opt/muos/script/var/func.sh

chmod +x /usr/bin/expect
chmod +x /bin/bluetoothctl /bin/hciattach /bin/hciconfig /bin/hcidump /bin/hcitool
chmod +x /usr/libexec/bluetooth/bluetoothd

[ -f "/opt/muos/expect/usr/bin/expect" ] && rm -f "/opt/muos/expect/usr/bin/expect" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_autoexpect" ] && rm -f "/opt/muos/expect/usr/bin/expect_autoexpect" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_autopasswd" ] && rm -f "/opt/muos/expect/usr/bin/expect_autopasswd" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_cryptdir" ] && rm -f "/opt/muos/expect/usr/bin/expect_cryptdir" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_decryptdir" ] && rm -f "/opt/muos/expect/usr/bin/expect_decryptdir" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_dislocate" ] && rm -f "/opt/muos/expect/usr/bin/expect_dislocate" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_ftp-rfc" ] && rm -f "/opt/muos/expect/usr/bin/expect_ftp-rfc" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_kibitz" ] && rm -f "/opt/muos/expect/usr/bin/expect_kibitz" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_lpunlock" ] && rm -f "/opt/muos/expect/usr/bin/expect_lpunlock" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_mkpasswd" ] && rm -f "/opt/muos/expect/usr/bin/expect_mkpasswd" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_multixterm" ] && rm -f "/opt/muos/expect/usr/bin/expect_multixterm" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_passmass" ] && rm -f "/opt/muos/expect/usr/bin/expect_passmass" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_rftp" ] && rm -f "/opt/muos/expect/usr/bin/expect_rftp" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_rlogin-cwd" ] && rm -f "/opt/muos/expect/usr/bin/expect_rlogin-cwd" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_timed-read" ] && rm -f "/opt/muos/expect/usr/bin/expect_timed-read" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_timed-run" ] && rm -f "/opt/muos/expect/usr/bin/expect_timed-run" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_tknewsbiff" ] && rm -f "/opt/muos/expect/usr/bin/expect_tknewsbiff" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_tkpasswd" ] && rm -f "/opt/muos/expect/usr/bin/expect_tkpasswd" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_unbuffer" ] && rm -f "/opt/muos/expect/usr/bin/expect_unbuffer" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_weather" ] && rm -f "/opt/muos/expect/usr/bin/expect_weather" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_xkibitz" ] && rm -f "/opt/muos/expect/usr/bin/expect_xkibitz" 2>/dev/null
[ -f "/opt/muos/expect/usr/bin/expect_xpstat" ] && rm -f "/opt/muos/expect/usr/bin/expect_xpstat" 2>/dev/null
[ -f "/opt/muos/expect/usr/lib/libexpect.so.5.45.4" ] && rm -f "/opt/muos/expect/usr/lib/libexpect.so.5.45.4" 2>/dev/null
[ -f "/opt/muos/expect/usr/lib/tcltk/expect5.45.4/pkgIndex.tcl" ] && rm -f "/opt/muos/expect/usr/lib/tcltk/expect5.45.4/pkgIndex.tcl" 2>/dev/null
[ -f "/opt/muos/expect/usr/share/doc/expect/changelog.Debian.arm64.gz" ] && rm -f "/opt/muos/expect/share/doc/expect/changelog.Debian.arm64.gz" 2>/dev/null
[ -f "/opt/muos/expect/usr/share/doc/expect/changelog.Debian.gz" ] && rm -f "/opt/muos/expect/share/doc/expect/changelog.Debian.gz" 2>/dev/null
[ -f "/opt/muos/expect/usr/share/doc/expect/changelog.gz" ] && rm -f "/opt/muos/expect/share/doc/expect/changelog.gz" 2>/dev/null
[ -f "/opt/muos/expect/usr/share/doc/expect/copyright" ] && rm -f "/opt/muos/expect/share/doc/expect/copyright" 2>/dev/null
[ -f "/opt/muos/expect/usr/share/doc/expect/FAQ.gz" ] && rm -f "/opt/muos/expect/share/doc/expect/FAQ.gz" 2>/dev/null
[ -f "/opt/muos/expect/usr/share/doc/expect/NEWS.Debian.gz" ] && rm -f "/opt/muos/expect/share/doc/expect/NEWS.Debian.gz" 2>/dev/null
[ -f "/opt/muos/expect/usr/share/doc/expect/NEWS.gz" ] && rm -f "/opt/muos/expect/share/doc/expect/NEWS.gz" 2>/dev/null
[ -f "/opt/muos/expect/usr/share/doc/expect/README.gz" ] && rm -f "/opt/muos/expect/share/doc/expect/README.gz" 2>/dev/null

[ -d "/opt/muos/expect/usr/bin" ] && rmdir "/opt/muos/expect/usr/bin" 2>/dev/null
[ -d "/opt/muos/expect/usr/lib/tcltk/expect5.45.4" ] && rmdir "/opt/muos/expect/usr/lib/tcltk/expect5.45.4" 2>/dev/null
[ -d "/opt/muos/expect/usr/lib/tcltk" ] && rmdir "/opt/muos/expect/usr/lib/tcltk" 2>/dev/null
[ -d "/opt/muos/expect/usr/lib" ] && rmdir "/opt/muos/expect/usr/lib" 2>/dev/null
[ -d "/opt/muos/expect/usr/share/doc/expect" ] && rmdir "/opt/muos/expect/usr/share/doc/expect" 2>/dev/null
[ -d "/opt/muos/expect/usr/share/doc" ] && rmdir "/opt/muos/expect/usr/share/doc" 2>/dev/null
[ -d "/opt/muos/expect/usr/share" ] && rmdir "/opt/muos/expect/usr/share" 2>/dev/null
[ -d "/opt/muos/expect/usr" ] && rmdir "/opt/muos/expect/usr" 2>/dev/null
[ -d "/opt/muos/expect" ] && rmdir "/opt/muos/expect" 2>/dev/null

cd /usr/lib && ln -s libexpect.so.5.45.4 libexpect.so && ln -s libexpect.so.5.45.4 libexpect.so.5.45 && ln -s libtcl8.6.so.0 libtcl8.6.so

files="
expect
expect_autoexpect
expect_autopasswd
expect_cryptdir
expect_decryptdir
expect_dislocate
expect_ftp-rfc
expect_kibitz
expect_lpunlock
expect_mkpasswd
expect_multixtermc
expect_passmass
expect_rftp
expect_rlogin-cwd
expect_timed-read
expect_timed-run
expect_tknewsbiff
expect_tkpasswd
expect_unbuffer
expect_weather
expect_xkibitz
expect_xpstat
"

# Iterate over the files and make them executable
for file in $files; do
    if [ -f "/usr/bin/$file" ]; then
        chmod +x "/usr/bin/$file"
    else
        echo "Warning: /usr/bin/$file does not exist"
    fi
done


SET_VAR "global" "settings/advanced/user_init" "1"

setsid bash -c '
/opt/muos/script/system/halt.sh reboot
'
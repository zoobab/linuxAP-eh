#!/bin/sh
#
# network
#
# Bring up the network interfaces
#
case "$1" in
  start)
    while read iface_line
    do
        case "$iface_line" in
          #*) : ;;
          eth*|wlan*|br*) set $iface_line
            /etc/rc.d/init.d/iface.i $*
        esac
    done < $CFGD/interfaces
    ;;
  stop)
    killall udhcpc > /dev/null 2>&1
    while read iface_line
    do
        case "$iface_line" in
          #*) : ;;
          eth*|wlan*|br*) set $iface_line
            ifconfig $1 down
        esac
    done < $CFGD/interfaces
    ;;    
esac
exit 0

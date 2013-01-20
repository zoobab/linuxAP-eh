#!/bin/sh
CFGDIR="/etc/cipe/peers"
set -e
[ -d $CFGDIR ] || exit 0

case "$1" in
  start|2|3|4)
    kver=`cat /proc/version | cut -d ' ' -f 3`
    /sbin/insmod -o cipcb0 /lib/modules/$kver/misc/cipcb.o
    for cfg in $CFGDIR
    do
      [ ! -f "$cfg" ] && continue
      /usr/sbin/ciped-cb -o $cfg
    done 
    echo "Done."
  ;;
  stop|0|1|6)
    killall ciped-cb
    sleep 3
    /sbin/rmmod cipcb0
    echo "Done."
  ;;
  restart)
  	$0 stop
	sleep 1
  	$0 start
	;;
  *)
	echo "Usage: $0 {start|stop|restart}" >&2
	exit 1
	;;
esac

exit 0

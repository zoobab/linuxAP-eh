#!/bin/sh
#
# br0
#
NWDS=0

[ -f $CFGD/netcfg ] && . $CFGD/netcfg
[ -f $CFGD/wlan0 ] && . $CFGD/wlan0
EXITCODE=1
case "$1" in
    start|3)
	echo "Starting BRIDGING services:"

# fixme: move eth0 stuff to wired
	ifconfig eth0 up
        ifconfig wlan0 up

        x=0
        while [ $x -lt $NWDS ]
        do
            iwpriv wlan0 wds_add 00:00:00:00:00:00	    
            ifconfig wlan0wds$x up
            x=`expr $x + 1`
        done

	WLANS=`ifconfig -a | cut -d ' ' -f 1 | grep wlan`
	ETHS=`ifconfig -a | cut -d ' ' -f 1 | grep eth`

	brctl addbr br0
	brctl sethello br0 2 # must keep this below fd
# maxage - length of time between configuration messages
# (hellos) before a bridge decides that a port is no longer
# reachable.  we'll set it to the time it takes an ap to
# reboot.  the longer it is, the less we are affected by
# unnecessary spanning tree recalculations
	brctl setmaxage br0 70 
	brctl setfd br0 4
	brctl setbridgeprio br0 100
	
# wlans must be first so the bridge takes the
# MAC address of the wlan
	for i in $WLANS $ETHS ; do
	    brctl addif br0 $i
	done
	
	ifconfig br0 up
# Need to give the bridge time to come up!
        sleep 8

	EXITCODE=0
	;;

    stop|0|6)
	echo "Shutting down BRIDGING services:"

        WLANS=`brctl show | sed -n 's/.*\(wlan.*\).*/\1/p'` 
	ETHS=`brctl show | sed -n 's/.*\(eth.*\).*/\1/p'`

	# teardown the bridge
	ifconfig br0 down

	for i in $WLANS $ETHS ; do
	    brctl delif br0 $i
	done

	brctl delbr br0

	EXITCODE=0
	;;

    status)
	echo "Checking BRIDGING service status:"
	EXITCODE=0
	;;
    restart|reload)
	echo "Restarting BRIDGING services:"
	$0 stop
	    sleep 1
	$0 start
	EXITCODE=$?
	;;

    *)
	echo "Usage: $0 {start|stop|status|restart|reload}"
	exit 1;
	;;
esac

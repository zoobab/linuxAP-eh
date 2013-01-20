#!/bin/sh
#
# iface.i
# start interface
#
iface=$1
dhcp=$2
address=$3
netmask=$4
broadcast=$5
status=1
if [ "$dhcp" = "enabled" ]
then
    udhcpc -n -i $iface
    status=$?
fi
if [ $status -eq 1 -o "$dhcp" != "enabled" ]
then
    if [ "$address" != "" ]
    then
        ifconfig $iface $address \
            netmask $netmask broadcast $broadcast
    fi
fi
sleep 2

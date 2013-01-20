#!/bin/sh
#
# iptables
#
[ -f $CFGD/netcfg ] && . $CFGD/netcfg

if [ -z "$masq_net" -o ! -f /usr/sbin/iptables ]
then
    exit 0
fi

clear_chains()
{
    iptables -F
    iptables -t nat -F
    iptables -X
    iptables -t nat -X
}

clear_chains

case "$1" in
2|3|4|5)
    iptables -t nat -A POSTROUTING -s $masq_net -d $masq_net -j ACCEPT
    iptables -t nat -A POSTROUTING -s $masq_net -d 0.0.0.0/0 -j MASQUERADE
    ;;
esac

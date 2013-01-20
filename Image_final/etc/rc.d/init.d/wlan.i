#! /bin/sh
#
# wlan.i
# Just turns on the card / sets up wep?
#
DRIVER=hostap_cs
essid=test
channel=1
nwds=0

#----------------------------------------------------------------------
# FIXUP_MAC
# Try and set the eth0 interface to the same mac only on the wl1100
#----------------------------------------------------------------------
fixup_mac()
{
    if [ ! -d /etc/rw ]
    then
        return
    fi
    hwaddr=`/sbin/ifconfig wlan0 | sed -n 's/.*HWaddr\(.*\)/\1/p'`
    ifconfig eth0 hw ether $hwaddr
}


#----------------------------------------------------------------------
# SET_PARMS
#----------------------------------------------------------------------
set_parms()
{
    iface=$1
    case "$runlevel" in
      2) iwconfig $iface mode Managed
        ;;
      3|4) iwconfig $iface mode Master
        iwconfig $iface channel $channel
        prism2_param $iface max_wds $nwds
        prism2_param $iface autom_ap_wds 1
        prism2_param $iface ap_bridge_packets 1
        ;;
    esac
    [ "$essid" ] && iwconfig $iface essid $essid
    [ "$security" ] && prism2_param $iface enh_sec $security
    [ "$w_txpower" ] && iwconfig $iface txpower $w_txpower
    [ "$w_rate" ] && iwconfig $iface rate $w_rate
    [ "$antsel_rx" ] && prism2_param $iface antsel_rx $antsel_rx
    [ "$antsel_tx" ] && prism2_param $iface antsel_tx $antsel_tx
    if [ "$wep" ]
    then
        iwconfig $iface key $wep
        prism2_param $iface host_encrypt 1
        prism2_param $iface host_decrypt 1
    fi
}

#----------------------------------------------------------------------
# MAIN
#----------------------------------------------------------------------
runlevel=$1

case "$runlevel" in
  2|3|4) 
    echo "Loading wireless modules"
    kver=`cat /proc/version | cut -d ' ' -f 3`
    if [ -f /lib/modules/$kver/pcmcia/pcmcia_core.o ]
    then
        insmod pcmcia_core
        insmod i82365 # ignore=1
        insmod ds
    fi
    insmod hostap
    insmod hostap_crypt_wep
    insmod $DRIVER ignore_cis_vcc=1
    cardmgr -o
    for ifcfg in $CFGD/wlan/*
    do
        . $ifcfg
        iface=`expr "$ifcfg" : ".*\/\\(wlan[0-9]\\)$"`
        if ifconfig $iface > /dev/null 2>&1
        then
            echo -n "Starting $iface: "
            set_parms $iface
            fixup_mac
        fi
        echo "Done."
    done
    ;;

  stop|0|6)
    echo -n "Stopping wireless interafces: "
    for ifcfg in $CFGD/wlan/*
    do
        . $ifcfg
        iface=`expr "$ifcfg" : ".*\/\\(wlan[0-9]\\)$"`
	ifconfig $iface down
	echo -n " $iface"
    done
# remove modules
    rmmod $DRIVER
    rmmod hostap
    rmmod hostap_crypt_wep
    rmmod hostap_crypt
    if [ -f /lib/modules/$kver/pcmcia/pcmcia_core.o ]
    then
        rmmod ds
        rmmod i82365
        rmmod pcmcia_core
    fi
    echo " Done."
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

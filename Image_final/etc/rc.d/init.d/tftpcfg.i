#!/bin/sh
#
# tftpcfg
#
# Download configuration info via tftp

# Keep The noise down on SRAM flash
if ifconfig wlan0 > /dev/null 2>&1
then
    :
else
    exit 0
fi

echo "1" > /proc/sys/net/ipv4/ip_forward

[ -f $CFGD/netcfg ] && . $CFGD/netcfg
[ -f /var/udhcpc.lease ] && . /var/udhcpc.lease

case "$1" in
    2|4)
        ;;
    *) exit 0 ;;
esac

hw=`/sbin/ifconfig wlan0 | \
    sed -n 's/.*HWaddr \(..\):\(..\):\(..\):\(..\):\(..\):\(..\)/\1\2\3\4\5\6/p'`

# In order dhcp: tftp serverid cfg: tftphost
[ "$tftp" ] && tftphost=$tftp
[ ! "$tftp" -a "$serverid" ] && tftphost=$serverid
if [ -z "$tftphost" ]
then
    exit 0
fi

# Download our configuration info
echo "Download $hw as etc.tar from $tftphost"
cd /tmp
tftp -g -l etc.tar -r $hw $tftphost
if [ -f etc.tar ]
then
    cd $CFGD
    tar xvf /tmp/etc.tar
    rm /tmp/etc.tar
fi
exit 0

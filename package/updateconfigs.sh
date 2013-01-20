#!/bin/sh
#
# Prepare system after upgrade
# Delete once done
#

CFGDIR="/etc/rw"
MODIFS='udhcpd openvpn cipe svr wlan'

udhcpd() {
    FILE=$CFGDIR/udhcpd.conf
    echo -n " udhcpd.conf"
    if [ ! -f $FILE ]
    then
	echo " -> not present"
    elif grep "^# udhcpd.conf" $FILE > /dev/null
    then
	if grep "^# udhcpd.conf  *enable" $FILE > /dev/null; then
	    STATS=yes
	else
	    STATS=no
	fi
	mv $FILE $FILE.old
	echo "enable               $STATS" > $FILE
	cat $FILE.old | grep -v "^# udhcpd.conf" >> $FILE
	rm $FILE.old
	echo " -> done"
    else
	echo " -> already ok"
    fi
}

openvpn() {
    echo -n " vpn-*.conf to openvpn dir"
    if [  -d $CFGDIR/openvpn ]
    then
	echo " -> already ok"
    elif [ ! -z "`ls $CFGDIR/vpn-*.conf 2> /dev/null`" ]
    then
	mkdir $CFGDIR/openvpn
	for i in `ls -1 $CFGDIR/vpn-*.conf | sed s/\\\/etc\\\/rw\\\/vpn-//| sed s/\.conf//`
	do
	    echo -n " ."
	    mv $CFGDIR/vpn-$i.conf $CFGDIR/openvpn/$i
	done
	echo " -> done"
    else
	echo " -> not present"
    fi
}

cipe() {
    echo -n " cipe"
    if [ -f $CFGDIR/cipe/host ]
    then
	mkdir $CFGDIR/cipe/peers
	mv $CFGDIR/cipe/host $CFGDIR/cipe/peers/
	echo " -> done"
    elif [ -d $CFGDIR/cipe/peers ]
    then
	echo " -> already ok"
    else
	echo " -> not present"
    fi
}

svr() {
    echo -n " netcfg"
    FILE=$CFGDIR/netcfg
    cp $FILE $FILE.bak
    cat $FILE.bak | sed -e s/^swaphost/swapsvr/ > $FILE
    cp $FILE $FILE.bak
    cat $FILE.bak | sed -e s/^timehost/timesvr/ > $FILE
    cp $FILE $FILE.bak
    cat $FILE.bak | sed -e s/^logaddr/logsvr/ > $FILE
    rm $FILE.bak
    echo " -> done"
}

wlan() {
    echo -n " wlan"
    if [ ! -d $CFGDIR/wlan ]
    then
	FILE=$CFGDIR/wlan/wlan0
	mkdir $CFGDIR/wlan
	mv $CFGDIR/wlan0 $FILE
	cp $FILE $FILE.bak
	cat $FILE.bak | sed -e s/^SSID/essid/ > $FILE
	cp $FILE $FILE.bak
	cat $FILE.bak | sed -e s/^CHANNEL/channel/ > $FILE
	cp $FILE $FILE.bak
	cat $FILE.bak | sed -e s/^NWDS/nwds/ > $FILE
	rm $FILE.bak
	echo "antsel_rx=0" >> $FILE
	echo "antsel_tx=0" >> $FILE
	echo "rate=auto" >> $FILE
	echo "txpower=auto" >> $FILE
	echo " -> done"
    else
	echo " -> already ok"
    fi
}

block() { # $1:file_in  $2:block_name  $3: file_out
    echo "   Extracting block $2: $1 -> $3"
    SLINE=`cat $1 | grep -n "#--- +$2" | sed -e s/:.*//`
    ELINE=`cat $1 | grep -n "#--- -$2" | sed -e s/:.*//`
    grep -A `expr $ELINE - 1 - $SLINE` "#--- +$2 ---" $1 | grep -v "#--- +$2 ---" > $3
}

pre_openvpn() {
    CFGFILE=$CFGDIR/vpn.conf
    if [ -f $CFGFILE ]
    then
	multiconf "$CFGFILE"
	if [ ! "$?" = "0" ]
	then
	    mkdir $CFGDIR/openvpn
	    for i in `cat $CFGFILE | grep "#--- +" | sed -e s/"#--- +"// | sed -e s/" ---"//`
	    do
		block $CFGFILE $i $CFGDIR/openvpn/$i
	    done
	    rm $CFGFILE
	fi
    fi
}

pre() {
    CFGFILE=$CFGDIR/netcfg
    mv $CFGFILE $CFGFILE.old
    block $CFGFILE.old "netcfg" $CFGFILE
    block $CFGFILE.old "wlan0"  $CFGDIR/wlan0
    if [ ! "grep \"#--- +kaodv\" $CFGFILE.old" = "" ]; then
	block $CFGFILE.old "kaodv"  $CFGDIR/kaodv
    fi
    rm $CFGFILE.old
    pre_openvpn
}

multiconf() {
    if [ "`grep \"#---\" $1`" = "" ]; then
	return 0
    else
	return 1
    fi
}


##########
## MAIN ##
##########

echo -n "Checking for old multi-conf mode"
multiconf "$CFGDIR/netcfg"
if [ ! "$?" = "0" ]
then
    echo -e "\n"
    pre
    echo -e "\nDone!"
else
    echo ": none"
fi

echo "Repairing config files"
for i in $MODIFS
do
    $i
done


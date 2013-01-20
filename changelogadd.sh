#!/bin/sh
logfile="ChangeLog.eh"
fecha=`head -n 1 $logfile` 
if [ $fecha = "`date '+%d-%m-20%y'`" ]
then
    echo $fecha > /tmp/log.eh
    echo "  * $*" >> /tmp/log.eh
    tail +2 $logfile >> /tmp/log.eh
    cat /tmp/log.eh > $logfile
    rm /tmp/log.eh
else
    echo `date '+%d-%m-20%y'` > /tmp/log.eh
    echo -e "  * $*\n" >> /tmp/log.eh
    cat $logfile >> /tmp/log.eh
    cat /tmp/log.eh > $logfile
    rm /tmp/log.eh
fi


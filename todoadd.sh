#!/bin/sh
logfile="TODO.eh"
fecha=`head -n 1 $logfile` 
if [ $fecha = "`date '+%d-%m-20%y'`" ]
then
    echo $fecha > /tmp/log.eh
    echo "  * $1" >> /tmp/log.eh
    tail +2 $logfile >> /tmp/log.eh
    cat /tmp/log.eh > $logfile
    rm /tmp/log.eh
else
    echo `date '+%d-%m-20%y'` > /tmp/log.eh
    echo "  * $1" >> /tmp/log.eh
    cat $logfile >> /tmp/log.eh
    cat /tmp/log.eh > $logfile
    rm /tmp/log.eh
fi


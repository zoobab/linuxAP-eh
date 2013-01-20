#!/bin/sh

# output file
LINKSFILE=links.tgz
# don't search links recursively on those dirs
# usually where bundle packages are compiled (to avoid a make clean)
# each entry is a grep pattern, that will be put together like:
#    ^<pattern1>$\|^<pattern2>$\|.... etc
# (so this variable can be understood easier)
# HEY: use just ONE space between each entry, all in a line and use no trailing
#      (nor starting) spaces!!! (yes, i'm a lazy checker :P)
IGNOREDIRS="./Image_final ./wireless_tools\..* ./linux-.* ./uClibc-.* ./busybox-.* ./pcmcia-cs-.* ./bridge-utils-.* ./hostap-.* ./iptables-.* ./kernel-aodv_.* ./openvpn-.* ./cramfs-.*"
# add those links that are on project's root (./), as it's not checked ('cause
# link search is recursive)
ADDLINKS="./RW.default"

# ideally don't touch from here to end (...)
echo "===> Remember to check my IGNOREDIRS or/and ADDLINKS variables if you"
echo "     have added new bundle packages"
expr="^.$\|^`echo "$IGNOREDIRS" | sed -e s/" "/"$\\\\\\\\\|^"/g`$"
list=""
for d in `find . -type d -maxdepth 1 | grep -v "$expr"`
do
    list="$list `find $d -type l`"
done
list="$list $ADDLINKS"

tar zcf $LINKSFILE $list

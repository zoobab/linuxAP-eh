source:		Keith Smith's linuxAP [1]
Version:	2003-09-01

Usage:
"make" linuxAP-eh gets configured and then you can compile it
"make menuconfig" to reconfigure it and after that make to compile
"make clean" to clean up the binaries 
"make distclean" it cleans all and even the binary and sources of the unpackaged
software (busybox, iptables, etc...)

When more than one version is listed, all except the last are always from the
original linuxAP, while the last can be (if not from original linuxAP itself) from
linuxAP-eh (focused on Eumitcom WL11000 SA-N platform).

The versions in menuconfig are:

Utility 		Available and tested versions
-------- 		--------------------------------
kernel 			2.4.20
hostap-driver		2002-10-12, 0.0.4(+), 0.1.2, 0.1.3(*)
hostap-utils            0.1.0, 0.1.2(*)
hostapd 		0.1.0
kernel-aodv 		v2.0, v2.1(*)

(*) default used versions
(+) this version has no txpower support (it makes distorsions on radio signal)


The default versions of unchoosable version software from menuconfig are:

Utility		        Available and tested versions
--------		--------------------------------
bridge-utils		0.9.6
busybox			0.60.5, 1.00-pre7(*)
cipe			1.5.4
cramfs			1.1
squashfs                1.2
iptables		1.2.7a
linux			2.4.20
openvpn			1.5-beta7
pcmcia-cs		3.2.3
uClibc			0.9.17, 0.9.20, 0.9.21(*)
wireless_tools		25

(*) default used versions

[1] http://linuxAP-eh.berlios.de


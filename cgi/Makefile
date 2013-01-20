# CONFIG_CIPE=y
# CROSS_COMPILE=/usr/i386-linux-uclibc/usr/bin/

CC= $(CROSS_COMPILE)gcc -Os

OFILES= setup.o utils.o network.o status.o udhcpd.o wlan.o telnetd.o httpd.o

ifeq ($(CONFIG_CIPE),y)
OFILES+= cipe.o
CFLAGS+=-DCONFIG_CIPE
endif

ifeq ($(CONFIG_OPENVPN),y)
OFILES+= openvpn.o
CFLAGS+=-DCONFIG_OPENVPN
endif

ifeq ($(CONFIG_KERNEL_AODV),y)
OFILES+= kaodv.o
CFLAGS+=-DCONFIG_KERNEL_AODV
endif



HFILES=	setup.h linked_functions.h

setup: $(OFILES)
	$(CC) $(OFILES) -o setup

$(OFILES): $(HFILES)

install: setup
	strip setup
	cp setup ../Image_final/html/cgi-bin

clean:
	@rm -f *.o setup

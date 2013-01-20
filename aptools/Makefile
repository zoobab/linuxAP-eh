#
# Makefile
#
# linuxAP specific Tools
#
CC=$(CROSS_COMPILE)gcc
INSTALL=install
STRIP=$(CROSS_COMPILE)strip

UPDATE_CFLAGS += -O2 -Wall -static -DDEBUG

all: update image_rdev chr

update:
	$(CC) $(UPDATE_CFLAGS) update.c -o update

clean:
	rm -f update image_rdev chr *.o

distclean:
	rm -f update image_rdev chr *.o

install:
	$(INSTALL) -d $(IMAGE_DIR)/sbin
	$(INSTALL) update $(IMAGE_DIR)/sbin
	$(STRIP) $(STRIPFLAGS) $(IMAGE_DIR)/sbin/update

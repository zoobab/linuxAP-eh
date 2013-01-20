#----------------------------------------------------------------------
#
# Makefile for LinuxAP Project
#
# Original Source: Keith Edwin Smith (c)2003
#	    Date: 2003/01/08
#
# The *very* first thing is to build uClibc, then use
# it to build the rest of the stuff.
# Buuuutt . . . './linux' must be in place and configured first
# This tango && extracts are not up to speed as of yet.
# Busybox is heavily patched, and build dependent.
#----------------------------------------------------------------------

ifeq (.config,$(wildcard .config))
include .config
endif
include ./Makefile.defs

# For Pathing with no setting
AP_BUILD	:= .

ifeq ($(CONFIG_UCLIBC),y)
ifeq ($(CONFIG_WL11000),y)
PRE_INSTALL=kernel-config-sram uClibc-install
else
PRE_INSTALL=kernel-config uClibc-install
endif
else
PRE_INSTALL=
endif

#----------------------------------------------------------------------
# The primary targets
#----------------------------------------------------------------------

#----------------------------------------------------------------------
# SOEKRIS
#----------------------------------------------------------------------
ifeq ($(CONFIG_SOEKRIS),y)
soekris: FORCE
	@if [ -f wl11000-config ]; then \
		 make distclean; \
	fi
	@echo -e "Building soekris images."
	@make AP_BUILD=soekris ramdisk
	@echo -e "Done."
	touch soekris-config

cflash:
#	./scripts/cf_setup soekris

endif


#----------------------------------------------------------------------
# ITX
#----------------------------------------------------------------------
ifeq ($(CONFIG_ITX),y)
itx: FORCE
	@if [ -f wl11000-config ]; then \
		 make distclean; \
	fi
	@echo -e "Building itx images."
	@make AP_BUILD=itx KERNEL_VERSION=$(KERNEL_VERSION) ramdisk
	@echo -e "Done."
	touch soekris-config

cflash:
	./scripts/cf_setup itx

endif


#----------------------------------------------------------------------
# RAMDISK
#----------------------------------------------------------------------
ifeq ($(CONFIG_RAMDISK),y)
ramdisk: syslinux-config $(PRE_INSTALL) kernel image
	@echo $(DATE_TIME) \
		> $(IMAGE_DIR)/etc/linuxAP-version
ifeq ($(CONFIG_SYSVINIT),y)
	mv $(IMAGE_DIR)/etc/itab-sysv $(IMAGE_DIR)/etc/inittab
	rm -f $(IMAGE_DIR)/etc/itab-bb
else
	mv $(IMAGE_DIR)/etc/itab-bb $(IMAGE_DIR)/etc/inittab
	rm -f $(IMAGE_DIR)/etc/itab-sysv
endif
	@echo -e "\n Building Filesystem Image. . ."
	@rm -f $(RAMFS).gz ramdisk
	@dd if=/dev/zero of=$(RAMFS) bs=1024 count=$(RAMDISK_SIZE) \
		> /dev/null 2>&1
	@yes | mkfs.minix $(RAMFS) > /dev/null 2>&1
	@mount -o loop $(RAMFS) /mnt/image
	@cd $(IMAGE_DIR) && tar cf - . | ( cd /mnt/image ; tar xf - )
ifeq ($(CONFIG_GLIBC),y)
	@ldconfig -r /mnt/image
endif
	@umount /mnt/image
	@gzip -9 $(RAMFS)
	@mv $(RAMFS).gz ramdisk
	@echo -e ""
endif


#----------------------------------------------------------------------
# WL11000
#----------------------------------------------------------------------
ifeq ($(CONFIG_WL11000),y)
wl11000: FORCE
	if [ -f soekris-config ]; then \
		 make distclean; \
	fi
	make AP_BUILD=wl11000 sram
	touch wl11000-config

sram: $(PRE_INSTALL) kernel-sram flash
	@rm -rf $(IMAGE_DIR)/etc/conf
	@mkdir -p $(IMAGE_DIR)/etc/conf
	@echo "6" > $(IMAGE_DIR)/etc/conf/runlevel
	@cp flash $(IMAGE_DIR)/flash
	@cp flash.md5  $(IMAGE_DIR)/flash.md5	
	@echo "sram build"
	@$(MKNOD) $(IMAGE_DIR)/dev/mtd1 c 90 2
	@./aptools/image_rdev ./kernel-sram 31 1
	./scripts/build_flash.pl 2097152 sram # 2 * 1024 * 1024
	@md5sum sram > sram.md5
	@echo -e "\nSRAM package:"
	@mv sram* package/
	@(cd package; tar -cvzf ../images/linuxAP-eh-$(DATE)-$(ELAN_SPEED)-SRAM.tar.gz *)
	@mv package/sram*  .
	@echo -e "\nFLASH package:"
	@mv flash* package/
	@(cd package; tar -cvzf ../images/linuxAP-eh-$(DATE)-$(ELAN_SPEED)-FLASH.tar.gz *)
	@mv package/flash* .

flash: kernel image squashfs-build alios-build
	@echo $(DATE_TIME) \
		> $(IMAGE_DIR)/etc/linuxAP-version
	@echo "3" > RW.default/runlevel
	@./aptools/image_rdev ./kernel 31 0
	@touch pcmcia-cs-config
	@touch pcmcia-cs-build
	@./aptools/image_rdev ./kernel-sram 31 0
	@./scripts/build_flash.pl 1048576 flash # 1024 * 1024
	@md5sum flash > flash.md5

endif


# Fall thru to here if no configuration
menuconfig:
	make -C conf/lxdialog
	conf/Menuconfig

config: menuconfig

FORCE:

#----------------------------------------------------------------------
# The meat and potatos
#----------------------------------------------------------------------

# These are required for all builds
include Mk/kernel.mk
include Mk/busybox.mk
include Mk/pcmcia_cs.mk
include Mk/wireless_tools.mk
include Mk/cgi.mk

# This is every other package
ifeq ($(MAKECMDGOALS),distclean)
include Mk/alios.mk
include Mk/bridge-utils.mk
include Mk/cipe.mk
include Mk/ckermit.mk
include Mk/squashfs.mk
include Mk/hostap-driver.mk
include Mk/hostap-utils.mk
include Mk/hostapd.mk
include Mk/iproute2.mk
include Mk/iptables.mk
include Mk/nbd.mk
include Mk/psmisc.mk
include Mk/syslinux.mk
include Mk/sysvinit.mk
include Mk/aptools.mk
include Mk/uClibc.mk
include Mk/umsdos_progs.mk
include Mk/kernel-aodv.mk
include Mk/openvpn.mk
include Mk/tinylogin.mk
include Mk/udhcp.mk
include Mk/vtun.mk
else

# Selective if not distclean
ifeq ($(CONFIG_TINY_LOGIN),y)
include Mk/tinylogin.mk
endif
ifeq ($(CONFIG_ALIOS),y)
include Mk/alios.mk
endif
ifeq ($(CONFIG_APTOOLS),y)
include Mk/aptools.mk
endif
ifeq ($(CONFIG_SQUASHFS),y)
include Mk/squashfs.mk
endif
ifeq ($(CONFIG_BUTILS),y)
include Mk/bridge-utils.mk
endif
ifeq ($(CONFIG_CIPE),y)
include Mk/cipe.mk
endif
ifeq ($(CONFIG_CKERMIT),y)
include Mk/ckermit.mk
endif
ifeq ($(CONFIG_NBD),y)
include Mk/nbd.mk
endif
ifeq ($(CONFIG_HOSTAP_DRIVER),y)
include Mk/hostap-driver.mk
endif
ifeq ($(CONFIG_HOSTAP_UTILS),y)
include Mk/hostap-utils.mk
endif
ifeq ($(CONFIG_HOSTAPD),y)
include Mk/hostapd.mk
endif
ifeq ($(CONFIG_IPTABLES),y)
include Mk/iptables.mk
endif
ifeq ($(CONFIG_KERNEL_AODV),y)
include Mk/kernel-aodv.mk
endif
ifeq ($(CONFIG_VTUN),y)
include Mk/vtun.mk
endif
ifeq ($(CONFIG_OPENVPN),y)
include Mk/openvpn.mk
endif
ifeq ($(CONFIG_PSMISC),y)
include Mk/psmisc.mk
endif
ifeq ($(CONFIG_SYSLINUX),y)
include Mk/syslinux.mk
endif
ifeq ($(CONFIG_SYSVINIT),y)
include Mk/sysvinit.mk
endif
ifeq ($(CONFIG_TRAFFIC),y)
include Mk/iproute2.mk
endif
ifeq ($(CONFIG_UCLIBC),y)
include Mk/uClibc.mk
endif
ifeq ($(CONFIG_UDHCP),y)
include Mk/udhcp.mk
endif
ifeq ($(CONFIG_UMSDOS),y)
include Mk/umsdos_progs.mk
endif

endif

image:	Image_dir \
	kernel-install \
	$(SUBDIR_INSTALL) \
	configure_links \
	copy_libc
	@echo -e "\nCleaning CVS directories from Image_final"
	@rm -Rf `find $(IMAGE_DIR) -type d -name CVS`
	@echo ""
	@echo "Stripping binaries/modules (probably redundant)"
	#$(STRIP) --strip-debug `find $(IMAGE_DIR) -type f -exec file {} \; | grep "ELF 32-bit" | cut -f 1 -d :`
	@$(STRIP) --strip-debug `find $(IMAGE_DIR) -type f -exec file {} \; | grep "ELF 32-bit" | cut -f 1 -d :`
	@echo ""
	@echo "Removing dirs/files:"
	@rm -Rfv $(REMOVE_FINAL)

Image_dir:
	@echo -e "\nRebuilding Image_final"
	@rm -rf $(IMAGE_DIR)
	@mkdir -p $(IMAGE_DIR)/
	@( cd Image_static ; tar cf - . | ( cd $(IMAGE_DIR) ; tar xf - ))
	@( cd $(AP_BUILD)/Image_static ; tar cf - . | \
		( cd $(IMAGE_DIR); tar xf - ) )
	@scripts/util_dev $(IMAGE_DIR)/dev/ `cat scripts/util_dev.$(AP_BUILD)`
ifneq ($(CONFIG_HTTPD),y)
	@rm -rf $(IMAGE_DIR)/html
	@rm -f $(IMAGE_DIR)/etc/rc.d/init.d/httpd
	@rm -f `find $(IMAGE_DIR)/etc/rc.d -type l -name "*\.httpd"`
endif

configure_links:
	@echo -e "\nConfigure image symlinks"
ifeq ($(CONFIG_WL11000),y)
	@ln -s ../proc/mounts $(IMAGE_DIR)/etc/mtab
	@ln -s /var/tmp $(IMAGE_DIR)/tmp
	@ln -s /var/etc/rw  $(IMAGE_DIR)/etc/rw
	@ln -s /var/etc/rw/resolv.conf  $(IMAGE_DIR)/etc/resolv.conf
ifeq ($(CONFIG_CIPE),y)
endif
	@ln -s /var/etc/rw/telnetd.hosts $(IMAGE_DIR)/etc/telnetd.hosts
	@ln -s /var/syslogd.socket $(IMAGE_DIR)/dev/log
endif
ifeq ($(CONFIG_SOEKRIS),y)
	@ln -s ../proc/mounts $(IMAGE_DIR)/etc/mtab
	mkdir $(IMAGE_DIR)/tmp
endif

copy_libc:
ifeq ($(CONFIG_UCLIBC),y)
	# install uclibc
	@mkdir -p $(IMAGE_DIR)/usr/i386-linux-uclibc-$(UCLIBC_VERSION)/lib
	@mkdir -p $(IMAGE_DIR)/lib
	@for lib in $(LIBS) ; do \
		cp -a /usr/i386-linux-uclibc/lib/$$lib \
			$(IMAGE_DIR)/usr/i386-linux-uclibc-$(UCLIBC_VERSION)/lib ; \
	done
	@ln -s /usr/i386-linux-uclibc-$(UCLIBC_VERSION)/lib/ld-uClibc.so.0 \
		$(IMAGE_DIR)/lib/ld-uClibc.so.0
	@ln -s /usr/i386-linux-uclibc-$(UCLIBC_VERSION) \
		$(IMAGE_DIR)/usr/i386-linux-uclibc
else
	# install glibc
	mkdir -p $(IMAGE_DIR)/lib $(IMAGE_DIR)/usr/lib
	cp -a /lib/ld-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libBrokenLocale-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libanl-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libc-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libcrypt-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libdb-3.1.so $(IMAGE_DIR)/lib
	cp -a /lib/libdb1.so.2.1.3 $(IMAGE_DIR)/lib
	cp -a /lib/libdb2.so.3 $(IMAGE_DIR)/lib
	cp -a /lib/libdl-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libm-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libmemusage.so $(IMAGE_DIR)/lib
	cp -a /lib/libncurses.so.5.2 $(IMAGE_DIR)/lib
	cp -a /lib/libnsl-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libnss_compat-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libnss_db*.so $(IMAGE_DIR)/lib
	cp -a /lib/libnss_dns-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libnss_files-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libnss_hesiod-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libnss_nis-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libnss_nisplus-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libpcprofile.so $(IMAGE_DIR)/lib
	cp -a /lib/libpthread*.so $(IMAGE_DIR)/lib
	cp -a /lib/libresolv-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/librt-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libthread_db*.so $(IMAGE_DIR)/lib
	cp -a /lib/libutil-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib
	cp -a /lib/libgpm.so.1.18.0 $(IMAGE_DIR)/lib
	-$(STRIP) --strip-debug $(IMAGE_DIR)/lib/*
#	-$(STRIP) --strip-unneeded $(IMAGE_DIR)/lib/*
	ln -s libc-$(GLIBC_VERSION).so $(IMAGE_DIR)/lib/libc.so.6
	touch $(IMAGE_DIR)/etc/ld.so.conf
endif

#----------------------------------------------------------------------
# Clean & distribute
#----------------------------------------------------------------------
linuxAP-clean:
	@echo -e "\nRemove Images and Marker Files ..."
	@$(RM) flash* sram*
	@$(RM) kernel linux/.config
	@$(RM) ramfs.img ramdisk
	@$(RM) image
	@$(RM) RW.tar.gz
	@$(RM) soekris-config wl11000-config
	@rm -rf $(IMAGE_DIR)
	@$(MAKE) -C conf/lxdialog clean > /dev/null 2>&1

clean: $(SUBDIR_CLEAN) linuxAP-clean

distclean: $(SUBDIR_DISTCLEAN) linuxAP-clean
	@rm -f .config dirs.done links.done RW.default

tar: distclean
	@echo -e "\nBuilding Distribution File ..."
	rm -f ../linuxAP-eh-$(DATE).tar.bz2
	cd .. && tar -c -j -v -f linuxAP-eh-$(DATE).tar.bz2 \
		--exclude=./linuxAP-eh/tarfiles \
		--exclude=./linuxAP-eh/ariel \
		./linuxAP-eh

#post: tar                
#       [ -d /www/linuxAP.ksmith.com/htdocs/archive/linuxAP-tar ] && \
#       cp ../linuxAP-$DATE.tar.bz2 \
#               /www/linuxAP.ksmith.com/htdocs/archive/linuxAP-tar && \
#        ( cd /www/linuxAP.ksmith.com/htdocs/archive ; \
#          rm -r linuxAP; \
#          tar xvfj linuxAP-tar/linuxAP-`date +%Y-%m-%d`.tar.bz2 )


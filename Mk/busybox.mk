#----------------------------------------------------------------------
# busybox
#----------------------------------------------------------------------
SUBDIR_CONFIG   += busybox-config
SUBDIR_BUILD    += busybox-build
SUBDIR_INSTALL  += busybox-install
SUBDIR_CLEAN    += busybox-clean
SUBDIR_DISTCLEAN+= busybox-distclean

busybox-config:
	@echo -e "\nExtract and Configure busybox version $(BUSYBOX_VERSION)."
	@scripts/util_config busybox $(BUSYBOX_VERSION) $(ARCHIVE_DIR) \
		> /tmp/busybox-config
ifeq ($(BUSYBOX_VERSION),"0.60.5")
ifneq ($(CONFIG_SYSVINIT),y)
	@[ -f $(AP_BUILD)/patches/busybox/Config.h-$(BUSYBOX_VERSION) ] && \
		cp $(AP_BUILD)/patches/busybox/Config.h-$(BUSYBOX_VERSION) \
		   busybox/Config.h
else
	@[ -f $(AP_BUILD)/patches/busybox/noinit-$(BUSYBOX_VERSION) ] && \
		cp $(AP_BUILD)/patches/busybox/noinit-$(BUSYBOX_VERSION) \
		   busybox/Config.h
endif
endif
ifneq ($(CONFIG_HTTPD),y)
	@cd busybox && patch -p1 < \
		../$(AP_BUILD)/patches/busybox/$(BUSYBOX_VERSION)-nohttpd \
		>> /tmp/busybox-config
endif
	@$(MAKE) -C busybox oldconfig \
		KERNEL_DIR=$(KERNEL_DIR) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC=$(CC) \
		>> /tmp/busybox-config 2>&1
	@mv /tmp/busybox-config .

busybox-build: busybox-config
	@echo -e "\nBuilding busybox version $(BUSYBOX_VERSION)."
	@$(MAKE) -C busybox \
		KERNEL_DIR=$(KERNEL_DIR) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC=$(CC) > /tmp/busybox-build 2>&1
	@mv /tmp/busybox-build .

busybox-install: busybox-build
	@echo -e "\nInstalling busybox version $(BUSYBOX_VERSION)."
	@$(MAKE) -C busybox \
		INSTALL=install \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		PREFIX=$(IMAGE_DIR) \
		STRIP=$(STRIP) \
		STRIPFLAGS=$(STRIPFLAGS)\ --strip-all\
		install > /tmp/busybox-install 2>&1
ifeq ($(CONFIG_WL11000),y)
	@ln -s /var/etc/rw/passwd $(IMAGE_DIR)/etc/passwd
	@ln -s /var/etc/rw/group $(IMAGE_DIR)/etc/group
	@ln -s /var/etc/rw/nologin $(IMAGE_DIR)/etc/nologin
	@ln -s /var/etc/rw/motd $(IMAGE_DIR)/etc/motd
	@ln -s /var/etc/rw/udhcpd.conf $(IMAGE_DIR)/etc/udhcpd.conf
	@ln -s /var/etc/rw/udhcpd.leases $(IMAGE_DIR)/etc/udhcpd.leases
	@ln -s /var/etc/rw/httpd.conf $(IMAGE_DIR)/etc/httpd.conf
endif
	@mkdir -p -m 0755 $(IMAGE_DIR)/usr/share/udhcpc/
	#@install busybox/examples/udhcp/simple.script $(IMAGE_DIR)/usr/share/udhcpc/default.script
	@scripts/util_setup install busybox $(BUSYBOX_VERSION) \
		>> /tmp/busybox-install 2>&1

busybox-clean:
	@echo -e "\nCleaning busybox version $(BUSYBOX_VERSION)."
	@rm -f busybox-build
	@rm -f busybox-config
	@-$(MAKE) -C busybox clean > /dev/null 2>&1
	@scripts/util_setup clean busybox $(BUSYBOX_VERSION)

busybox-distclean:
	@echo -e "\nPurging busybox version $(BUSYBOX_VERSION)."
	@rm -f busybox-build
	@rm -f busybox-config
	@rm -rf busybox-$(BUSYBOX_VERSION) busybox
	@scripts/util_setup clean busybox $(BUSYBOX_VERSION)

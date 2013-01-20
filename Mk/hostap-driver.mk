#----------------------------------------------------------------------
# hostap / Prism 2/2.5/3 driver
#----------------------------------------------------------------------
SUBDIR_CONFIG   += hostap-driver-config
SUBDIR_BUILD    += hostap-driver-build
SUBDIR_INSTALL  += hostap-driver-install
SUBDIR_CLEAN    += hostap-driver-clean
SUBDIR_DISTCLEAN+= hostap-driver-distclean

ifeq ($(AP_BUILD),wl11000)
PCMCIA_PATH=
else
PCMCIA_PATH=$(TOPDIR)/pcmcia-cs
endif

hostap-driver-config:
	@echo -e "\nExtract and Configure hostap-driver version $(HOSTAP_DRIVER_VERSION)."
	@scripts/util_config hostap-driver $(HOSTAP_DRIVER_VERSION) $(ARCHIVE_DIR)\
		> /tmp/hostap-driver-config
	@mv /tmp/hostap-driver-config .

hostap-driver-build: hostap-driver-config
	@echo -e "\nBuild hostap-driver version $(HOSTAP_DRIVER_VERSION)."
	@$(MAKE) -C hostap-driver pccard \
		KERNEL_PATH=$(KERNEL_DIR) \
		CC=$(CROSS_COMPILE)gcc \
		PCMCIA_PATH=$(PCMCIA_PATH) \
		DESTDIR=$(IMAGE_DIR) \
		EXTRA_CFLAGS="-DPRISM2_NO_DEBUG -DPRISM2_NO_PROCFS_DEBUG" \
		> /tmp/hostap-driver-build 2>&1
	@mv /tmp/hostap-driver-build .

hostap-driver-install: hostap-driver-build
	@echo -e "\nInstall hostap-driver version $(HOSTAP_DRIVER_VERSION)."
	@$(MAKE) -C hostap-driver \
		KERNEL_PATH=$(KERNEL_DIR) \
		CC=$(CROSS_COMPILE)gcc \
		PCMCIA_PATH=$(PCMCIA_PATH) \
		DESTDIR=$(IMAGE_DIR) \
		install_pccard \
		install_hostap \
		install_crypt \
		> /tmp/hostap-driver-install 2>&1
	#@$(STRIP) --strip-debug $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/net/hostap*.o
	@$(STRIP) --strip-debug $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/hostap_cs.o

hostap-driver-clean:
	@rm -f hostap-driver-config
	@rm -f hostap-driver-build
	@-$(MAKE) -C hostap-driver clean >/dev/null 2>&1

hostap-driver-distclean:
	@echo -e "\nPurging hostap-driver version $(HOSTAP_DRIVER_VERSION)"
	@rm -f hostap-driver-config
	@rm -f hostap-driver-build
	@rm -rf hostap-driver-$(HOSTAP_DRIVER_VERSION) hostap-driver

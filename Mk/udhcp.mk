#----------------------------------------------------------------------
# udhcp
#----------------------------------------------------------------------
SUBDIR_CONFIG   += udhcp-config
SUBDIR_BUILD    += udhcp-build
SUBDIR_INSTALL  += udhcp-install
SUBDIR_CLEAN    += udhcp-clean
SUBDIR_DISTCLEAN+= udhcp-distclean

udhcp-config:
	@echo -e "\nExtract and Configure udhcp version $(UDHCP_VERSION)."
	@scripts/util_config udhcp $(UDHCP_VERSION) $(ARCHIVE_DIR)\
		> /tmp/udhcp-config
	@mv /tmp/udhcp-config .

udhcp-build: udhcp-config
	@echo -e "\nBuilding udhcp version $(UDHCP_VERSION)."
	@$(MAKE) -C udhcp CROSS_COMPILE=$(CROSS_COMPILE) \
		> /tmp/udhcp-build > /tmp/udhcp-build 2>&1
	@mv /tmp/udhcp-build .

# Install the correct scripts
udhcp-install: udhcp-build
	@echo -e "\nInstalling udhcp version $(UDHCP_VERSION)."
	@$(MAKE) IMAGE_DIR=$(IMAGE_DIR) CROSS_COMPILE=$(CROSS_COMPILE) \
		-C udhcp install > /tmp/udhcp-install 2>&1
	@rm $(IMAGE_DIR)/usr/share/udhcpc/*
	#@cp -a ./udhcp/samples/simple.script \
	#	$(IMAGE_DIR)/usr/share/udhcpc/default.script
	#@chmod 0775 $(IMAGE_DIR)/usr/share/udhcpc/default.script
	@scripts/util_setup install udhcp $(UDHCP_VERSION) \
		>> /tmp/udhcp-install 2>&1
ifeq ($(AP_BUILD),wl11000)
	rm -rf $(IMAGE_DIR)/usr/bin/dumpleases
	@ln -s /var/etc/rw/udhcpd.conf $(IMAGE_DIR)/etc/udhcpd.conf
	@ln -s /var/etc/rw/udhcpd.leases $(IMAGE_DIR)/etc/udhcpd.leases
endif

udhcp-clean:
	@echo -e "\nCleaning udhcp version $(UDHCP_VERSION)."
	@rm -f udhcp-build
	@rm -f udhcp-config
	@-$(MAKE) -C udhcp clean > /dev/null 2>&1
	@scripts/util_setup clean udhcp $(UDHCP_VERSION)

udhcp-distclean:
	@echo -e "\nPurging udhcp version $(UDHCP_VERSION)."
	@rm -f udhcp-build
	@rm -f udhcp-config
	@rm -rf udhcp-$(UDHCP_VERSION) udhcp
	@scripts/util_setup clean udhcp $(UDHCP_VERSION)

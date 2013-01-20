#----------------------------------------------------------------------
# hostapd / Prism 2/2.5/3 driver
#----------------------------------------------------------------------
SUBDIR_CONFIG   += hostapd-config
SUBDIR_BUILD    += hostapd-build
SUBDIR_INSTALL  += hostapd-install
SUBDIR_CLEAN    += hostapd-clean
SUBDIR_DISTCLEAN+= hostapd-distclean
hostapd-config:
	@echo -e "\nExtract and Configure hostapd version $(HOSTAPD_VERSION)."
	@scripts/util_config hostapd $(HOSTAPD_VERSION) $(ARCHIVE_DIR)\
		> /tmp/hostapd-config
	@mv /tmp/hostapd-config .

hostapd-build: hostapd-config
	@echo -e "\nBuild hostapd version $(HOSTAPD_VERSION)."
	@$(MAKE) -C hostapd hostapd \
		CC=$(CROSS_COMPILE)gcc \
		> /tmp/hostapd-build 2>&1
	@mv /tmp/hostapd-build .

hostapd-install: hostapd-build
	@echo -e "\nInstall hostapd version $(HOSTAPD_VERSION)."
	@cp hostapd/hostapd $(IMAGE_DIR)/sbin
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/sbin/hostapd
	@scripts/util_setup install hostapd $(HOSTAPD_VERSION) >> /tmp/hostapd-install 2>&1
	@ln -s /var/etc/rw/hostapd.conf  $(IMAGE_DIR)/etc/hostapd.conf
	@ln -s /var/etc/rw/hostapd.accept  $(IMAGE_DIR)/etc/hostapd.accept
	@ln -s /var/etc/rw/hostapd.deny  $(IMAGE_DIR)/etc/hostapd.deny


hostapd-clean:
	@rm -f hostapd-config
	@rm -f hostapd-build

hostapd-distclean:
	@echo -e "\nPurging hostapd version $(HOSTAPD_VERSION)"
	@rm -f hostapd-config
	@rm -f hostapd-build
	@rm -rf hostapd-$(HOSTAPD_VERSION) hostapd

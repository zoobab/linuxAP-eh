#----------------------------------------------------------------------
# wireless_tools
#----------------------------------------------------------------------
SUBDIR_CONFIG   += wireless_tools-config
SUBDIR_BUILD    += wireless_tools-build
SUBDIR_INSTALL  += wireless_tools-install
SUBDIR_CLEAN    += wireless_tools-clean
SUBDIR_DISTCLEAN+= wireless_tools-distclean

wireless_tools-config:
	@echo -e "\nExtract and Configure wireless_tools version $(WTOOLS_VERSION)."
	@scripts/util_config wireless_tools $(WTOOLS_VERSION) $(ARCHIVE_DIR)\
		> /tmp/wireless_tools-config
	@mv /tmp/wireless_tools-config .

wireless_tools-build: wireless_tools-config
	@echo -e "\nBuilding wireless_tools version $(WTOOLS_VERSION)."
	@$(MAKE) -C wireless_tools CROSS_COMPILE=$(CROSS_COMPILE) \
		> /tmp/wireless_tools-build > /tmp/wireless_tools-build 2>&1
	@mv /tmp/wireless_tools-build .

wireless_tools-install: wireless_tools-build
	@echo -e "\nInstalling wireless_tools version $(WTOOLS_VERSION)."
	@$(MAKE) -C wireless_tools install CROSS_COMPILE=$(CROSS_COMPILE) \
		> /tmp/wireless_tools-install 2>&1
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/usr/sbin/iw*

wireless_tools-clean:
	@echo -e "\nCleaning wireless_tools version $(WTOOLS_VERSION)."
	@rm -f wireless_tools-build
	@rm -f wireless_tools-config
	@-$(MAKE) -C wireless_tools realclean > /dev/null 2>&1

wireless_tools-distclean:
	@echo -e "\nPurging wireless_tools version $(WTOOLS_VERSION)."
	@rm -f wireless_tools-build
	@rm -f wireless_tools-config
	@rm -rf wireless_tools.$(WTOOLS_VERSION) wireless_tools

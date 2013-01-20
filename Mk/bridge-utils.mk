#----------------------------------------------------------------------
# bridge-utils
#----------------------------------------------------------------------
SUBDIR_CONFIG   += bridge-utils-config
SUBDIR_BUILD    += bridge-utils-build
SUBDIR_INSTALL  += bridge-utils-install
SUBDIR_CLEAN    += bridge-utils-clean
SUBDIR_DISTCLEAN+= bridge-utils-distclean

bridge-utils-config:
	@echo -e "\nExtract and Configure bridge-utils version $(BUTILS_VERSION)."
	@scripts/util_config bridge-utils $(BUTILS_VERSION) $(ARCHIVE_DIR)\
		> /tmp/bridge-utils-config
	@cd bridge-utils && ./configure \
		--with-linux=$(KERNEL_DIR) \
                --prefix=$(IMAGE_DIR)/usr \
		>> /tmp/bridge-utils-config
	@mv /tmp/bridge-utils-config .

bridge-utils-build: bridge-utils-config
	@echo -e "\nBuilding bridge-utils version $(BUTILS_VERSION)."
	@$(MAKE) CC=$(CC) -C bridge-utils > /tmp/bridge-utils-build > /tmp/bridge-utils-build 2>&1
	@mv /tmp/bridge-utils-build .

bridge-utils-install: bridge-utils-build
	@echo -e "\nInstalling bridge-utils version $(BUTILS_VERSION)."
	@$(MAKE) CC=$(CC) -C bridge-utils install > /tmp/bridge-utils-install 2>&1
	@rm -r $(IMAGE_DIR)/usr/include
	@rm -r $(IMAGE_DIR)/usr/man
	@rm $(IMAGE_DIR)/usr/lib/libbridge.a
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/usr/sbin/brctl
	#commented @$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/usr/sbin/brctld
	@rm -f $(IMAGE_DIR)/usr/sbin/brctld

bridge-utils-clean:
	@echo -e "\nCleaning bridge-utils version $(BUTILS_VERSION)."
	@rm -f bridge-utils-build
	@rm -f bridge-utils-config
	@-$(MAKE) -C bridge-utils clean > /dev/null 2>&1

bridge-utils-distclean:
	@echo -e "\nPurging bridge-utils version $(BUTILS_VERSION)."
	@rm -f bridge-utils-build
	@rm -f bridge-utils-config
	@rm -rf bridge-utils-$(BUTILS_VERSION) bridge-utils

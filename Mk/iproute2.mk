#----------------------------------------------------------------------
# iproute2
#----------------------------------------------------------------------
SUBDIR_CONFIG   += iproute2-config
SUBDIR_BUILD    += iproute2-build
SUBDIR_INSTALL  += iproute2-install
SUBDIR_CLEAN    += iproute2-clean
SUBDIR_DISTCLEAN+= iproute2-distclean

IPROUTE2_BINS = iproute2/ip/ip \
		iproute2/tc/tc
 
iproute2-config:
	@echo -e "\nExtract and Configure iproute2 version $(IPROUTE2_VERSION)."
	@scripts/util_config iproute2 $(IPROUTE2_VERSION) $(ARCHIVE_DIR)\
		> /tmp/iproute2-config
	@mv /tmp/iproute2-config .

iproute2-build: iproute2-config
	@echo -e "\nBuilding iproute2 version $(IPROUTE2_VERSION)."
	@$(MAKE) CC=$(CC) KERNEL_DIR=$(KERNEL_DIR) -C iproute2 \
		> /tmp/iproute2-build > /tmp/iproute2-build 2>&1
	@mv /tmp/iproute2-build .

iproute2-install: iproute2-build
	@echo -e "\nInstalling iproute2 version $(IPROUTE2_VERSION)."
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IPROUTE2_BINS) > /tmp/iproute2-install 2>&1
	@cp -va $(IPROUTE2_BINS) $(IMAGE_DIR)/usr/sbin >> /tmp/iproute2-install 2>&1

iproute2-clean:
	@echo -e "\nCleaning iproute2 version $(IPROUTE2_VERSION)."
	@rm -f iproute2-build
	@rm -f iproute2-config
	@-$(MAKE) -C iproute2 clean > /dev/null 2>&1

iproute2-distclean:
	@echo -e "\nPurging iproute2 version $(IPROUTE2_VERSION)."
	@rm -f iproute2-build
	@rm -f iproute2-config
	@rm -rf iproute2-$(IPROUTE2_VERSION) iproute2

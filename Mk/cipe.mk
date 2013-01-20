#----------------------------------------------------------------------
# cipe
#----------------------------------------------------------------------
SUBDIR_CONFIG 	+= cipe-config
SUBDIR_BUILD	+= cipe-build
SUBDIR_INSTALL 	+= cipe-install
SUBDIR_CLEAN	+= cipe-clean
SUBDIR_DISTCLEAN+= cipe-distclean

cipe-config:
	@echo -e "\nExtract and Configure cipe version $(CIPE_VERSION)."
	@scripts/util_config cipe $(CIPE_VERSION) $(ARCHIVE_DIR) \
		> /tmp/cipe-config
	@mv /tmp/cipe-config .

cipe-build: cipe-config
	@echo -e "\nBuilding cipe version $(CIPE_VERSION)."
	@$(MAKE) -C cipe > /tmp/cipe-build > /tmp/cipe-build 2>&1
	@mv /tmp/cipe-build .

cipe-install: cipe-build
	@echo -e "\nInstalling cipe version $(CIPE_VERSION)."
	@$(MAKE) -C cipe install > /tmp/cipe-install 2>&1
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/usr/local/sbin/ciped-cb
	@scripts/util_setup install cipe $(CIPE_VERSION) >> /tmp/cipe-install 2>&1
	@ln -s /var/etc/rw/cipe  $(IMAGE_DIR)/etc/cipe

cipe-clean:
	@echo -e "\nCleaning cipe version $(CIPE_VERSION)."
	@rm -f cipe-build
	@rm -f cipe-config
	@-$(MAKE) -C cipe clean > /dev/null 2>&1
	@scripts/util_setup clean cipe $(CIPE_VERSION)

cipe-distclean:
	@echo -e "\nPurging cipe version $(CIPE_VERSION)."
	@rm -f cipe-build
	@rm -f cipe-config
	@rm -rf cipe-$(CIPE_VERSION) cipe
	@scripts/util_setup clean cipe $(CIPE_VERSION)

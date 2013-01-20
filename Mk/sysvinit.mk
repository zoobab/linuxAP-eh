#----------------------------------------------------------------------
# sysvinit
#----------------------------------------------------------------------
SUBDIR_CONFIG   += sysvinit-config
SUBDIR_BUILD    += sysvinit-build
SUBDIR_INSTALL  += sysvinit-install
SUBDIR_CLEAN    += sysvinit-clean
SUBDIR_DISTCLEAN+= sysvinit-distclean

sysvinit-config:
	@echo -e "\nExtract and Configure sysvinit version $(SYSVINIT_VERSION)."
	@scripts/util_config sysvinit $(SYSVINIT_VERSION) $(ARCHIVE_DIR)\
		> /tmp/sysvinit-config
	@mv /tmp/sysvinit-config .

sysvinit-build: sysvinit-config
	@echo -e "\nBuilding sysvinit version $(SYSVINIT_VERSION)."
	@$(MAKE) -C sysvinit/src CC=$(CROSS_COMPILE)gcc \
		> /tmp/sysvinit-build > /tmp/sysvinit-build 2>&1
	mv /tmp/sysvinit-build .

sysvinit-install: sysvinit-build
	@echo -e "\nInstalling sysvinit version $(SYSVINIT_VERSION)."
	@cp sysvinit/src/init $(IMAGE_DIR)/sbin
	@cp sysvinit/src/halt $(IMAGE_DIR)/sbin
	@cp sysvinit/src/runlevel $(IMAGE_DIR)/sbin
	@$(STRIP) $(STRIPFLAGS) $(IMAGE_DIR)/sbin/init
	@$(STRIP) $(STRIPFLAGS) $(IMAGE_DIR)/sbin/halt
	@$(STRIP) $(STRIPFLAGS) $(IMAGE_DIR)/sbin/runlevel
	@cd $(IMAGE_DIR)/dev && rm -f initctl && mknod -m 600 initctl p

sysvinit-clean:
	@echo -e "\nCleaning sysvinit version $(SYSVINIT_VERSION)."
	@rm -f sysvinit-build
	@rm -f sysvinit-config
	@-$(MAKE) -C sysvinit clean > /dev/null 2>&1

sysvinit-distclean:
	@echo -e "\nPurging sysvinit version $(SYSVINIT_VERSION)."
	@rm -f sysvinit-build
	@rm -f sysvinit-config
	@rm -rf sysvinit-$(SYSVINIT_VERSION) sysvinit

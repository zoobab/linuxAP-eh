#----------------------------------------------------------------------
# syslinux
#----------------------------------------------------------------------
SUBDIR_CONFIG   += syslinux-config
# SUBDIR_BUILD    += syslinux-build
# SUBDIR_INSTALL  += syslinux-install
# SUBDIR_CLEAN    += syslinux-clean
SUBDIR_DISTCLEAN+= syslinux-distclean

syslinux-config:
	@echo -e "\nExtract and Configure syslinux version $(SYSLINUX_VERSION)."
	@scripts/util_config syslinux $(SYSLINUX_VERSION) $(ARCHIVE_DIR)\
		> /tmp/syslinux-config
	@mv /tmp/syslinux-config .

syslinux-build: syslinux-config
	@echo -e "\nBuilding syslinux version $(SYSLINUX_VERSION)."
	@$(MAKE) -C syslinux CC=$(CROSS_COMPILE)gcc \
		> /tmp/syslinux-build > /tmp/syslinux-build 2>&1
	mv /tmp/syslinux-build .

syslinux-install: syslinux-build
	@echo -e "\nInstalling syslinux version $(SYSLINUX_VERSION)."

syslinux-clean:
	@echo -e "\nCleaning syslinux version $(SYSLINUX_VERSION)."
	@rm -f syslinux-build
	@rm -f syslinux-config
	@-$(MAKE) -C syslinux clean > /dev/null 2>&1

syslinux-distclean:
	@echo -e "\nPurging syslinux version $(SYSLINUX_VERSION)."
	@rm -f syslinux-build
	@rm -f syslinux-config
	@rm -rf syslinux-$(SYSLINUX_VERSION) syslinux

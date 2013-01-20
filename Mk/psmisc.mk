#----------------------------------------------------------------------
# psmisc
#----------------------------------------------------------------------
SUBDIR_CONFIG   += psmisc-config
SUBDIR_BUILD    += psmisc-build
SUBDIR_INSTALL  += psmisc-install
SUBDIR_CLEAN    += psmisc-clean
SUBDIR_DISTCLEAN+= psmisc-distclean

psmisc-config:
	@echo -e "\nExtract and Configure psmisc version $(PSMISC_VERSION)."
	@scripts/util_config psmisc $(PSMISC_VERSION) $(ARCHIVE_DIR)\
		> /tmp/psmisc-config
	@cd psmisc && ./configure --prefix=/usr
	@mv /tmp/psmisc-config .

psmisc-build: psmisc-config
	@echo -e "\nBuilding psmisc version $(PSMISC_VERSION)."
	@$(MAKE) -C psmisc/src CC=$(CROSS_COMPILE)gcc \
		> /tmp/psmisc-build > /tmp/psmisc-build 2>&1
	mv /tmp/psmisc-build .

psmisc-install: psmisc-build
	@echo -e "\nInstalling psmisc version $(PSMISC_VERSION)."
	@cp psmisc/src/killall $(IMAGE_DIR)/sbin

psmisc-clean:
	@echo -e "\nCleaning psmisc version $(PSMISC_VERSION)."
	@rm -f psmisc-build
	@rm -f psmisc-config
	@-$(MAKE) -C psmisc clean > /dev/null 2>&1

psmisc-distclean:
	@echo -e "\nPurging psmisc version $(PSMISC_VERSION)."
	@rm -f psmisc-build
	@rm -f psmisc-config
	@rm -rf psmisc-$(PSMISC_VERSION) psmisc

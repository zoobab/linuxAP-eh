#----------------------------------------------------------------------
# cramfs
#----------------------------------------------------------------------
SUBDIR_CONFIG   += cramfs-config
SUBDIR_BUILD    += cramfs-build
# SUBDIR_INSTALL  += cramfs-install
# SUBDIR_CLEAN    += cramfs-clean
SUBDIR_DISTCLEAN+= cramfs-distclean
cramfs-config:
	@echo -e "\nExtract and Configure cramfs utlities version $(CRAMFS_VERSION)."
	@scripts/util_config cramfs $(CRAMFS_VERSION) $(ARCHIVE_DIR)\
		> /tmp/cramfs-config
	@mv /tmp/cramfs-config .

cramfs-build: cramfs-config
	@echo -e "\nBuilding cramfs utilities version $(CRAMFS_VERSION)."
	@cd cramfs && make \
		> /tmp/cramfs-build > /tmp/cramfs-build 2>&1
	@mv /tmp/cramfs-build .

cramfs-clean:
	@echo -e "\nCleaning cramfs utilities version $(CRAMFS_VERSION)."
	@rm -f cramfs-build
	@rm -f cramfs-config
	@-$(MAKE) -C cramfs clean > /dev/null 2>&1

cramfs-distclean:
	@echo -e "\nPurging cramfs utilities version $(CRAMFS_VERSION)."
	@rm -f cramfs-build
	@rm -f cramfs-config
	@rm -rf cramfs-$(CRAMFS_VERSION) cramfs

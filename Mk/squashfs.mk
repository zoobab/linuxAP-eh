#----------------------------------------------------------------------
# squashfs
#----------------------------------------------------------------------
SUBDIR_CONFIG   += squashfs-config
SUBDIR_BUILD    += squashfs-build
# SUBDIR_INSTALL  += squashfs-install
# SUBDIR_CLEAN    += squashfs-clean
SUBDIR_DISTCLEAN+= squashfs-distclean
squashfs-config:
	@echo -e "\nExtract and Configure squashfs utlities version $(SQUASHFS_VERSION)."
	@scripts/util_config squashfs $(SQUASHFS_VERSION) $(ARCHIVE_DIR)\
		> /tmp/squashfs-config
	@mv /tmp/squashfs-config .

squashfs-build: squashfs-config
	@echo -e "\nBuilding squashfs utilities version $(SQUASHFS_VERSION)."
	@make -C squashfs/squashfs-tools  > /tmp/squashfs-build 
	@mv /tmp/squashfs-build .

squashfs-clean:
	@echo -e "\nCleaning squashfs utilities version $(SQUASHFS_VERSION)."
	@rm -f squashfs-build
	@rm -f squashfs-config
	@-$(MAKE) -C squashfs clean > /dev/null 2>&1

squashfs-distclean:
	@echo -e "\nPurging squashfs utilities version $(SQUASHFS_VERSION)."
	@rm -f squashfs-build
	@rm -f squashfs-config
	@rm -rf squashfs$(SQUASHFS_VERSION) squashfs

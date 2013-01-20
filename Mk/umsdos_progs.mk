#----------------------------------------------------------------------
# umsdos_progs
#----------------------------------------------------------------------
SUBDIR_CONFIG   += umsdos_progs-config
SUBDIR_BUILD    += umsdos_progs-build
SUBDIR_INSTALL  += umsdos_progs-install
SUBDIR_CLEAN    += umsdos_progs-clean
SUBDIR_DISTCLEAN+= umsdos_progs-distclean

umsdos_progs-config:
	@echo -e "\nExtract and Configure umsdos_progs version $(UMSDOS_VERSION)."
	@scripts/util_config umsdos_progs $(UMSDOS_VERSION) $(ARCHIVE_DIR)\
		> /tmp/umsdos_progs-config
	@mv /tmp/umsdos_progs-config .

umsdos_progs-build: umsdos_progs-config
	@echo -e "\nBuilding umsdos_progs version $(UMSDOS_VERSION)."
	@$(MAKE) -C umsdos_progs \
		GCC=$(CROSS_COMPILE)gcc \
		GPP=$(CROSS_COMPILE)g++ \
		> /tmp/umsdos_progs-build > /tmp/umsdos_progs-build 2>&1
	@mv /tmp/umsdos_progs-build .

umsdos_progs-install: umsdos_progs-build
	@echo -e "\nInstalling umsdos_progs version $(UMSDOS_VERSION)."
	@cp -a ./umsdos_progs/util/umssync $(IMAGE_DIR)/sbin
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/sbin/umssync

umsdos_progs-clean:
	@echo -e "\nCleaning umsdos_progs version $(UMSDOS_VERSION)."
	@rm -f umsdos_progs-build
	@rm -f umsdos_progs-config
	@-$(MAKE) -C umsdos_progs clean > /dev/null 2>&1

umsdos_progs-distclean:
	@echo -e "\nPurging umsdos_progs version $(UMSDOS_VERSION)."
	@rm -f umsdos_progs-build
	@rm -f umsdos_progs-config
	@rm -rf umsdos_progs-$(UMSDOS_VERSION) umsdos_progs

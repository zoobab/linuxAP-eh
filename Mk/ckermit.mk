#----------------------------------------------------------------------
# ckermit
#----------------------------------------------------------------------
SUBDIR_CONFIG   += ckermit-config
SUBDIR_BUILD    += ckermit-build
SUBDIR_INSTALL  += ckermit-install
SUBDIR_CLEAN    += ckermit-clean
SUBDIR_DISTCLEAN+= ckermit-distclean

ckermit-config:
	@echo -e "\nExtract and Configure ckermit version $(CKERMIT_VERSION)."
	@rm -rf ckermit-$(CKERMIT_VERSION) ckermit
	@mkdir ckermit-$(CKERMIT_VERSION)
	@ln -s ckermit-$(CKERMIT_VERSION) ckermit
	@cd ckermit && tar xvfz $(ARCHIVE_DIR)/cku$(CKERMIT_VERSION).tar.gz > /tmp/ckermit-config
	@[ -f patches/ckermit/$(CKERMIT_VERSION) ] && \
		(cd ckermit && patch -p1 < ../patches/ckermit/$(CKERMIT_VERSION) \
		) >> /tmp/ckermit-config || true
	@mv /tmp/ckermit-config .

ckermit-build: ckermit-config
	@echo -e "\nBuilding ckermit version $(CKERMIT_VERSION)."
ifeq ($(CONFIG_UCLIBC),y)
	@$(MAKE) -C ckermit CROSS_COMPILE=$(CROSS_COMPILE) uclinux > \
		/tmp/ckermit-build > /tmp/ckermit-build 2>&1
else
	@$(MAKE) -C ckermit linux > /tmp/ckermit-build > /tmp/ckermit-build 2>&1
endif
	@mv /tmp/ckermit-build .

ckermit-install: ckermit-build
	@echo -e "\nInstalling ckermit version $(CKERMIT_VERSION)."
	@mkdir -p Image_final/usr/bin
	@cp ckermit/wermit Image_final/usr/bin/kermit
	@$(STRIP) $(STRIPFLAGS) --strip-all Image_final/usr/bin/kermit

ckermit-clean:
	@echo -e "\nCleaning ckermit version $(CKERMIT_VERSION)."
	@rm -f ckermit-build
	@rm -f ckermit-config
	@-$(MAKE) -C ckermit clean > /dev/null 2>&1

ckermit-distclean:
	@echo -e "\nPurging ckermit version $(CKERMIT_VERSION)."
	@rm -f ckermit-build
	@rm -f ckermit-config
	@rm -rf ckermit-$(CKERMIT_VERSION) ckermit

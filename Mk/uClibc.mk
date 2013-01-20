#----------------------------------------------------------------------
# uClibc Section
# This is the *FIRST* item of business after the
# kernel is extracted && Configured
#----------------------------------------------------------------------
# Definitions
LIBS=ld-uClibc.so* libc.so* libresolv.so* libdl.so* libcrypt.so* \
        ld-uClibc-$(UCLIBC_VERSION).so \
        libuClibc-$(UCLIBC_VERSION).so \
        libresolv-$(UCLIBC_VERSION).so \
        libdl-$(UCLIBC_VERSION).so \
        libcrypt-$(UCLIBC_VERSION).so

# Must happen first
#SUBDIR_CONFIG += uClibc-config
#SUBDIR_BUILD += uClibc-build
#SUBDIR_INSTALL += uClibc-install
SUBDIR_CLEAN += uClibc-clean
SUBDIR_DISTCLEAN += uClibc-distclean

uClibc-patch:
	@echo -e "\nExtracting and patching uClibc version $(UCLIBC_VERSION)."
	@scripts/util_config uClibc $(UCLIBC_VERSION) $(ARCHIVE_DIR) \
		> /tmp/uClibc-patch
	@mv /tmp/uClibc-patch ./

uClibc-config: uClibc-patch
	@echo -e "\nConfiguring uClibc version $(UCLIBC_VERSION)."
	@touch /tmp/uClibc-config
ifneq ($(UCLIBC_VERSION),0.9.12)
	make -C uClibc oldconfig >> /tmp/uClibc-config
endif
	@mv /tmp/uClibc-config .

uClibc-build: uClibc-config
	@echo -e "\nBuilding uClibc version $(UCLIBC_VERSION) Please be patient ..."
	@$(MAKE) -C uClibc \
		KERNEL_SOURCE=$(KERNEL_DIR) \
		> /tmp/uClibc-build 2>&1
	@mv /tmp/uClibc-build ./

uClibc-install: uClibc-build
	@echo -e "\nInstalling uClibc version $(UCLIBC_VERSION) ..."
	@rm -rf /usr/i386-linux-uclibc
	@rm -rf /usr/i386-linux-uclibc-$(UCLIBC_VERSION)
	@mkdir -p /usr/i386-linux-uclibc-$(UCLIBC_VERSION)
	@cd /usr && ln -s i386-linux-uclibc-$(UCLIBC_VERSION) \
		./i386-linux-uclibc
	@$(MAKE) -C uClibc PREFIX=/ install \
		> /tmp/uClibc-install 2>&1
	@mv /tmp/uClibc-install ./

uClibc-clean:
	@echo -e "\nCleaning uClibc version $(UCLIBC_VERSION) ..."
	@rm -f uClibc-install
	@rm -f uClibc-build
	@rm -Rf /usr/i386-linux-uclibc i386-linux-uclibc-$(UCLIBC_VERSION)
	@-$(MAKE) -C uClibc clean > /dev/null 2>&1

uClibc-distclean:
	@echo -e "\nPurging uClibc version $(UCLIBC_VERSION) ..."
	@rm -f uClibc-install
	@rm -f uClibc-build
	@rm -f uClibc-config uClibc-patch
	@rm -rf uClibc-$(UCLIBC_VERSION) uClibc
	@rm -Rf /usr/i386-linux-uclibc /usr/i386-linux-uclibc-$(UCLIBC_VERSION)

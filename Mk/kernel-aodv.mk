#----------------------------------------------------------------------
# kernel-aodv
#----------------------------------------------------------------------
SUBDIR_CONFIG   += kernel-aodv-config
SUBDIR_BUILD    += kernel-aodv-build
SUBDIR_INSTALL  += kernel-aodv-install
SUBDIR_CLEAN    += kernel-aodv-clean
SUBDIR_DISTCLEAN+= kernel-aodv-distclean

KERNEL_AODV_INSMODIR = Image_final/lib/modules/$(KERNEL_VERSION)/net/
KERNEL_AODV_MOD   = kernel-aodv/kernel_aodv.o
 
kernel-aodv-config:
	@echo -e "\nExtract and Configure kernel-aodv version $(KERNEL_AODV_VERSION)."
	@scripts/util_config kernel-aodv $(KERNEL_AODV_VERSION) $(ARCHIVE_DIR)\
		> /tmp/kernel-aodv-config 2>&1
	@mv /tmp/kernel-aodv-config .

kernel-aodv-build: kernel-aodv-config
	@echo -e "\nBuilding kernel-aodv version $(KERNEL_AODV_VERSION)."
	@$(MAKE) -C kernel-aodv \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		KERNEL_VERSION=$(KERNEL_VERSION) \
		DESTDIR=$(IMAGE_DIR) \
		> /tmp/kernel-aodv-build 2>&1
	@mv /tmp/kernel-aodv-build .

kernel-aodv-install: kernel-aodv-build
	@echo -e "\nInstalling kernel-aodv version $(KERNEL_AODV_VERSION)."
ifeq ($(KERNEL_AODV_VERSION), "v2.1")
	@$(MAKE) -C kernel-aodv install \
		KERNEL_VERSION=$(KERNEL_VERSION) \
		DESTDIR=$(IMAGE_DIR) \
		> /tmp/kernel-aodv-install 2>&1
else
	@cp $(KERNEL_AODV_MOD) $(KERNEL_AODV_INSMODIR)/ \
		> /tmp/kernel-aodv-install 2>&1
endif
	@$(STRIP) --strip-debug $(KERNEL_AODV_INSMODIR)/kernel_aodv.o \
		>> /tmp/kernel-aodv-install 2>&1
	@scripts/util_setup install kernel-aodv $(KERNEL_AODV_VERSION) \
		>> /tmp/kernel-aodv-install 2>&1

kernel-aodv-clean:
	@echo -e "\nCleaning kernel-aodv version $(KERNEL_AODV_VERSION)."
	@rm -f kernel-aodv-build
	@rm -f kernel-aodv-config
	@-$(MAKE) -C kernel-aodv clean > /dev/null 2>&1
	@scripts/util_setup clean kernel-aodv $(KERNEL_AODV_VERSION)

kernel-aodv-distclean:
	@echo -e "\nPurging kernel-aodv version $(KERNEL_AODV_VERSION)."
	@rm -f kernel-aodv-build
	@rm -f kernel-aodv-config
	@rm -f kernel-aodv-install
	@rm -rf kernel-aodv_$(KERNEL_AODV_VERSION) kernel-aodv
	@scripts/util_setup clean kernel-aodv $(KERNEL_AODV_VERSION)

#----------------------------------------------------------------------
# kernel.mk
#
# Rebuild the kernel if we change the configuration
#
# Need wireless_tools to grab latest wireless.h
#----------------------------------------------------------------------
SUBDIR_DISTCLEAN += kernel-distclean

kernel-patch: wireless_tools-config
	@echo -e "\nExtracting and patching Linux Kernel Version $(KERNEL_VERSION)."
	@echo -e "Please be patient. . ."
	@scripts/util_config linux $(KERNEL_VERSION) $(ARCHIVE_DIR) \
		> /tmp/kernel-patch 2>&1
	@cp wireless_tools/wireless.h linux/include/linux/wireless.h
	@mv /tmp/kernel-patch .

kernel-config: kernel-patch $(AP_BUILD)/kernel-config/$(KERNEL_VERSION)
	@echo -e "\nConfiguring $(AP_BUILD) Linux Kernel Version $(KERNEL_VERSION)."
	@echo -e "Please be patient. . ."
	@touch /tmp/kernel-config
	@cp $(AP_BUILD)/kernel-config/$(KERNEL_VERSION)/base linux/.config
	@scripts/util_cond + linux $(KERNEL_VERSION) '$(COND_KERNEL)' \
		> /tmp/kernel-config 2>&1
	@$(MAKE) -C $(KERNEL_DIR) oldconfig >> /tmp/kernel-config 2>& 1
	@$(MAKE) -C $(KERNEL_DIR) dep >> /tmp/kernel-config 2>&1
	@mv /tmp/kernel-config .

kernel: kernel-config
	@echo -e "\nBuilding $(AP_BUILD) kernel, this may take a while ..."
	@$(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) \
		bzImage > /tmp/kernel-build 2>&1
	@echo "make bzImage done".
	@$(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) \
		modules >> /tmp/kernel-build 2>&1
	@echo "make modules done".
	@cp -va $(KERNEL_DIR)/arch/i386/boot/bzImage ./kernel
	@mv /tmp/kernel-build .
	@echo -e "Built ./kernel\n"

kernel-config-sram: kernel-patch $(AP_BUILD)/kernel-config/$(KERNEL_VERSION)/sram
	@echo -e "\nConfiguring SRAM Linux Kernel Version $(KERNEL_VERSION)."
	@echo -e "Please be patient. . ."
	@cp $(AP_BUILD)/kernel-config/$(KERNEL_VERSION)/sram linux/.config
	@$(MAKE) -C $(KERNEL_DIR) oldconfig >> /tmp/kernel-config-sram 2>& 1
	@$(MAKE) -C $(KERNEL_DIR) dep >> /tmp/kernel-config-sram 2>&1
	@mv /tmp/kernel-config-sram .

kernel-sram: kernel-config-sram
	@echo -e "\nBuilding SRAM kernel, this may take a while ..."
	@$(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) \
		bzImage > /tmp/kernel-build-sram 2>&1
	@echo "make bzImage done".
	@cp -va $(KERNEL_DIR)/arch/i386/boot/bzImage ./kernel-sram
	@mv /tmp/kernel-build-sram .
	@echo -e "Built ./kernel-sram\n"

kernel-install:
	@echo -e "\nInstalling kernel modules to $(IMAGE_DIR)"
	@$(MAKE) -C $(KERNEL_DIR) INSTALL_MOD_PATH=$(IMAGE_DIR) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		modules_install > /tmp/kernel-install.out 2>&1
	#find $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/kernel -type f -name '*.o' \
		-exec $(STRIP) $(STRIPFLAGS) {} \;
	@find $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/kernel -type f -name '*.o' \
		-exec $(STRIP) $(STRIPFLAGS) {} \;
	@echo -e "kernel modules installed.\n"

kernel-clean:
	@echo -e "\nBegin Cleaning linux source directory."
	@$(MAKE) -C $(KERNEL_DIR) clean
	@rm -f kernel kernel-sram kernel-build kernel-build-sram
	@echo -e "Done Cleaning linux source directory.\n"

kernel-distclean:
	@echo -e "\nPurging Linux Kernel Version $(KERNEL_VERSION)."
	@rm -rf kernel kernel-sram \
		kernel-build kernel-build-sram \
		kernel-config kernel-config-sram \
		kernel-patch linux linux-$(KERNEL_VERSION)
	@echo -e "Done Purging linux source directory.\n"

kernel-clean-flash:
	@echo -e "\nBegin Cleaning flash's kernel image and source."
	@rm -rf kernel kernel-config
	@$(MAKE) -C $(KERNEL_DIR) clean
	@echo -e "Done Cleaning flash's kernel image and source.\n"

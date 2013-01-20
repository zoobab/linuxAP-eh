#----------------------------------------------------------------------
# pcmcia-cs
# NOTE: Must come before hostap stuff!!!!
#----------------------------------------------------------------------
SUBDIR_CONFIG   += pcmcia-cs-config
SUBDIR_BUILD    += pcmcia-cs-build
SUBDIR_INSTALL  += pcmcia-cs-install
SUBDIR_CLEAN    += pcmcia-cs-clean
SUBDIR_DISTCLEAN+= pcmcia-cs-distclean

pcmcia-cs-config: kernel-config
	@echo -e "\nConfigure pcmcia-cs version $(PCMCIA_VERSION)."
	@scripts/util_config pcmcia-cs $(PCMCIA_VERSION) $(ARCHIVE_DIR) \
		> /tmp/pcmcia-cs-config 2>&1
	@cd pcmcia-cs && ./Configure -n --kernel=$(KERNEL_DIR) \
		--target=$(IMAGE_DIR) --ucc=$(CC) --trust \
		--nocardbus --nopnp --noapm --srctree \
		>> /tmp/pcmcia-cs-config 2>&1
	@mv /tmp/pcmcia-cs-config .

pcmcia-cs-build: pcmcia-cs-config
	@echo -e "\nBuilding pcmcia-cs version $(PCMCIA_VERSION). . ."
	@$(MAKE) -C pcmcia-cs all > /tmp/pcmcia-cs-build 2>&1
	@mv /tmp/pcmcia-cs-build .

pcmcia-cs-install: pcmcia-cs-build
	@echo -e "\nInstalling pcmcia-cs version $(PCMCIA_VERSION). . ."
	@$(MAKE) -C pcmcia-cs install > /tmp/pcmcia-cs-install 2>&1
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/sbin/cardmgr
	@rm -rf $(IMAGE_DIR)/usr/man $(IMAGE_DIR)/usr/share/man
ifeq ($(AP_BUILD),wl11000)
	@rm -f $(IMAGE_DIR)/sbin/cardctl
	@rm -f $(IMAGE_DIR)/sbin/dump_cis
	@rm -f $(IMAGE_DIR)/sbin/pack_cis
	@rm -f $(IMAGE_DIR)/sbin/pcic_probe
	@rm -f $(IMAGE_DIR)/sbin/ifport
	@rm -f $(IMAGE_DIR)/sbin/ifuser
	@rm -f $(IMAGE_DIR)/sbin/ide_info
	@rm -f $(IMAGE_DIR)/sbin/pcinitrd
	@rm -f $(IMAGE_DIR)/sbin/ftl_format
	@rm -f $(IMAGE_DIR)/sbin/ftl_check
	@rm -f $(IMAGE_DIR)/sbin/dump_sys
	@rm -f $(IMAGE_DIR)/sbin/pack_sys
	@rm -f $(IMAGE_DIR)/usr/bin/gpccard
	@rm -rf $(IMAGE_DIR)/etc/pcmcia/*
	@rm -f $(IMAGE_DIR)/etc/rc.d/rc.pcmcia
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/3c574_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/3c589_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/airo.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/airo_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/axnet_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/dummy_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/fmvj18x_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/ftl_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/hermes.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/ide-cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/iflash2+_mtd.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/iflash2_mtd.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/memory_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/netwave_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/nmclan_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/orinoco.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/orinoco_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/pcnet_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/ray_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/serial_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/smc91c92_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/sram_mtd.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/tcic.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/wavelan_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/wvlan_cs.o
	@rm -f $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/xirc2ps_cs.o
	-@$(STRIP) $(STRIPFLAGS) --strip-unneeded $(IMAGE_DIR)/lib/modules/$(KERNEL_VERSION)/pcmcia/*
	cp -va $(AP_BUILD)/Image_static/etc/pcmcia $(IMAGE_DIR)/etc
endif

pcmcia-cs-clean:
	@rm -f pcmcia-cs-build
	@rm -f pcmcia-cs-config
	@-$(MAKE) -C pcmcia-cs clean > /dev/null

pcmcia-cs-distclean:
	@rm -f pcmcia-cs-build pcmcia-cs-clean pcmcia-cs-config
	@rm -rf pcmcia-cs-$(PCMCIA_VERSION) pcmcia-cs

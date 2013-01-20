#----------------------------------------------------------------------
# iptables
#----------------------------------------------------------------------
SUBDIR_CONFIG   += iptables-config
SUBDIR_BUILD    += iptables-build
SUBDIR_INSTALL  += iptables-install
SUBDIR_CLEAN    += iptables-clean
SUBDIR_DISTCLEAN+= iptables-distclean
COND_KERNEL     += iptables/$(IPTABLES_VERSION)

iptables-config:
	@echo -e "\nExtract and Configure iptables version $(IPTABLES_VERSION)."
	@scripts/util_config iptables $(IPTABLES_VERSION) $(ARCHIVE_DIR) \
		>/tmp/iptables-config 2>&1
	@mv /tmp/iptables-config .

iptables-build: iptables-config
	@echo -e "\nBuilding iptables version $(IPTABLES_VERSION)."
	@$(MAKE) -C iptables \
		CC=$(CC) \
		KERNEL_DIR=$(KERNEL_DIR) \
		DESTDIR=$(IMAGE_DIR) \
		COPT_FLAGS=-Os \
		> /tmp/iptables-build 2>&1
	@mv /tmp/iptables-build .

iptables-install: iptables-build
	@echo -e "\nInstalling iptables version $(IPTABLES_VERSION)."
	@$(MAKE) -C iptables \
		CC=$(CC) \
		KERNEL_DIR=$(KERNEL_DIR) \
		DESTDIR=$(IMAGE_DIR) \
		install > /tmp/iptables-install 2>&1
	@rm -rf $(IMAGE_DIR)/usr/man $(IMAGE_DIR)/usr/share/man
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/usr/sbin/iptables
ifeq ($(AP_BUILD),soekris)
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/usr/sbin/iptables-restore
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/usr/sbin/iptables-save
endif
ifeq ($(AP_BUILD),wl11000)
	@rm -f $(IMAGE_DIR)/usr/sbin/iptables-restore
	@rm -f $(IMAGE_DIR)/usr/sbin/iptables-save
endif
	@rm -f $(IMAGE_DIR)/usr/lib/iptables/*
	@scripts/iptables_ext $(IMAGE_DIR)
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/usr/lib/iptables/*

iptables-clean:
	@echo -e "\nCleaning iptables version $(IPTABLES_VERSION)."
	@rm -f iptables-build
	@rm -f iptables-config
	@-$(MAKE) -C iptables clean > /dev/null 2>&1

iptables-distclean:
	@echo -e "\nPurging iptables version $(IPTABLES_VERSION)."
	@rm -f iptables-build
	@rm -f iptables-config
	@rm -rf iptables-$(IPTABLES_VERSION) iptables
	@scripts/util_cond - linux $(KERNEL_VERSION) iptables/$(IPTABLES_VERSION)
	@echo "   ATTENTION: Should clean flash's kernel image ans sources (make kernel-clean-flash)"

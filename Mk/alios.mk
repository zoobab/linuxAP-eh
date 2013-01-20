#----------------------------------------------------------------------
# alios
#----------------------------------------------------------------------
# SUBDIR_CONFIG   += alios-config
# SUBDIR_BUILD    += alios-build
SUBDIR_CLEAN    += alios-clean
SUBDIR_DISTCLEAN+= alios-distclean

ifeq ($(CONFIG_WLSPD_HYPER),y)
SPEED := -DSPEED_HYPER
endif
ifeq ($(CONFIG_WLSPD_NORMAL),y)
SPEED := -DSPEED_NORMAL
endif
ifeq ($(CONFIG_WLSPD_SLOW),y)
SPEED := -DSPEED_SLOW
endif

alios-build:
	@echo -e "\nBuilding alios."
	@$(MAKE) -C alios clean > /tmp/alios-build 2>&1
ifeq (sram,$(findstring sram,$(MAKECMDGOALS)))
	@$(MAKE) -C alios SFLAGS="-DCARD_BOOT $(SPEED)"  \
		CONFIGURATION_1=0x1Fc000 >> /tmp/alios-build 2>&1
else
	@$(MAKE) -C alios SFLAGS="$(SPEED)" >> /tmp/alios-build 2>&1
endif

alios-clean:
	@echo -e "\nCleaning alios directory."
	@-$(MAKE) -C alios clean > /dev/null 2>&1

alios-distclean: alios-clean

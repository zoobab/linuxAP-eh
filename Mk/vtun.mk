#----------------------------------------------------------------------
# vtun
#----------------------------------------------------------------------
SUBDIR_CONFIG 	+= vtun-config
SUBDIR_BUILD	+= vtun-build
SUBDIR_INSTALL 	+= vtun-install
SUBDIR_CLEAN	+= vtun-clean
SUBDIR_DISTCLEAN+= vtun-distclean

COND_KERNEL     += vtun/$(VTUN_VERSION)

vtun-config:
	@echo -e "\nExtract and Configure vtun version $(VTUN_VERSION)."
	@scripts/util_config vtun $(VTUN_VERSION) $(ARCHIVE_DIR) \
		> /tmp/vtun-config
	@cd vtun && ./configure  \
		./configure --disable-lzo --disable-zlib --disable-crypto --disable-ssl \
		--prefix=$(IMAGE_DIR)/ >> /tmp/vtun-config 2>&1
	@cd ..
	@mv /tmp/vtun-config .

vtun-build: vtun-config
	@echo -e "\nBuilding vtun version $(VTUN_VERSION)."
	@$(MAKE) -C vtun CC=$(CC) > /tmp/vtun-build > /tmp/vtun-build 2>&1
	@mv /tmp/vtun-build .

vtun-install: vtun-build
	@echo -e "\nInstalling vtun version $(VTUN_VERSION)."
	@$(MAKE) -C vtun install > /tmp/vtun-install 2>&1
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/sbin/vtund
	@rm -rf $(IMAGE_DIR)/man/
	#@scripts/util_setup install vtun $(VTUN_VERSION) >> /tmp/vtun-install 2>&1
	@mkdir $(IMAGE_DIR)/dev/net/
	@mknod $(IMAGE_DIR)/dev/net/tun c 10 200
	@echo "alias char-major-10-200 tun" >> $(IMAGE_DIR)/etc/modules.conf

vtun-clean:
	@echo -e "\nCleaning vtun version $(VTUN_VERSION)."
	@rm -f vtun-build
	@rm -f vtun-config
	@-$(MAKE) -C vtun clean > /dev/null 2>&1
	@scripts/util_setup clean vtun $(VTUN_VERSION)

vtun-distclean:
	@echo -e "\nPurging vtun version $(VTUN_VERSION)."
	@rm -f vtun-build
	@rm -f vtun-config
	@rm -rf vtun-$(VTUN_VERSION) vtun
	@scripts/util_setup clean vtun $(VTUN_VERSION)
	@scripts/util_cond - linux $(KERNEL_VERSION) vtun/$(VTUN_VERSION)
	@echo "   ATTENTION: Should clean flash's kernel image ans sources (make kernel-clean-flash)"

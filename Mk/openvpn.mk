#----------------------------------------------------------------------
# openvpn
#----------------------------------------------------------------------
SUBDIR_CONFIG 	+= openvpn-config
SUBDIR_BUILD	+= openvpn-build
SUBDIR_INSTALL 	+= openvpn-install
SUBDIR_CLEAN	+= openvpn-clean
SUBDIR_DISTCLEAN+= openvpn-distclean

COND_KERNEL     += openvpn/$(OPENVPN_VERSION)

openvpn-config:
	@echo -e "\nExtract and Configure openvpn version $(OPENVPN_VERSION)."
	@scripts/util_config openvpn $(OPENVPN_VERSION) $(ARCHIVE_DIR) \
		> /tmp/openvpn-config
	@(cd openvpn; \
		./configure --disable-lzo --disable-crypto --disable-ssl \
		--prefix=$(IMAGE_DIR)/ >> /tmp/openvpn-config 2>&1)
	@mv /tmp/openvpn-config .

openvpn-build: openvpn-config
	@echo -e "\nBuilding openvpn version $(OPENVPN_VERSION)."
	@$(MAKE) -C openvpn CC=$(CC) > /tmp/openvpn-build 2>&1
	@mv /tmp/openvpn-build .

openvpn-install: openvpn-build
	@echo -e "\nInstalling openvpn version $(OPENVPN_VERSION)."
	@$(MAKE) -C openvpn install > /tmp/openvpn-install 2>&1
	@$(STRIP) $(STRIPFLAGS) --strip-all $(IMAGE_DIR)/sbin/openvpn
	@rm -rf $(IMAGE_DIR)/man/
	@scripts/util_setup install openvpn $(OPENVPN_VERSION) >> /tmp/openvpn-install 2>&1
	@mkdir $(IMAGE_DIR)/dev/net/
	@mknod $(IMAGE_DIR)/dev/net/tun c 10 200
	@echo "alias char-major-10-200 tun" >> $(IMAGE_DIR)/etc/modules.conf

openvpn-clean:
	@echo -e "\nCleaning openvpn version $(OPENVPN_VERSION)."
	@rm -f openvpn-build
	@rm -f openvpn-config
	@-$(MAKE) -C openvpn clean > /dev/null 2>&1
	@scripts/util_setup clean openvpn $(OPENVPN_VERSION)

openvpn-distclean:
	@echo -e "\nPurging openvpn version $(OPENVPN_VERSION)."
	@rm -f openvpn-build
	@rm -f openvpn-config
	@rm -rf openvpn-$(OPENVPN_VERSION) openvpn
	@scripts/util_setup clean openvpn $(OPENVPN_VERSION)
	@scripts/util_cond - linux $(KERNEL_VERSION) openvpn/$(OPENVPN_VERSION)
	@echo "   ATTENTION: Should clean flash's kernel image ans sources (make kernel-clean-flash)"

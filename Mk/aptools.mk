#----------------------------------------------------------------------
# aptools
#----------------------------------------------------------------------
SUBDIR_BUILD    += aptools-build
SUBDIR_INSTALL  += aptools-install
SUBDIR_CLEAN    += aptools-clean
SUBDIR_DISTCLEAN+= aptools-distclean

aptools-build:
	@echo -e "\nBuilding linuxAP aptools."
	$(MAKE) -e -C aptools IMAGE_DIR=$(IMAGE_DIR) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		> /tmp/aptools-build > /tmp/aptools-build 2>&1
	@mv /tmp/aptools-build .

aptools-install: aptools-build
	@echo -e "\nInstalling linuxAP aptools."
	@$(MAKE) -e -C aptools install \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		IMAGE_DIR=$(IMAGE_DIR) \
		STRIPFLAGS=$(STRIPFLAGS)\ --strip-all \
		> /tmp/aptools-install > /tmp/aptools-install 2>&1

aptools-clean:
	@echo -e "\nCleaning linuxAP aptools."
	@rm -f aptools-build
	@-$(MAKE) -C aptools clean > /dev/null 2>&1

aptools-distclean: aptools-clean

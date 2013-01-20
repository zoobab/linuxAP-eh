#----------------------------------------------------------------------
# tinylogin
#----------------------------------------------------------------------
SUBDIR_CONFIG   += tinylogin-config
SUBDIR_BUILD    += tinylogin-build
SUBDIR_INSTALL  += tinylogin-install
SUBDIR_CLEAN    += tinylogin-clean
SUBDIR_DISTCLEAN+= tinylogin-distclean

tinylogin-config:
	@echo -e "\nExtract and Configure tinylogin version $(TINYLOGIN_VERSION)."
	@scripts/util_config tinylogin $(TINYLOGIN_VERSION) $(ARCHIVE_DIR)\
		> /tmp/tinylogin-config
	@mv /tmp/tinylogin-config .

tinylogin-build: tinylogin-config
	@echo -e "\nBuilding tinylogin version $(TINYLOGIN_VERSION)."
	@$(MAKE) -C tinylogin > /tmp/tinylogin-build > /tmp/tinylogin-build 2>&1
	mv /tmp/tinylogin-build .

tinylogin-install: tinylogin-build
	@echo -e "\nInstalling tinylogin version $(TINYLOGIN_VERSION)."
	@$(MAKE) -C tinylogin install > /tmp/tinylogin-install 2>&1

tinylogin-clean:
	@echo -e "\nCleaning tinylogin version $(TINYLOGIN_VERSION)."
	@rm -f tinylogin-build
	@rm -f tinylogin-config
	@-$(MAKE) -C tinylogin clean > /dev/null 2>&1

tinylogin-distclean:
	@echo -e "\nPurging tinylogin version $(TINYLOGIN_VERSION)."
	@rm -f tinylogin-build
	@rm -f tinylogin-config
	@rm -rf tinylogin-$(TINYLOGIN_VERSION) tinylogin

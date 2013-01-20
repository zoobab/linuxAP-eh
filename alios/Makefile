# Makefile.dist - Makefile to assemble alios loader code
#
# Copyright (C) 1999-2001 telos EDV Systementwicklung GmbH (telos)
#
# alios is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#  
# alios is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#  
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
#  
# Author(s):
#
#  Kolja Waschk, telos (KW)
#  Karl-Werner Ahlers, telos (KA)
#  Markus Thiesmeyer, telos (MT)
#  Marco Budde, telos (MB)
#
# $Revision: 1.2 $
#
# Prerequisites to use this Makefile:
#
#  GNU tools (make, gcc, cpp, as, binutils: objcopy)
#
# History (yyyymmdd au desc, most recent first):
#
#  20000922 KW stripped from original Makefile
#  19991004 KW creation of original Makefile

# ---- configuration

# Target length of alios code (paragraphs of 16 bytes, max 2048 => 32 kbyte).
# Whenever you change ALIOS_LEN, you should also remember to update the
# start address where you put alios in your ROM. It has to be TOP-16*ALIOS_LEN
# Currently alios has less than 80P; 192 leaves space for small extensions.

ALIOS_LEN=    992 # Size = 16 * 992 = 3e00h (4000h - 200h)

# Where alios can find the two configuration blocks in ROM

CONFIGURATION_1= 0xFc000
CONFIGURATION_2= 0x200

# This variable should be defined if you want to use alios
# on an evaluation board. 
#EVAL_BRD=1

# Define this if your RTC isn't yet working to have a fixed 
# start date.
#FIXED_DATE=1

# ---- Rest of this file should not have to be changed...

# use GNU AS, but let gcc call the preprocessor CPP
AS=gcc
ASOPTS=-c -Wa,-aln=alios.lst

ifdef EVAL_BRD
ASOPTS+=-DEVAL_BRD
endif

ifdef FIXED_DATE
ASOPTS+=-DFIXED_DATE
endif

# OBJCOPY should take the name of an object file as its first argument and
# write the contained binary code with all symbols resolved to the file named
# as the second argument:

OBJCOPY=objcopy -O binary


all: alios.bin create_config_block

install:
	echo "Nothing to do for install"

alios.bin: alios.S Makefile
	@echo
	@echo "--- Assembling ALIOS bootloader code ---"
	@echo
	@echo "If you get the error \"attempt to org backwards\","
	@echo "increase the ALIOS_LEN in this Makefile."
	@echo
	$(AS) $(ASOPTS) \
		-DALIOS_LEN=$(ALIOS_LEN) \
		-DCONFIG_1_S=$(CONFIGURATION_1) \
		$(SFLAGS) \
			 alios.S
	$(OBJCOPY) alios.o alios.bin
	-$(RM) alios.o
	@echo

create_config_block: create_config_block.c
	@echo
	@echo "--- Compiling create_config_block ---"
	@echo
	gcc -O2 -s create_config_block.c -o create_config_block

.PHONY: clean
clean: 
	-$(RM) *~ *.lst *.bin create_config_block

# vim:ts=8:

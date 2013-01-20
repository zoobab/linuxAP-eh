# Rules.make for uClibc
#
# Copyright (C) 2000 by Lineo, inc.
# Copyright (C) 2000-2002 Erik Andersen <andersen@uclibc.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU Library General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Library General Public License for more
# details.
#
# You should have received a copy of the GNU Library General Public License
# along with this program; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA


#--------------------------------------------------------
# This file contains rules which are shared between multiple Makefiles.
# All normal configuration options live in the file named ".config".
# Don't mess with this file unless you know what you are doing.


#--------------------------------------------------------
# If you are running a cross compiler, you will want to set 'CROSS'
# to something more interesting...  Target architecture is determined
# by asking the CC compiler what arch it compiles things for, so unless
# your compiler is broken, you should not need to specify TARGET_ARCH
#
# Most people will set this stuff on the command line, i.e.
#        make CROSS=mipsel-linux-
# will build uClibc for 'mipsel'.

CROSS=
CC= $(CROSS)gcc
AR= $(CROSS)ar
LD= $(CROSS)ld
NM= $(CROSS)nm
STRIPTOOL= $(CROSS)strip

# Select the compiler needed to build binaries for your development system
NATIVE_CC=gcc
NATIVE_CFLAGS=-O2 -Wall


#--------------------------------------------------------
# Nothing beyond this point should ever be touched by mere mortals.  
# Unless you hang out with the gods, you should probably leave all
# this stuff alone.
MAJOR_VERSION:=0
MINOR_VERSION:=9
SUBLEVEL:=16
VERSION:=$(MAJOR_VERSION).$(MINOR_VERSION).$(SUBLEVEL)
# Ensure consistent filename sort order
LC_COLLATE:= C
export MAJOR_VERSION MINOR_VERSION SUBLEVEL VERSION LC_COLLATE

SHARED_FULLNAME:=libuClibc-$(MAJOR_VERSION).$(MINOR_VERSION).$(SUBLEVEL).so
SHARED_MAJORNAME:=libc.so.$(MAJOR_VERSION)
UCLIBC_LDSO:=ld-uClibc.so.$(MAJOR_VERSION)
LIBNAME:=libc.a
LIBC:=$(TOPDIR)libc/$(LIBNAME)

# Pull in the user's uClibc configuration
ifeq ($(filter $(noconfig_targets),$(MAKECMDGOALS)),)
include_config := 1
-include $(TOPDIR).config
endif

# A nifty macro to make testing gcc features easier
check_gcc=$(shell if $(CC) $(1) -S -o /dev/null -xc /dev/null > /dev/null 2>&1; \
	then echo "$(1)"; else echo "$(2)"; fi)

# check if we have nawk, otherwise user awk
AWK:=$(shell if [ -x /usr/bin/nawk ]; then echo "/usr/bin/nawk"; \
	else echo "/usr/bin/awk"; fi)

NATIVE_ARCH:= $(shell uname -m | sed \
		-e 's/i.86/i386/' \
		-e 's/sparc.*/sparc/' \
		-e 's/arm.*/arm/g' \
		-e 's/m68k.*/m68k/' \
		-e 's/ppc/powerpc/g' \
		-e 's/v850.*/v850/g' \
		-e 's/sh[234].*/sh/' \
		-e 's/mips.*/mips/' \
		)
ifeq ($(strip $(TARGET_ARCH)),)
TARGET_ARCH:=$(shell $(CC) -dumpmachine | sed -e s'/-.*//' \
		-e 's/i.86/i386/' \
		-e 's/sparc.*/sparc/' \
		-e 's/arm.*/arm/g' \
		-e 's/m68k.*/m68k/' \
		-e 's/ppc/powerpc/g' \
		-e 's/v850.*/v850/g' \
		-e 's/sh[234]/sh/' \
		-e 's/mips-.*/mips/' \
		-e 's/mipsel-.*/mipsel/' \
		-e 's/cris.*/cris/' \
		)
endif
export TARGET_ARCH

ARFLAGS:=r

# use '-Os' optimization if available, else use -O2, allow Config to override
OPTIMIZATION:=
OPTIMIZATION+=$(call check_gcc,-Os,-O2)

# Some nice CPU specific optimizations
ifeq ($(strip $(TARGET_ARCH)),i386)
	OPTIMIZATION+=$(call check_gcc,-mpreferred-stack-boundary=2,)
	OPTIMIZATION+=$(call check_gcc,-falign-jumps=0 -falign-loops=0,-malign-jumps=0 -malign-loops=0)
	CPU_CFLAGS-$(CONFIG_386):="-march=i386"
	CPU_CFLAGS-$(CONFIG_486):="-march=i486"
	CPU_CFLAGS-$(CONFIG_586):="-march=i586"
	CPU_CFLAGS-$(CONFIG_586MMX):="$(call check_gcc,-march=pentium-mmx,-march=i586)"
	CPU_CFLAGS-$(CONFIG_686):="-march=i686"
	CPU_CFLAGS-$(CONFIG_PENTIUMIII):="$(call check_gcc,-march=pentium3,-march=i686)"
	CPU_CFLAGS-$(CONFIG_PENTIUM4):="$(call check_gcc,-march=pentium4,-march=i686)"
	CPU_CFLAGS-$(CONFIG_K6):="$(call check_gcc,-march=k6,-march=i586)"
	CPU_CFLAGS-$(CONFIG_K7):="$(call check_gcc,-march=athlon,-malign-functions=4 -march=i686)"
	CPU_CFLAGS-$(CONFIG_CRUSOE):="-march=i686 -malign-functions=0 -malign-jumps=0 -malign-loops=0"
	CPU_CFLAGS-$(CONFIG_WINCHIPC6):="$(call check_gcc,-march=winchip-c6,-march=i586)"
	CPU_CFLAGS-$(CONFIG_WINCHIP2):="$(call check_gcc,-march=winchip2,-march=i586)"
	CPU_CFLAGS-$(CONFIG_CYRIXIII):="$(call check_gcc,-march=c3,-march=i586)"
endif

ifeq ($(strip $(TARGET_ARCH)),arm)
	OPTIMIZATION+=-fstrict-aliasing
	CPU_CFLAGS-$(CONFIG_GENERIC_ARM):=
	CPU_CFLAGS-$(CONFIG_ARM7TDMI):="-mcpu=arm7tdmi"
	CPU_CFLAGS-$(CONFIG_STRONGARM):="-mcpu=strongarm"
	CPU_CFLAGS-$(CONFIG_XSCALE):="$(call check_gcc,-mcpu=xscale,-mcpu=strongarm)"
endif

ifeq ($(strip $(TARGET_ARCH)),sh)
	OPTIMIZATION+=-fstrict-aliasing
	OPTIMIZATION+= $(call check_gcc,-mprefergot,)
	CPU_LDFLAGS-$(ARCH_LITTLE_ENDIAN):="-EL"
	CPU_LDFLAGS-$(ARCH_BIG_ENDIAN):="-EB"
	CPU_CFLAGS-$(ARCH_LITTLE_ENDIAN):="-ml"
	CPU_CFLAGS-$(ARCH_BIG_ENDIAN):="-mb"
	CPU_CFLAGS-$(CONFIG_SH2)+="-m2"
	CPU_CFLAGS-$(CONFIG_SH3)+="-m3"
	CPU_CFLAGS-$(CONFIG_SH4)+="-m4"
	CPU_CFLAGS-$(CONFIG_SH5)+="-m5"
endif

# Add a bunch of extra pedantic annoyingly strict checks
WARNINGS+=-Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing

# Some nice CFLAGS to work with
CFLAGS:=$(WARNINGS) $(OPTIMIZATION) -fno-builtin -nostdinc $(CPUFLAGS) \
	-D_LIBC $(CPU_CFLAGS-y) $(ARCH_CFLAGS) -I$(TOPDIR)include -I.

# Sigh, some stupid versions of gcc can't seem to cope with '-iwithprefix include'
#CFLAGS+=-iwithprefix include
CFLAGS+=$(shell $(CC) -print-search-dirs | sed -ne "s/install: *\(.*\)/-I\1include/gp")


ifeq ($(strip $(DODEBUG)),y)
    CFLAGS += -g
    LDFLAGS:= $(CPU_LDFLAGS-y) -shared --warn-common --warn-once -z combreloc
    STRIPTOOL:= true -Since_we_are_debugging
else
    LDFLAGS := $(CPU_LDFLAGS-y) -s -shared --warn-common --warn-once -z combreloc
endif
ifneq ($(strip $(DOASSERTS)),y)
    CFLAGS += -DNDEBUG
endif

ifeq ($(strip $(HAVE_SHARED)),y)
    LIBRARY_CACHE:=#-DUSE_CACHE
    ifeq ($(strip $(BUILD_UCLIBC_LDSO)),y)
	LDSO:=$(TOPDIR)lib/$(UCLIBC_LDSO)
	DYNAMIC_LINKER:=$(SHARED_LIB_LOADER_PATH)/$(UCLIBC_LDSO)
	BUILD_DYNAMIC_LINKER:=$(shell cd $(TOPDIR) && pwd)/lib/$(UCLIBC_LDSO)
    else
	LDSO:=$(SYSTEM_LDSO)
	DYNAMIC_LINKER:=/lib/$(notdir $(SYSTEM_LDSO))
	BUILD_DYNAMIC_LINKER:=/lib/$(notdir $(SYSTEM_LDSO))
   endif
endif
ifeq ($(strip $(DOPIC)),y)
    CFLAGS += -fPIC
endif
ifeq ($(strip $(UCLIBC_HAS_SOFT_FLOAT)),y)
    CFLAGS += $(call check_gcc,-msoft-float,)
endif

LIBGCC_CFLAGS ?= $(CFLAGS) $(CPU_CFLAGS-y)
LIBGCC:=$(shell $(CC) $(LIBGCC_CFLAGS) -print-libgcc-file-name)
LIBGCC_DIR:=$(dir $(LIBGCC))

# TARGET_PREFIX is the directory under which which the uClibc runtime
# environment will be installed and used on the target system.   The 
# result will look something like the following:
#   TARGET_PREFIX/
#	lib/            <contains all runtime and static libs>
#	usr/lib/        <this directory is searched for runtime libs>
#	etc/            <weher the shared library cache and configuration 
#	                information go if you enabled LIBRARY_CACHE above>
# Very few people will need to change this value from the default...
TARGET_PREFIX = /


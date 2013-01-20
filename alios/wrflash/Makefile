# Makefile
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
# Author(s): Marco Budde
# $Revision: 1.2 $


# Where can we find the PCMCIA header files?
PCMCIA_INCLUDE_DIR=../../flasher/pcmcia-cs-3.1.17/include 

# Additional options
COPTS=-O2 -s -I$(PCMCIA_INCLUDE_DIR)

##########################################################
#       Do not changed anything below this line.         #
##########################################################

all: wrflash

wrflash: wrflash.c
	gcc $(COPTS) -o wrflash wrflash.c

clean:
	-rm -f wrflash *~
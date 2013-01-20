/*
 alios.S

 Linux bootloader and BIOS replacement for AMD Elan with flash mem only

 Copyright (C) 1999-2001 telos EDV Systementwicklung GmbH (telos)
 Copyright (C) 2002 Instant802 Networks Inc.

 Some hints and parts of the code are taken from...

   AMD's Windows(tm) CE bootloader (C) 1998 Advanced Micro Devices
   Linux bootsect.S,setup.S,video.S (C) 1991/2 Linus Torvalds

 alios is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
  
 alios is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
  
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA

 Author(s):

  Kolja Waschk, telos (KW)
  Marco Budde, telos (MB)
  Markus Thiesmeyer, telos (MT)

 Version:
  $Id: alios.S,v 1.2 2003/09/29 21:52:20 xscript Exp $	
	
 History (yyyymmdd au desc, most recent first):

  20020114 David Kimdon <dwhedon@instant802.com>, cosmetic fixes.
  20011004 Bill McClintock, Changes to support Eumitcom WL11000SA-N
  20010131 MB added automatic DRAM detection
  20010129 MB added prhexdword and print_dram (DRAM configuration) 
  20010124 KW comments added/mod, config loader output mod, set %esi pointer
  20000922 KW cleanup, removed redundant code (printValue,get_flash_byte,...)
  20000719 MT moved commandline from header into configuration block
  20000202 MT moved KERNEL_CMDLINE definition to the include "cmdline.h" file.
  20000524 MT read (previously hardcoded) parameters from configuration block
  20000524 MT added printValue for printing decimal values
  19991115 KW added DRAM init for NECScom target
  19991029 KW added (yet defunct) call to graphic adapter ROM
  19991029 KW fixed buf with variable start address in gdt pointer
  19991028 KW enabling cache before kernel decompression speeds it up...
  19991028 KW corrected/improved super IO initialisation, set some CMOS vars
  19991027 KW kernel is now loaded high, thus images >576k are allowed
  19991027 KW added more eval board support code from CE bootloader
  19991027 KW translated from Intel style (NASM) to AT&T style (GNU as)
  19991022 KW cleanup
  19991021 KW corrected RTC setup, removed some redundant inits
  19991019 KW added command line 
  19991019 KW corrected deactivation of MMSA+B before far jmp to kernel
  19991008 KW added setup of PARAM structure as far as needed to make
		the kernel startup without exception
		- loads kernel low, can't load ram disk image in this version
  19991007 KW creation using snippets from CE bootloader, bootsect.S, setup.S

 This code can be run from either ROMCS0-driven on-board memory as well as
 from linear PC Card memory (if ROMCS0 is redirected to PC Card Socket A).

 Just make sure the topmost 16 bytes appear physically at the very top of 
 memory space during power-on, i.e. 0x3FFFFFF.

*/

#include <asm/boot.h>
#include <asm/segment.h>

/* ----------
   some definitions
*/

/* define if you want to boot from pcmcia, and map both
   flash and pcmcia into phys address space */
//#define CARD_BOOT

/* define if you want to use the prhex* subroutines */
#define HEXPRINT 

/* use CTS handshaking when sending to serial port? */
//#define RTSCTS

/* command line to pass to the kernel */

/* dst start address for kernel */
#define KERNEL_S	0x00100000	/* above 1MB */

/* the following definitions are not options... dont modify */

#define MMSA_SEG	0xB000
#define MMSB_SEG	0x10000
#define RAMBLOAD_SEG	(0x10000-ALIOS_LEN)
//#define RAMBLOAD_SEG 0x8000
#define ROMBLOAD_SEG	(MMSA_SEG+0x800-ALIOS_LEN)

// This defines the segment address for the bootloader while running
// in protected mode:	
#define BOOT_SEG	0x10000-ALIOS_LEN
		
/* dst start address for kernel setup info (aka bootsect/setup) */
#define BOOTSETUP_SEG	DEF_INITSEG	/* from asm/boot.h */

/* variable data configured on extra locations in ROM/on flash */
#define CONFBUF_OFF	0xF000
#define CONFBUF_LOC	((16*BOOTSETUP_SEG)+CONFBUF_OFF)
/* long word: start byte of kernel image within ROM */
#define VAR_KERNELIMG_S	(CONFBUF_OFF)
/* max 255 bytes + zero: kernel command line */
#define VAR_COMMANDLINE (CONFBUF_OFF+4)

/* for UART initialisation */
#define	UART_BASE	0x03f8

/* Speed definitions */
#ifdef SPEED_HYPER
#define SPEED $0x8140
#endif

#ifdef SPEED_NORMAL
#define SPEED $0x8040
#endif

#ifdef SPEED_SLOW
#define SPEED $0x8240
#endif

#ifndef SPEED
#define SPEED $0x8040
#endif

/* (preliminary) memory layout from Elan's view:

        ; alios  - 03FFFFFF	; (ROMCS0/PCCARD A) alios
        ; 01000000 - alios	; (unused)
	; 00100000 - 00FFFFFF	; system RAM, upper 15 MBs
	; 00100000 - 0010FFFF   ; MMSB (during bootstrap), HMA
	; 000F8000 - 000FFFFF   ; (DRAM) shadow location for alios
	; 000B8000 - 000F7FFF   ; unused
	; 000B0000 - 000B7FFF	; MMSA (during bootstrap)
	; 000A0000 - 000AFFFF   ; unused
        ; 00000000 - 0009FFFF	; 640k base RAM
*/

.text
.code16
.org 0x0000,0xFF

#/**** Temporary Configuration block parameters ****/	
#.long 0x0008dc00	# kernel image start address
#.asciz "console=ttyS0,9600n8"

	

/* ----------
   General setup: I/O address(word), data(byte)
 * ----------*/
begin_config_table:
# CSC registers:
        .word	0x22,	0x40 # PMU Force Mode Register
        .word	0x23,	0x82 # Low Speed Mode

	.word	0x22,	0xd0 # Internal IO device config index
	.word	0x23,	0x02 # enable PC Card controller
# PC Card registers:
	.word	0x3e0,	0x02 # Power and RESETDRV control register index
	.word	0x3e1,	0x30 # VCC enable, auto power enable	
# CSC registers:
	.word	0x22,	0x04 # DRAM control register index
	.word	0x23,	0x5c # Select slow DRAM timing

	.word	0x22,	0x21 # ROMCS0/ shadow register index
	.word	0x23,	0x28 # use mem space 0xF0000..0xFFFFF as RAM (for bootloader)

	.word	0x22,	0x23 # ROMCS0/ configuration register A index
	.word	0x23,	0x30 # set fast rom timings

	.word	0x22,	0x24 # ROMCS0/ wait state config index
	.word	0x23,	0x02 # 2 wait states

	.word	0x22,	0x31 # MMS C-F Window index
	.word	0x23,	0x0c # MMS Window C selects flash, MMS Window D selects DRAM 2

	.word	0x22,	0x38 # Pin mux register A index
	.word	0x23,	0x9f # CLK_IO output, GPIO_CS5 thru GPIO_CS12 ISA
	
	.word	0x22,	0x39 # Pin mux register B index
	.word	0x23,	0x24 # enable gpio 21-31, PC card A VCC and VPP

	.word	0x22,	0x3a # Pin mux register C index
	.word	0x23,	0x02 # PIRQ7-3 pins used as PIRQ, not keyboard scanning

        .word	0x22,	0x80 # CPU clock speed register index
        .word	0x23,	0x04 # High speed 33.18MHz, Low speed 8.29MHz

	.word	0x22,	0x83 # CLK_IO pin output clock select index
	.word	0x23,	0x04 # output = system clock

	.word	0x22,	0xa4 # GPIO function select register E index
	.word	0x23,	0x0c # GPIO 18 & 19 configured as outputs for LEDs (D2-19, D3-18)

	.word	0x22,	0xa5 # GPIO function select register F index
	.word	0x23,	0xc0 # GPIO 30 & 31 configured as outputs (used for watchdog)

	.word	0x22,	0xa8 # GPIO read-back/write register C index
	.word	0x23,	0x00 # Turn off LEDs (active low) (GPIO 18-19)

	.word	0x22,	0xa9 # GPIO read-back/write register D index
	.word	0x23,	0x80 # Set GPIO 30 & 31 to 0 & 1 (disable watchdog timer)

        .word	0x22,	0xd1 # Parallel/Serial port config register index
        .word	0x23,	0x01 # enable internal UART at 0x3F8, no LPT

	.word	0x22,	0xd4 # Interrupt config register A index
	.word	0x23,	0x1e # PIRQ1 (optional extra UART) to IRQ1, PIRQ0 (ethernet INT0) to IRQ14 

	.word	0x22,	0xd7 # Interrupt config register D index
	.word	0x23,	0x06 # PIRQ6 (ethernet INT4) to 

        .word	0x22,	0xd8 # Interrupt configuration register E index
        .word	0x23,	0x40 # UART mapped to IRQ4

# UART registers:
	.word	(UART_BASE+3),	0x80	# set DLAB
	.word	(UART_BASE+0),	0x18	# divisor LSB =12 (for 9600 bps)
	.word	(UART_BASE+1),	0x00	# divisor MSB =0 (for all bps)
	.word	(UART_BASE+3),	0x03	# reset DLAB, clear BRK, use 8N1
	.word	(UART_BASE+4),	0x03	# set DTR, RTS

# CSC registers:
	.word	0x22,	0xE5 # Suspend mode pin state override register index
	.word	0x23,	0x01 # Pin termination latch command (make this the last entry in the table)

# PIC1 initialization:
	.word	0x20,	0x11	# send initialization control word 1
	.word	0x21,	0x20	# start of hw interrupts
	.word	0x21,	0x04	# master PIC
	.word	0x21,	0x01	# 8086 mode
	.word	0x21,	0xfb	# mask all but irq2 (cascade mode)

# PIC2 initialization:
	.word	0xa0,	0x11	# send initialization control word 1
	.word	0xa1,	0x28	# start of second HW interrupts
	.word	0xa1,	0x02	# slave PIC
	.word	0xa1,	0x01	# 8086 mode
	.word	0xa1,	0xff	# mask all interrupts

# DMA controller 1:
	.word	0x00,	0x08	# reset DMA controller #1
	.word	0x00,	0xd0
	.word	0x0b,	0x40	# Channel 0
	.word	0x0b,	0x41	# Channel 1
	.word	0x0b,	0x42	# Channel 2
	.word	0x0b,	0x43	# Channel 3
	.word	0xd6,	0xc0	# Channel 4 cascade
	.word	0xd6,	0x41	# Channel 5
	.word	0xd6,	0x42	# Channel 6
	.word	0xd6,	0x43	# Channel 7

# PC Card registers, used for MMS C and D
# this SC400 specific feature is used to map flash into
# phys address space at 16M, and to remap the hole in RAM
# between 640k and 1M to the top of RAM at 4M
	.word	0x3e0,	0x59 # MMS Window C start addr high index
	.word	0x3e1,	0x10 # Start at 0x1000000

	.word	0x3e0,	0x5b # MMS Window C stop addr high index
	.word	0x3e1,	0x11 # Stop at 0x10fffff

	.word	0x3e0,	0x61 # MMS Window D start addr high index
	.word	0x3e1,	0x04 # Start at 0x400000

	.word	0x3e0,	0x62 # MMS Window D stop addr low index
	.word	0x3e1,	0x60 # Stop at 0x45ffff

	.word	0x3e0,	0x63 # MMS Window D stop addr high index
	.word	0x3e1,	0x04 # Stop at 0x45ffff

	.word	0x3e0,	0x64 # MMS Window D addr offset low index
	.word	0x3e1,	0xa0 # Offset = -0x360000

	.word	0x3e0,	0x65 # MMS Window D addr offset high index
	.word	0x3e1,	0x3c # Offset = -0x360000

	.word	0x3e0,	0x46 # Address window enable register index
	.word	0x3e1,	0x06 # Enable MMS C and D windows now

#ifdef CARD_BOOT	
# Memory window 0, PC card socket A setup:
# Start address = 0x02000000 (32MB)
# End address = 0x021fffff (2MB range)
# Read only, 16 bit data bus, common memory area
	.word	0x3e0,	0x10 # Start addr low index
	.word	0x3e1,  0x00 # bits 12-19 = 0
	
	.word	0x3e0,	0x11 # Start addr high index
	.word	0x3e1,	0xa0 # 16bit, bits 20-25

	.word	0x3e0,	0x12 # Stop addr low index
	.word	0x3e1,	0x00 # 

	.word	0x3e0,	0x13 # Stop addr high index
	.word	0x3e1,	0x22 #

	.word	0x3e0,	0x14 # Offset addr low index
	.word	0x3e1,	0x00 #

	.word	0x3e0,	0x15 # Offset addr high index
	.word	0x3e1,	0x80 # write protect, common memory
	
	.word	0x3e0,	0x06 # Address window enable register index
	.word	0x3e1,	0x01 # Enable window 0 now
#endif
	
end_config_table:	

	
#include "detect_dram.S"
	
/*************************************************************
 * print_dram:	
 *   Prints some informations about the DRAM configuration.
 *************************************************************/
total_ramsize:
        .word 0

				
print_dram:
        xorw    %dx,%dx      //  Bank number
        xorl    %ebx,%ebx    //  Total DRAM detected
print_dram_label1:
	movw    $s_print_dram_0, %si
	call    puts
        movb    %dl,%al
	call    prhexnibble
	movw    $s_print_dram_1, %si
	call    puts
        outb    %al,$0x22
        inb     $0x23,%al
        movb    %al,%ch
        movb    %al,%cl

	testb   $0x80,%cl                // no DRAM?
	jnz     print_dram_label_print
	movw    $s_print_dram_2, %si
	call    puts
	jmp     print_dram_label_mainloop

print_dram_label_print:	
	testb   $8,%cl
	setnzb  %ah
        addb    %ah,%cl
        andb    $0x07,%cl
        addb    $9,%cl
        movl    $1,%eax
        shl     %cl,%eax
        addl    %eax,%ebx         // Add in to total
        call    prhexdword
	movw    $s_print_dram_3, %si
	call    puts
        movb    %ch,%cl
        andb    $7,%cl
        addb    $8,%cl
        movl    $1,%eax
        shl     %cl,%eax
        call    prhexdword
	movw    $s_print_dram_4, %si
	call    puts
        movb    %cl,%al
        addb    $10,%al
        movb    %al,%ah
        shrb    $1,%ah
        subb    %ah,%al

	testb   $0x10,%ch
	jz      print_dram_label2
	cmpb    $9,%ah
	jng     print_dram_label2
	incb    %al
	decb    %ah
	cmpb    $12,%al
	jge     print_dram_label2
	incb    %al
	decb    %ah
print_dram_label2:	
		
	pushl   %eax
        andl    $0x0F,%eax
        call    prhexdword
	movw    $s_print_dram_5, %si
	call    puts
        popl    %eax
        movb    %ah,%al
        andl    $0x0F,%eax
        call    prhexdword
	movw    $s_print_dram_6, %si
	call    puts
        movl    $16,%eax
        testb   $8,%ch
        setnzb  %cl
        shl     %cl,%eax
        call    prhexdword
	movw    $s_print_dram_7, %si
	call    puts

	testb   $0x20,%ch                  // FPM or EDO DRAM?
	jz	print_dram_label_fpm
	movw    $s_print_dram_8, %si
	call    puts
	jmp     print_dram_label_mainloop
print_dram_label_fpm:
	movw    $s_print_dram_9, %si
	call    puts
	
print_dram_label_mainloop:		
	incw    %dx
	cmpw    $4,%dx
	jb      print_dram_label1

	// display total DRAM size and store it in the
	// variable "total_ramsize"
	movw    %bx,(total_ramsize)
        
        movw    $s_print_dram_10, %si      
        call    puts
        movw    %bx,%ax
        call    prhexdword      
        movw    $s_print_dram_11, %si
        call    puts    

	ret

	
/* ----------
   alios 'main' 
   (started in MMSA at ROMBLOAD_SEG:alios, 
    later in DRAM from RAMBLOAD_SEG:rtr) 
*/

alios:
	cli				# clear interrupt flag
	cld				# clear direction flag

	movw	%cs,%ax
	movw	%ax,%ds

	inb	$0xEE,%al		# enable propagation of A20 signal

// do initial system setup
// now flash is mapped into phys address space at 16Mb, so we can change to
// protected mode and start executing from flash
	movw	$begin_config_table,%si
	movw	$((end_config_table-begin_config_table)>>2),%cx
config_table_loop:
	movw	(%si),%dx	# move word from table into dx register
	incw	%si		# increment two bytes to data field
	incw	%si		#
	movb	(%si),%al	# move byte from table into al register
	incw	%si		# increment to next table element
	incw	%si		# increment to next table element
	outb	%al,%dx		# output contents of al to address dx
	loop	config_table_loop

/* flash LEDs 10 times */
	movw	$0x04a8,%ax
	movw	$0x000a,%cx
led_flash_loop:
#ifdef CARD_BOOT
	movw	$0x5fff,%bx	# reduce the blink delay on CARD boots
#else
	movw	$0xffff,%bx 
#endif
	
delay_loop:
	dec	%bx
	jnz	delay_loop
	movw	$0x0c00,%bx
	xorw	%bx,%ax
	outw	%ax,$0x22
	dec	%cx
	jnz	led_flash_loop
	movw	$0x00a8,%ax
	outw	%ax,$0x22

/* detect & configure the installed RAM modules */

	movb      $1, %dh              // matrix keyboard: disabled
	lea       conf_dram_rtn,%bp    // no stack, store return addr in bp
	jmp       ConfigureDRAM     
conf_dram_rtn:
        movw	%cs,%ax                // reload ds
        movw    %ax,%ds

/* move alios to RAM (to be able to use MMS A for other purposes) */

	movw	$RAMBLOAD_SEG,%ax	# to top of 1st Mbyte
	movw	%ax,%es
	subw	%si,%si
	subw	%di,%di

	movw	$(8*ALIOS_LEN),%cx	# copy 16*ALIOS_LEN byte
	rep
	movsw

	movw	%ax,%ds			# reload DS
	ljmp	$RAMBLOAD_SEG,$rtr	# reload CS

/* RAM is initialised; we are now in RAM, do final setup */
rtr:
	movw	$BOOTSETUP_SEG,%ax	# alloc stack, set TOS=0x9FFFE
	movw	%ax,%ss			# (rather arbitrary)
	movw	$0xFFFE,%ax
	movw	%ax,%sp

final_setup:

	movw	$s_hello_world,%si	# print hello message
	call	puts

	call    print_dram              # show DRAM size
	
boot_linux:

	call	load_config		# load configuration block
	call	load_info		# set kernel parameters
	call	load_images		# load kernel & ram disk image

	movw	$0x0033,%ax		# disable MMS Window A
	outw	%ax,$0x22
	movw	$0x0035,%ax		# disable MMS Window B
	outw	%ax,$0x22


#ifdef CARD_BOOT
	movw	$0x0020,%ax		# remap ROMCS0* to flash
	outw	%ax,$0x22
#endif		

	invd				# invalidate cache contents
	movl	%cr0,%eax		# enable caching
	andl	$0x9FFFFFFF,%eax	# (clear bits 29,30)
	movl	%eax,%cr0

	movw	SPEED,%ax		# Set Speed Register
	outw    %ax,$0x22

/* switch to protected mode */

	movw	$s_starting,%si		# last of our messages
	call	puts

	movl	$(16*BOOTSETUP_SEG),%esi	# real mode pointer

	lidt	idt_48			# load idt with 0,0
	lgdt	gdt_48			# load gdt with whatever appropriate

	movw	$0x0001,%ax		# PE bit
	lmsw	%ax			# This is it!

	jmp	flush_instr
flush_instr:

	xorw	%bx,%bx			# Flag to indicate a boot

/* jump to kernel startup code at 1MB */

	.byte	0x66,0xEA		# ljmp	$(__KERNEL_CS),$KERNEL_S
	.long	KERNEL_S
	.word	__KERNEL_CS		# from asm/segment.h

/* ----------
   dummy soft int dests
*/


/* ----------
   descriptor tables
*/

gdt:
	.word	0,0,0,0		# dummy

	.word	0,0,0,0		# unused

	.word	0xFFFF		# 4Gb - (0x100000*0x1000 = 4Gb)
	.word	0x0000		# base address=0
	.word	0x9A00		# code read/exec
	.word	0x00CF		# granularity=4096, 386 (+5th nibble of limit)

	.word	0xFFFF		# 4Gb - (0x100000*0x1000 = 4Gb)
	.word	0x0000		# base address=0
	.word	0x9200		# data read/write
	.word	0x00CF		# granularity=4096, 386 (+5th nibble of limit)

/* pointer to descriptor tables */

idt_48:
	.word	0		# idt limit=0
	.long	0		# idt base=0L

gdt_48:
	.word	0x800		# gdt limit=2048, 256 GDT entries
	.long	0x00100000-16*ALIOS_LEN+gdt	# gdt base = 16*cs + offset

	
/* ----------
   some subroutines to take care of debug messages
   (these are real quickn dirty hacks)
*/

prhexnibble:
        pushw   %ax
        andb    $0x0F,%al
        orb     $0x30,%al
        cmpb    $0x3A,%al
        jb      putchar_label1
        addb    $0x07,%al
        jmp     putchar_label1
putchar:
        pushw   %ax
putchar_label1:
        pushw   %dx
#ifdef RTSCTS
        pushw   %ax
        movw    $(UART_BASE+6),%dx
txwait_cts:
        inb     %dx,%al
        testb   $0x10,%al               # wait until CTS clear
        jz      txwait_cts
        popw	%ax
#endif
        movw    $(UART_BASE),%dx
        outb    %al,%dx			# send the character
        movw    $(UART_BASE+5),%dx
txwait:
        inb     %dx,%al
        testb   $0x20,%al               # wait until THRE
        jz      txwait
        popw    %dx
        popw    %ax
        ret
	
/* ----------
   "print" ASCIIZ string from ds:si
*/

puts_label1:
        call    putchar
        jmp     puts_label2
puts:
        pushw   %ax
puts_label2:
        lodsb
        orb     %al,%al
        jnz     puts_label1
        popw    %ax
        ret

#ifdef HEXPRINT

/* ----------
   "print" cr/lf sequence
*/
putcrlf:
	pushw	%ax
	movb	$0x0D,%al
	call	putchar
	movb	$0x0A,%al
	call	putchar
	popw	%ax
	ret

/* ----------
   "print" AL, hexadecimal
*/
prhexbyte:
	pushw	%cx
	pushw	%ax
	movb	$4,%cl
	shrb	%cl,%al
	call	prhexnibble
	popw	%ax
	pushw	%ax
	call	prhexnibble
	popw	%ax
	popw	%cx
	ret

/* ----------
   "print" AX, hexadecimal
*/
prhexword:
	pushw	%ax
	movb	%ah,%al			# send ah
	call	prhexbyte
	popw	%ax
	pushw	%ax			# send al
	call	prhexbyte
	popw	%ax
	ret

/*************************************************************
 * "print" EAX (dword)
 *************************************************************/
	
prhexdword:
	push    %eax
        push    %ebx
        push    %edx

        mov     $10,%ebx
        push    %bx                // End of number indicator
prhexdword_label1:
        xor     %edx,%edx
        div     %ebx
        push    %dx                // save the remainder
        or      %eax,%eax          // see if we're done yet
        jnz     prhexdword_label1  // do it again if not
        pop     %ax
prhexdword_label2:	
        call    prhexnibble
        pop     %ax                // get the next digit
        cmp     %bl,%al            // compare with end-of-number
        jb      prhexdword_label2
        pop     %edx
        pop     %ebx
        pop     %eax
        ret
	
#endif // def(HEXPRINT)

	
/* ----------
   helper for load: extract bits from 32 bit address for MMSA/MMSB setup
*/

mmswinsetup:
	movl	%cs:(%si),%eax		# get phys address in memory
	movl	%eax,%ebx		# save current value in ebx
	addl	$512,%eax		# add 'sector' size
	movl	%eax,%cs:(%si)		# store value for next run

	cmpl	$0x400000,%ebx		# above 4Mb? (top of ram)
	jl	no_wrap
	subl	$0x360000,%ebx		# wrap down to 640k
no_wrap:

	movw	%bx,%si			# extract bits 14..0 into si
	andw	$0x7FFF,%si
	andl	$0xFFFF8000,%ebx	# bits 31 - 15 (for CSC 0x32/0x33)
	movb	$15,%cl
	shrl	%cl,%ebx		# bh gets bits 25-23, bl gets 22-15

	movb	%dh,%al			# put bits 22-15 to CSC index (DH)
	movb	%bl,%ah
	outw	%ax,$0x22

	movb	%dl,%al			# put bits 25-23 to CSC index (DL)
	movb	%bh,%ah
	andb	$0x07,%ah
	orb	%ch,%ah			# point to ? and enable
	outw	%ax,$0x22

	ret

/* ----------
   copy data chunks

     load_sector copies CX * 512 bytes   ("sectors")
            from ROMCS0 DS:(currentSrc)  (stored there as linear address)
              to DRAM   DS:(currentDst)  (stored there as linear address) 
*/

currentSrc:	.long	0		# source address in flash/on pc card
currentDst:	.long	0		# destination address in RAM

/* ----------
   load the kernel image from flash into ram
*/

load_images:
	movw	$s_loadkernel,%si
	call	puts

	movw	$BOOTSETUP_SEG,%ax
	movw	%ax,%es

	movw	%es:(SYSSIZE),%ax	# how many paragraphs (16b) for kernel?
	addw	$31,%ax			# calc ceil(ax/(512/16))
	movb	$5,%cl
	shrw	%cl,%ax			# no of sectors for kernel
	movw	%ax,%cx

	/* currentSrc at this time points just behind setup sectors] */
	movl	$KERNEL_S,(currentDst)

	
load_sector:
	pushw	%ax
	pushw	%bx
	pushw	%si
	pushw	%di
	pushw	%ds
	pushw	%es

	movw	$MMSA_SEG,%ax		# itll appear in MMS Window A
	movw	%ax,%ds
	movw	$(MMSB_SEG-0x800),%ax	# and go to MMS Window B in HMA
	movw	%ax,%es

	orw	%cx,%cx
	jz	ls_early_exit

load_sector_loop:
	pushw	%cx

	testb	$0x7F,%cl		# emit ASCII '.' (dot) 
	jnz	lsl_nodot		# as progress indicator
	movb	$'.',%al
	call	putchar
lsl_nodot:

/* point MMS Window B to destination (DRAM) */

	movw	$currentDst,%si
	movb	$0xC8,%ch		# point to DRAM and enable
	movw	$0x3435,%dx		# CSC indices for MMS B
	call	mmswinsetup		# returns si=access pointer

	movw	%si,%di			# used as destination (es:di)
	orw	$0x8000,%di		# compensate -0x800 in ES setup

/* point MMS Window A to source location (ROMCS0, may be PC CARD A) */

	movw	$currentSrc,%si
	movb	$0x08,%ch		# point to ROMCS0 and enable
	movw	$0x3233,%dx		# CSC indices for MMS A

	call	mmswinsetup		# returns si=access pointer

/* copy data from 0xBxxxx (MMSA) to 0x10xxxx (MMSB) */

	movw	$256,%cx		# copy 512 bytes
	rep	
	movsw

	popw	%cx
	loop	load_sector_loop

ls_early_exit:
	popw	%es
	popw	%ds
	popw	%di
	popw	%si
	popw	%bx
	popw	%ax

	ret

/* ----------
  initialise the values later read by the kernel (vga, ram size, etc)
  [uses some data from bootsect/setup found in front of the kernel bzImage]
*/


load_config:
	movw $s_load_conf, %si
	call puts

	movw $BOOTSETUP_SEG, %ax
	movw %ax, %es

	movl	$CONFIG_1_S,(currentSrc)	# try 1st
	movl	$CONFBUF_LOC,(currentDst)
	movw	$1,%cx
	call	load_sector

	mov	$0x31, %al
	call	putchar

	movw	$s_loaded_cmdline, %si		# show command line
	call	puts
	pushw	%ds
	pushw	%es
	popw	%ds
	movw	$VAR_COMMANDLINE, %si
	call	puts
	popw	%ds
	call	putcrlf
	ret

/* located within bootsect space (copied from arch/i386/setup.c) */
/* originally defined mostly in arch/i386/kernel/setup.c and head.S */

PARAM		=	0
SCREEN_INFO	=	PARAM+0
EXT_MEM_K	=	PARAM+2
CL_MAGIC	=	PARAM+0x20
CL_OFFSET	=	PARAM+0x22
ALT_MEM_K	=	PARAM+0x01e0
APM_BIOS_INFO	=	PARAM+0x0040
DRIVE_INFO	=	PARAM+0x0080
SYS_DESC_TABLE	=	PARAM+0x00A0
SETUP_SECTS	=	PARAM+0x01F1
MOUNT_ROOT_RDO	=	PARAM+0x01F2
SYSSIZE		=	PARAM+0x01F4
RAMDISK_FLAGS	=	PARAM+0x01F8
ORIG_ROOT_DEV	=	PARAM+0x01FC
AUX_DEVICE_INFO	=	PARAM+0x01FF

/* located within and following the setup space: */

LOADER_TYPE	=	PARAM+0x0210
LOAD_FLAGS	=	PARAM+0x0211
KERNEL_START	=	PARAM+0x0214
INITRD_START	=	PARAM+0x0218
INITRD_SIZE	=	PARAM+0x021C
COMMAND_LINE	=	PARAM+0x0800

/* load bootsect.o (first 512 bytes of kernel image) */

load_info:
	movw	$s_loadbootsect,%si
	call	puts

	mov	%es:(VAR_KERNELIMG_S),%eax
	
	movl	%eax,(currentSrc)
	movl	$(16*BOOTSETUP_SEG),(currentDst)

	movw	$1,%cx			# load only one sector,
	call	load_sector		# the boot sector (512 bytes)

/* load setup.o (length of setup is taken from bootsect) */

	movw	$s_loadsetup,%si
	call	puts

	movw	$BOOTSETUP_SEG,%ax
	movw	%ax,%es

	xorb	%ch,%ch
	movb	%es:(SETUP_SECTS),%cl	# read # of sectors for setup.o
	call	load_sector		# load setup code

/* write some updated information into setup header (e.g command line) */

	movw	$s_patchsetup,%si
	call	puts

	pushw	%ds
	pushw	%es			# BOOTSETUP_SEG
	popw	%ds

	movb	$1,LOADER_TYPE		# must be != 0
#if KERNEL_S >= 0x100000
	movb	$1,LOAD_FLAGS		# kernel is loaded high, above 1MB
#else
	movb	$0,LOAD_FLAGS		# kernel is loaded in low 640k
#endif
	movw	$0,RAMDISK_FLAGS

	movl	$0,ALT_MEM_K
	movw	$0xA33F,CL_MAGIC
	movw	$COMMAND_LINE,CL_OFFSET
	movb	$0,AUX_DEVICE_INFO
	movl	$KERNEL_S,KERNEL_START

	// set EXT_MEM_K
	xorl    %eax,%eax
	pushw   %ds                     
        movw    $RAMBLOAD_SEG,%ax
        movw    %ax,%ds
        movw    (total_ramsize),%ax
	addw    $384,%ax	# add 384k (we remapped the 384k between 640k and 1M to the end of ram)
        popw    %ds
        subw    $1024,%ax
        movw    %ax,EXT_MEM_K

	// calculate the RAM size in bytes and store it in %ebx
	addw	$1024,%ax
        movb    $10,%cl
        shll    %cl,%eax
        movl    %eax,%ebx

	
/* copy command line contents from config buffer */

	movw	$VAR_COMMANDLINE,%si
	movw	$COMMAND_LINE,%di
	movw	$127,%cx	# max cmdline length: 256 (see setup.c)
	rep			# copy 127x2 bytes
	movsw
	movsb			# plus 1 byte
	xorb	%al,%al
	stosb			# plus forced trailing zero

	movw	$APM_BIOS_INFO,%di		# clear extra info structs
	movw	$((0x100-APM_BIOS_INFO)>>1),%cx	# at 0x9000:0x0040..0x00FF
	xorw	%ax,%ax
	rep	
	stosw

	popw	%ds
	ret



#### ASCII strings:
		
s_print_dram_0:
	.byte   13,10
	.asciz  "- Bank "
s_print_dram_1:
	.asciz  ": "
s_print_dram_2:	
	.asciz  "no DRAM detected"
s_print_dram_3:
	.asciz  "K organized as "
s_print_dram_4:
	.asciz  "K ("
s_print_dram_5:
        .asciz " rows by "
s_print_dram_6:
        .asciz " columns) by "
s_print_dram_7:
        .asciz " bits, "
s_print_dram_8:
        .asciz "EDO"
s_print_dram_9:
        .asciz "FPM"
s_print_dram_10:
        .byte   13,10
        .asciz "- Total DRAM detected: "
s_print_dram_11:
        .asciz " kbytes"
s_loadkernel:
	.byte	13,10
	.asciz	"- copying compressed kernel into RAM"


/* loader messages */

s_hello_world:
	.byte	13,10,13,10
	.ascii	"alios biosless Linux bootloader V2"
	.byte	13,10,0
s_starting:
	.byte	13,10
	.ascii	"- starting kernel"
	.byte	13,10,10,0

s_load_conf:
	.byte	13,10
	.asciz	"- loading configuration "
s_load_conf_err:
	.byte	13,10
	.asciz	"- ERROR: invalid configuration "
s_loaded_cmdline:
	.byte	13,10
	.asciz	"- kernel args: "

s_loadbootsect:
	.byte	13,10
	.asciz	"- scanning bootsect.o"
s_loadsetup:
	.byte	13,10
	.asciz	"- scanning setup.o"
s_patchsetup:
	.byte	13,10
	.asciz	"- updating setup values"


/* fillup to 16 last bytes */

.org 16*(ALIOS_LEN-1),0xFF

/* ----------
   These are the last 16 bytes of the flash; the reset code.
   This code must later be exactly located at sizeof(FLASHMEM)-16 !
*/

start:			
	movw	$0xFF32,%ax		# set bits 22-15 of MMS A ptr
	outw	%ax,$0x22
	movw	$0x2F33,%ax		# set bits 25-23, enable MMS A,
	outw	%ax,$0x22		# point MMS A to ROMCS0/PCCARDA
	ljmp	$ROMBLOAD_SEG,$alios	# jump far to there

.org 16*ALIOS_LEN,0xFF			# fillup to end

# vim:ts=8:


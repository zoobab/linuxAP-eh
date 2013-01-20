/**************************************************************
 *  BIOSDRAM.ASM
 *
 *    This file contains code which determines the type and 
 *    size of DRAM on the Elan SC400 evaluation board.
 ***************************************************************/


/******************************************************************************
 *                                                                            *
 * Copyright 1996 Advanced Micro Devices, Inc.                                *
 *                                                                            *
 * This software is the property of Advanced Micro Devices, Inc  (AMD)  which *
 * specifically  grants the user the right to modify, use and distribute this *
 * software provided this notice is not removed or altered.  All other rights *
 * are reserved by AMD.                                                       *
 *                                                                            *
 * AMD MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, WITH REGARD TO THIS *
 * SOFTWARE.  IN NO EVENT SHALL AMD BE LIABLE FOR INCIDENTAL OR CONSEQUENTIAL *
 * DAMAGES IN CONNECTION WITH OR ARISING FROM THE FURNISHING, PERFORMANCE, OR *
 * USE OF THIS SOFTWARE.                                                      *
 *                                                                            *
 * So that all may benefit from your experience, please report  any  problems *
 * or suggestions about this software back to AMD.  Please include your name, *
 * company,  telephone number,  AMD product requiring support and question or *
 * problem encountered.                                                       *
 *                                                                            *
 * Advanced Micro Devices, Inc.       Worldwide support and contact           *
 * Logic Products Division            information available at:               *
 * Systems Engineering                                                        *
 * 5204 E. Ben White Blvd.     http://www.amd.com/html/support/techsup.html   *
 * Austin, TX 78741                                                           *
 ******************************************************************************/

/******************************************************************************
 *                                                                            *
 * Copyright 2001 telos EDV Systementwicklung GmbH, Hamburg                   *
 *                                                                            *
 * $Id: detect_dram.S,v 1.2 2003/09/29 21:52:20 xscript Exp $
 *                                                                            *
 * modified for GNU assembler                                                 *
 *                                                                            *
 ******************************************************************************/
	
/**************************************************************
 * ColTest and RowTest tables
 *
 *  The Elan SC400 has a very flexible DRAM architecture,
 *  supporting up to 4 banks of X16 or X32 DRAMs.  In order
 *  to reduce address line multiplexing, the mapping of the
 *  system address lines to the DRAM MA lines is not always
 *  straightforward.  To determine the size, the algorithm
 *  programs the Elan for maximum "reach" on the address lines
 *  (16Mbits symmetrical for col, 16MBits asymmetrical for row).
 *
 *  To support these tests, the ColTest and RowTest tables
 *  determine the number of active column and row lines based
 *  on a system address line.
 ***************************************************************/
	
ColTest:
        .byte       8,0         // If A8 wraps, it is an error
        .byte       9,8         // If A9 wraps, there are 8 columns
        .byte      10,9         // If A10 wraps, there are 9 columns
        .byte      11,10        // If A11 wraps, there are 10 columns
        .byte      12,11        // If A12 wraps, there are 11 columns
	.byte       0,12        // If A12 didn't wrap, there are 12 columns

RowTest:
        .byte      22,0         // If A22 wraps, it is an error
        .byte      13,9         // If A13 wraps, there are 9 rows
        .byte      24,10        // If A24 wraps, there are 10 rows
        .byte      23,11        // If A23 wraps, there are 11 rows
        .byte      12,12        // If A12 wraps, there are 12 rows
        .byte       0,13        // If A12 didn't wrap, there are 13 rows

/**************************************************************
 * SizeInfo table
 *
 * Once we know the number of rows and columns, we must
 * match them to a known DRAM size if possible.  The
 * SizeInfo table does this for us.
 *
 * The SizeInfo table is in descending column major order,
 * to make it easier to search for the right size.  First we
 * look for a matching column, then we look for a matching row.
 *
 * Each entry contains the column, the row, and the value to
 * program in the Elan register for that bank on a match.
 ***************************************************************/

SizeInfo:	
     .byte    12,12,  6+ 0       // 16M   S
     .byte    11,13,  6+ 0x10    // 16M   A
     .byte    11,12,  5+ 0       //  8M   A
     .byte    11,11,  4+ 0       //  4M   S
     .byte    10,13,  5+ 0x10    //  8M   A
     .byte    10,12,  4+ 0x10    //  4M   A
     .byte    10,11,  3+ 0       //  2M   A
     .byte    10,10,  2+ 0       //  1M   S
     .byte     9,12,  3+ 0x10    //  2M   A
     .byte     9,10,  1+ 0x10    //  512K A
     .byte     9, 9,  0+ 0       //  256K S
     .byte     8,12,  2+ 0x10    //  1M   A
     .byte    -1,-1              //  Sentinel (<0 for both row and col)

/**************************************************************
 * MapData PROC NEAR
 *
 * Passed:
 *    Absolute physical DRAM address in EDI
 *
 * Returns:
 *    Real mode pointer to address in DS:EDI
 *
 * Destroys:
 *    EAX, EDI, DS, flags
 *
 * MapData uses the SC400's MMS B window in
 * order to develop a pointer to anywhere in
 * system memory from real mode.  It might
 * be simpler to use big real mode, but this
 *  works just fine for now
 ***************************************************************/

MapData:	
        movw    $0x8240,%ax     # Low Speed
        outw    %ax,$0x22
        movw    $0x0FFFF,%ax       // MMS B window starts at 1MB
        movw    %ax,%ds
        shldl   $(17+8),%edi,%eax  // bit 15 to AH  bit 0  fixme

        movb    $0x34,%al
        outw    %ax,$0x22
	
        shldl   $17,%edi,%eax     // bit 23 to AH  bit 0 fixme
        andw    $0x700,%ax        // Get upper 3 address bits
        orw     $0x0C835,%ax      // Enable, + Map to DRAM
        outw    %ax,$0x22

        movb    %dl,%al           // Set index to point to our bank information
        outb    %al,$0x22

        andl    $0x7FFF,%edi
        addw    $0x10,%di         // Offset to match FFFF segment
        jmp     *%bp              // FakeRet
//MapData ENDP


/**************************************************************
 * NumBits PROC NEAR
 *
 * Passed:
 *    BX = Pointer to RowTest or ColTest
 *
 * Returns:
 *    CH = Number of rows or columns
 *    (0 on error)
 *
 * Destroys:
 *    EAX, BX, CX, EDI, EBP, flags
 *
 * NumBits works its way through the
 * passed table, checking for address wrap
 * on the given address line.  It returns
 * the associated number of rows/columns
 * when wrap is found.
 ***************************************************************/
	
NumBits:	
        rol     $16,%ebp       // Save return address

NumBitsLoop:  

// Get table entry and bump to next one

        movw     %cs:(%bx),%cx
        incw     %bx
        incw     %bx

// If the address line is 0, it means that we have gotten to
// the end of the table successfully (must have a large DRAM).

        orb     %cl,%cl
        jz      NumBitsExit

// Store a value to test against in DRAM address 0

        xorl      %edi,%edi
	lea       fake_call_1,%bp   // fake call
	jmp       MapData           // fake call
fake_call_1:                        // fake call
        orl       $-1,%ds:(%di)

// Generate the new address based on the line from the table,
// and store a different value in it.

        xorl     %edi,%edi         // '1' to EDI
        incl     %edi
        shl      %cl,%edi
	lea      fake_call_2,%bp   // fake call
	jmp      MapData           // fake call
fake_call_2:                       // fake call
        andl     $0,%ds:(%di)

// Go back to 0 and make sure that it is still the original value.
// We are done if not.  (If there were no DRAM there, we would return
// a 0 at this point, because the first table entry has a 0 here.)

        xorl     %edi,%edi
	lea      fake_call_3,%bp   // fake call
	jmp      MapData           // fake call
fake_call_3:                       // fake call
        cmpl     $-1,%ds:(%di)
        jnz      NumBitsExit

// We appear to have more DRAM than this.  Let's check to make sure
// that we can read and write the location.  Return 0 for error if not.

        movb    $0,%ch            // Error code in case we return
        xorl    %edi,%edi         // '1' to EDI
        incl    %edi
        shl     %cl,%edi
	lea     fake_call_4,%bp   // fake call
	jmp     MapData           // fake call
fake_call_4:                      // fake call

        cmp     $0,%ds:(%di)
        jnz     NumBitsExit

        orl     $-1,%ds:(%di)
        cmpl    $-1,%ds:(%di)
        jz      NumBitsLoop

NumBitsExit:
        rol     $16,%ebp       // Get return address back
        jmp     *%bp           // FakeRet
//NumBits ENDP

/**************************************************************
 * ConfigureDRAM PROC NEAR PUBLIC
 *
 * Passed:
 *  - DH = Test code:
 *        0 = Matrix keyboard disabled
 *        1 = Matrix keyboard enabled
 *        2 = Matrix keyboard state unknown
 *
 * (Do NOT pass 2 to this routine in a production environment.
 * If there is a DRAM failure, it could make it hard to diagnose.
 * See NOTE in the code below.)
 *
 *  - Assumes A20 is enabled.
 *
 * Returns:
 *  - All banks which appear to have DRAM enabled and set up appropriately.
 *  - MMS B enabled
 *  - Bank 3 may be enabled at an illegal size (256K deep, asym), to
 *    insure that DRAM controller "owns" shared matrix keyboard signals.
 *
 * Destroys:
 *   - EAX, EBX, CX, DX, SI, EDI, EBP, flags, DS, ES
 *
 * ConfigureDRAM checks out the DRAM banks one
 * by one to determine the size and attributes
 * of each bank.
 *
 * Internal register usage:
 *     DL - bank number
 * 
 ***************************************************************/
	
ConfigureDRAM:	
        mov     %bp,%es    // Save return address fixme

// Disable refresh by writing a 0 to index register 5

        movw    $0x0005,%ax
        outw    %ax,$0x22

// Wait for 3 transitions of 32kHz clock to insure that the
// final refresh is flushed out

        movw    $3,%cx
        movb    $0x82,%al
        outb    %al,$0x22
        inb     $0x23,%al
        movb    %al,%ah
telos_label1:
        inb     $0x23,%al
        xorb    %ah,%al
        andb    $8,%al
        jz      telos_label1
        loop    telos_label1

// Enable bank 3 unless the matrix keyboard is enabled.  Disable the
// other banks _after_ enabling bank 3 (to avoid glitches on warm boot).
// Store 1 in DL if matrix keyboard is enabled, 3 if not
        
        movw    $0x0A603,%ax     // Assume we're enabling bank 3
        movb    $3,%dl
	cmpb    $1,%dh
        jnz     telos_label2
        movb    $0,%ah
        movb    $1,%dl
telos_label2:
        outw    %ax,$0x22
        movb    $0,%ah
        decw    %ax
        jns     telos_label2

// If the matrix keyboard is enabled, BankLoop will execute for banks
// 0 and 1.  Otherwise, it will execute for all the banks, starting with 3

BankLoop:

// Check for existence/ EDO/FPM determination

        xorl     %edi,%edi        // Get a pointer to DRAM address 0
	lea      fake_call_5,%bp  // fake call
	jmp      MapData          // fake call
fake_call_5:                      // fake call

        movb    $0x86,%al         // Enable current bank at 16MBits X 16
        outb    %al,$0x23

        movw    $0x1005,%ax       // disable RAS timeout
        outw    %ax,$0x22

        movl    $0x55AA55AA,%ds:(%di)     // Store arbitrary data
        movl    %ds:(%di),%eax    // Read back to latch EDO DRAM outputs

        movw    $0x0DC04,%ax      // set EDO detect
        outw    %ax,$0x22

        movl    %ds:(%di),%ebx    // Will be good data if EDO

        movw    $0x05C04,%ax      // reset EDO detect
        outw    %ax,$0x22

        movw    $0x0005,%ax       // reenable RAS timeout
        outw    %ax,$0x22

        movb    %dl,%al           // Set index register to point to bank
        outb    %al,$0x22

        movl    %ds:(%di),%eax

        cmpl    $0x55AA55AA,%eax
        jnz     BadBank

// We have DRAM.  Set EDO bit if appropriate

        cmpl    %ebx,%eax
        jnz     telos_label3
        movb    $0x0A6,%al
        outb    %al,$0x23
telos_label3:

// Figure out how many columns we have (save in second byte of SI)

        movw     $ColTest,%bx
	lea      fake_call_6,%bp  // fake call
	jmp      NumBits          // fake call
fake_call_6:                      // fake call
        movw     %cx,%si

// Reconfigure for asymmetrical mode to get maximum row reach

        inb      $0x23,%al
        orb      $0x10,%al
        outb     %al,$0x23

// Figure out how many rows we have

        movw     $RowTest,%bx
	lea      fake_call_7,%bp  // fake call
	jmp      NumBits          // fake call
fake_call_7:                      // fake call

// Calculate size and symmetry from columns and rows by looping
// through the SizeInfo table until we have a match or run
// into a sentinel.

        movw    %si,%ax                   // Columns to CL
        movb    %ah,%cl                   // (Rows already in CH)
        movw    $SizeInfo,%bx
telos_label4:
        movw    %cs:(%bx),%ax
        addw    $3,%bx
        cmpb    %cl,%al
        jg      telos_label4
        cmpb    %ch,%ah
        jg      telos_label4

// Make sure we have a match on the row and column

        cmpw    %cx,%ax
        jnz     BadBank

// Bank size information to AL

        inb     $0x23,%al
        andb    $0x0E0,%al
        orb     %cs:-1(%bx),%al    // Get size information from table

// If matrix keyboard is enabled, the bank CANNOT be 32 bits, so we are done

        cmpb    $1,%dh            // 32 bits allowed?
        jz      SetBankFromAL

// Matrix keyboard disabled.  Check bank for 32 bit width.

        orb     $8,%al            // set width to 32 bits
        outb    %al,$0x23

        xorl    %edi,%edi
	lea     fake_call_8,%bp   // fake call
	jmp     MapData           // fake call
fake_call_8:                      // fake call

        inb     $0x23,%al
        andb    $0xF7,%al   // AL contains code to set width back to 16 bits

        movl    $0x05A5AA5A5,%ebx
        movl    %ebx,%ds:0(%di)
        notl    %ebx
        movl    %ebx,%ds:4(%di)

        notl    %ebx
        cmpl    %ds:0(%di),%ebx
        jnz     SetBankFromAL
        notl    %ebx
        cmpl    %ds:4(%di),%ebx
        jnz     SetBankFromAL
        jmp     NextBank

BadBank:
        movb    $0,%al
        cmpb    $3,%dl
        jnz     SetBankFromAL
        movb    $0x0B0,%al          // Enabled, illegal value
SetBankFromAL:
        outb    %al,$0x23

NextBank:
        decb    %dl
        jns     BankLoop

// Reenable DRAM refresh by writing 40h to index register 5

        movw    $0x4005,%ax
        outw    %ax,$0x22

        mov     %es,%bp          // Get return address back fixme
        jmp     *%bp             // FakeRet
//ConfigureDRAM ENDP


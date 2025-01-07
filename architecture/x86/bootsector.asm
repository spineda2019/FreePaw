.code16
.intel_syntax noprefix
.text
.org 0x0
.global main

LOAD_SEGMENT = 0x1000    # Location of 2nd stage bootloader

# First 3 bytes allocated for jumping
main:
    jmp start

# Bytes 4-62 stores deviceinfo
bootsector:                             # Store information about the floppy boot device
    iOEM:          .ascii "osOS/BOS"    # OEM String
    iSectSize:     .word  0x200         # bytes per sector
    iClustSize:    .byte  1             # sectors per cluster
    iResSect:      .word  1             # #of reserved sectors
    iFatCnt:       .byte  2             # #of FAT copies
    iRootSize:     .word  224           # size of root directory
    iTotalSect:    .word  2880          # total # of sectors if over 32 MB
    iMedia:        .byte  0xF0          # media Descriptor
    iFatSize:      .word  9             # size of each FAT
    iTrackSect:    .word  9             # sectors per track
    iHeadCnt:      .word  2             # number of read-write heads
    iHiddenSect:   .int   0             # number of hidden sectors
    iSect32:       .int   0             # # sectors for over 32 MB
    iBootDrive:    .byte  0             # holds drive that the boot sector came from
    iReserved:     .byte  0             # reserved, empty
    iBootSign:     .byte  0x29          # extended boot sector signature
    iVolID:        .ascii "seri"        # disk serial
    acVolumeLabel: .ascii "MYVOLUME   " # volume label
    acFSType:      .ascii "FAT16   "    # file system type

# Everything else (must be smaller than 512 bytes) can be our code

usefulconstants:
    diskerror: .asciz "(FreePaw) Disk ERROR.\r\n"
    rebootmsg: .asciz "(FreePaw) Press any key to reboot\r\n"
    loadmsg:   .asciz "Loading FreePaw...\r\n"

# To use logical block adressing (LBA) the following conversions will be needed
# Sector   = (LBA mod SectorsPerTrack) + 1
# Cylinder = (LBA / SectorsPerTrack) / NumHeads
# Head     = (LBA / SectorsPerTrack) mod NumHeads

# In the routine, the following registers will hold the following info:
# AX: Logical block
# CX: Try count (3 try max)
# BX: Data buffer offset
# Do NOT clobber these registers (except setting CX to 0)
ReadSector:
    xor cx, cx                          # Accumulator (CX) will be try count

    push ax                             # Save registers to avoid clobbering
    push bx
    push cx

    # Disk - Read Sector(s) Into Memory - int 0x13 subfunction 0x2
    # AH: 0x2 (Subfunction 2)
    # AL: Number of sectors to read (must be non zero)
    # CH: Low eight bits of cylinder number
    # CL (bits 0-5): Sector number 1-63
    # CL (bits 6-7): High two bits of cylinder (Hard disk only)
    # DH: Head number
    # DL: Drive number (bit 7 is set if this is a harddisk)
    # ES:BX -> Data Buffer
    .readsector
    # Calculate Sector Number
    mov bx, iTrackSect                  # Save sectors/track in bx
    xor dx, dx                          # DX:AX is divisor (DIVISOR/NUMERATOR)

    div bx                              # performs (DX:AX)/BX
                                        # Quotient in AX, remainder in DX
                                        # Performs (LogicalBlock/SectorsPerTrack)

    inc dx                              # Add 1 to LBA mod Sectors per track
                                        # DX is now sector number

    mov cl, dl                          # setup sector num in CL for interrupt

    # Calculate Cylinder Number
    mov bx, iHeadCnt
    xor dx, dx
    div bx                              # Performs (LogicalBlock/NumberOfHeads)
    ret

Reboot:
    lea si, rebootmsg
    call WriteString

    # Keyboard - Get Keystroke: int 0x16 subfunc 0
    # AH: 0
    # Returns:
    # AH: BIOS Scan Code
    # AL: ASCII Char
    .waitforkey:
    xor ax, ax
    int 0x16

    .reboot:
    .byte 0xEA           # machine language to jump to FFFF:0000 (reboots)
    .word 0x0000
    .word 0xFFFF

# DS:SI should contain string
WriteString:
    lodsb                # Special x86 instruction to load DS:SI to AL
    or al, al            # Only 0 at end of string
    jz .WriteStringDone  

    # Teletype video output: int 0x10 subfunc 0xe
    # AH: 0xe
    # AL: Character to print
    # BH: Page Number
    # BL: Foreground color
    .printchar:
    mov ah, 0xe          # subfunction 0xe is the print subfunc
    mov BH, 0            # pagenum 0
    mov BL, 9            # 9 is white 
    int 0x10             # Interupt to give control to BIOS
    jmp WriteString      # Continue untill end of string

    .WriteStringDone:
    ret


start:
    .setup:
    cli                  # Disable interrupts
    mov iBootDrive, dl   # Save Drive we booted from
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00       # Setup top of stack. Grows down in x86
    lea si, loadmsg
    .resetdisk:
    mov dl, iBootDrive   # dl stores the drive we want to reset
    xor ax, ax           # ax stores the subfunction to use; Subfunc 0 is reset
    int 0x13             # BIOS interrupt 0x13 subfunction 0 is disk reset
    jc .bootfail         # jc set on disk reset fail
    .printandwait:
    call WriteString
    .bootfail:
    lea si, diskerror
    call WriteString
    call Reboot
    sti                  # Re-enable interrupts

.fill (510-(.-main)), 1, 0
# bootmagic: .int 0xaa55   # Make this bootable

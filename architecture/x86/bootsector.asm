.code16
.intel_syntax noprefix
.text
.org 0x0

LOAD_SEGMENT = 0x1000    # Location of 2nd stage bootloader

.global main
main:
    jmp start

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

usefulconstants:
    diskerror: .asciz "Disk ERROR. "

bootsector:              # Store information about the floppy boot device
    iBootDrive: .byte 0  # holds drive that boot sector came from

start:
    .setup:
    cli                  # Disable interrupts
    mov iBootDrive, dl   # Save Drive we booted from
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00       # Setup top of stack. Grows down in x86
    .resetdisk:
    mov dl, iBootDrive   # dl stores the drive we want to reset
    xor ax, ax           # ax stores the subfunction to use; Subfunc 0 is reset
    int 0x13             # BIOS interrupt 0x13 subfunction 0 is disk reset
    .printandwait:
    call WriteString
    .bootfail:
    lea si, diskerror
    sti                  # Re-enable interrupts

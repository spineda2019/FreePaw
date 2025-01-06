.code16
.intel_syntax noprefix
.text
.org 0x0

LOAD_SEGMENT = 0x1000    # Location of 2nd stage bootloader

.global main
main:
    jmp start

WriteString:
    .WriteStringDone:
    ret

bootsector:              # Store information about the floppy boot device
    iBootDrive: .byte 0  # holds drive that boot sector came from

start:
    cli                  # Disable interrupts
    mov iBootDrive, dl   # Save Drive we booted from
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00       # Setup top of stack. Grows down in x86
    call WriteString
    sti                  # Re-enable interrupts

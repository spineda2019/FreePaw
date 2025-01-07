ENTRY(main)
OUTPUT_FORMAT("binary")

SECTIONS {
    . = 0x00007c00;        /* Load code at exactly addr 0x7c00 */
    . = ALIGN(512);

    .text :
    {
        *(.text)           /* All text sections from all files */
    }

    .sig : 
    {
        SHORT(0xAA55)      /* Append AA55 to end to make device bootable */
    }

    /DISCARD/ : {
        *(.note.gnu.property)
        *(.data)
        *(.bss)
    }
}

# Create flat binary
as architecture/x86/bootsector.asm -o boot.o
ld boot.o -o boot.bin -T architecture/x86/link.ld

# Create floppy
bximage -q -fd -size 1440 FreePaw.img

dd if=boot.bin of=FreePaw.img bs=512 count=1

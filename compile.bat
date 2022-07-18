
nasm boot/boot.asm -o ready/boot.bin

pause

qemu-system-x86_64 ready/boot.bin
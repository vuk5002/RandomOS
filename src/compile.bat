nasm main.asm -o boot.bin
nasm krn.asm -o krn.bin

copy /b boot.bin+krn.bin os.bin
pause

qemu-system-x86_64 -fda os.bin -display sdl
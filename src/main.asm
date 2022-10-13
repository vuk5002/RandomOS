[org 0x7c00]
PROGRAM_SPACE equ 0x7e00

mov [BOOT_DISK], dl

mov bp, 0x7c00
mov sp, bp 

call ReadDisk

jmp PROGRAM_SPACE

jmp $

ReadDisk:

    mov ah, 0x02
    mov bx, PROGRAM_SPACE
    mov al, 64 ; 64 sectors
    mov dl, [BOOT_DISK]
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02


    int 0x13


    ret

BOOT_DISK:
    db 0

times 510-($-$$) db 0
dw 0xaa55

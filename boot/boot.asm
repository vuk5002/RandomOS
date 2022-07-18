org 0x7c00
; Main bootloader
; loads FIRST 512 bytes (510 + padding)
; Hidden Studios (c) 2020-2022 All Rights Reserved.

mov si, string
call print

print:
    mov ah, 0x0e
    mov bh, 0x00
    .loop:
        lodsb
        cmp al, 0x00
        je .exit
        int 0x10
        jmp .loop
  .exit:
       ret

string: db "Welcome to RandomOS!", 0

; boot signature
times 510-($-$$) db 0
dw 0xaa55
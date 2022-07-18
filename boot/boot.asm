; Main bootloader
; loads FIRST 512 bytes (510 + padding)
; Hidden Studios (c) 2020-2022 All Rights Reserved.

mov ah, 0x0e
mov al, 'H'

int 0x10

; boot signature
times 510-($-$$) db 0
dw 0xaa55
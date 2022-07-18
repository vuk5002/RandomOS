; Main bootloader
; loads FIRST 512 bytes (510 + padding)
; Hidden Studios (c) 2020-2022 All Rights Reserved.



; boot signature
times 510-($-$$) db 0
dw 0xaa55
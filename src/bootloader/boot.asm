; RandomOS
; Ver 0.0.5v
; NEW: Kernel, Read the disk

org 0x7C00
bits 16


%define ENDL 0x0D, 0x0A

; **************

jmp short start
nop

bdb_oem:                        db 'MSWIN4.1'
bdb_bytes_per_sector:           dw 512
bdb_sectors_per_cluster:        db 1
bdb_reserved_sectors:           dw 1
bdb_fat_count:                  db 2
bdb_dir_entries_count:          dw 0E0h
bdb_total_sectors:              dw 2880
bdb_media_descriptor_type:      db 0F0h
bdb_sectors_per_fat:            dw 9
bdb_sectors_per_track:          dw 18
bdb_heads:                      dw 2
bdb_hidden_sectors:             dd 0
bdb_large_sector_count:         dd 0

; extended boot rectord
ebr_drive_number:               db 0
                                db 0
ebr_signature:                  db 29h
ebr_volume_id:                  db 12h, 34h, 56h, 78h
ebr_volume_label:               db 'RANDOM OS  '
ebr_system_id:                  db 'FAT12   ' 

; **************

start:
    jmp main


;
; Prints a string to the screen
; Params:
;   - ds:si points to string
;
puts:
    ; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si    
    ret
    

main:
    ; setup data segments
    mov ax, 0           ; can't set ds/es directly
    mov ds, ax
    mov es, ax
    
    ; setup stack
    mov ss, ax
    mov sp, 0x7C00      ; stack grows downwards from where we are loaded in memory

    ; read something from floppy
    ; BIOS should set DL to drive number
    mov [ebr_drive_number], dl

    mov ax, 1
    mov cl, 1
    mov bx, 0x7E00
    call disk_read

    ; print hello world message
    mov si, msg_hello
    call puts

    hlt

.halt:
    jmp .halt



; 
; disk routines
;

;
; converts an LBA adress to a CHS adress
; params:
;   - ax: LBA adress
; returns:
;   - cx [bits 0-5]: sector number
;   - cx [bits 6-15]: cylinder
;   - dh: head

lba_to_chs:

    push ax
    push dx

    xor dx, dx
    div word [bdb_sectors_per_track]

    inc dx
    mov cx, dx

    xor dx, dx
    div word [bdb_heads]

    mov dh, dl
    mov ch, al
    shl ah, 6
    or cl, ah

    pop ax
    mov al, al
    pop ax
    ret


;
; Reads sectors from a disk
; Parameters:
;   - ax: LBA address
;   - cl: number of sectors to read (up to 128)
;   - dl: drive number
;   - es:bx: memory address where to store read data
;
disk_read:

    push ax                             ; save registers we will modify
    push bx
    push cx
    push dx
    push di

    push cx                             ; temporarily save CL (number of sectors to read)
    call lba_to_chs                     ; compute CHS
    pop ax                              ; AL = number of sectors to read
    
    mov ah, 02h
    mov di, 3                           ; retry count

.retry:
    pusha                               ; save all registers, we don't know what bios modifies
    stc                                 ; set carry flag, some BIOS'es don't set it
    int 13h                             ; carry flag cleared = success
    jnc .done                           ; jump if carry not set

    ; read failed
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry

.fail:
    ; all attempts are exhausted
    jmp floppy_error

.done:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax                             ; restore registers modified
    ret


;
; Resets disk controller
; Parameters:
;   dl: drive number
;
disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc floppy_error
    popa
    ret





msg_hello: db 'Hello world!', ENDL, 0
msg_read_failed:        db 'Read from disk failed!', ENDL, 0


times 510-($-$$) db 0
dw 0AA55h
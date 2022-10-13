;
;	kernel
;

[org 0x7e00]

MOV     AX, 1003h       
MOV     BL, 00
INT     10h

mov  ax, 0003h    ; BIOS.SetVideoMode 80x25 16-color text
int  10h

mov  dh, 0
mov dl, 0
mov  bh, 0        ; DisplayPage
mov  ah, 02h      ; BIOS.SetCursorPosition
int  10h


mov ah,06h  ;clear screen instruction
mov al,00h  ;number of lines to scroll
mov bh,82h    ;display attribute - colors
mov ch,[default_row]    ;start row
mov cl,[default_col]    ;start col
mov dh,24d  ;end of row
mov dl,79d  ;end of col
int 10h     ;BIOS interrupt

mov ax, 0  ; set up segments
   mov ds, ax
   mov es, ax
   mov ss, ax     ; setup stack
   mov sp, 0x7C00 ; stack grows downwards from 0x7C00
 
   mov si, welcome
   call print_string
 
 mainloop:
   mov si, prompt
   call print_string
 
   mov di, buffer
   call get_string
 
   mov si, buffer
   cmp byte [si], 0  ; blank line?
   je mainloop       ; yes, ignore it
 
   mov si, buffer
   mov di, cmd_hi  ; "hi" command
   call strcmp
   jc .helloworld
 
   mov si, buffer
   mov di, cmd_help  ; "help" command
   call strcmp
   jc .help
   
   mov si, buffer
   mov di, cmd_changelog  ; "changelog" command
   call strcmp
   jc .chlog
   
   mov si, buffer
   mov di, cmd_color  ; "color" command
   call strcmp
   jc .color
 
   mov si,badcommand
   call print_string 
   jmp mainloop  
 
 .helloworld:
   mov si, msg_helloworld
   call print_string
 
   jmp mainloop
   
 .color:
	;; get color
	mov si, msg_color
    call print_string
 
	mov di, buffer
    call get_string
    
	mov ah,06h  ;clear screen instruction
	mov al,00h  ;number of lines to scroll
	mov bh,[buffer]    ;display attribute - colors
	mov ch,[default_row]    ;start row
	mov cl,[default_col]    ;start col
	mov dh,24d  ;end of row
	mov dl,79d  ;end of col
	int 10h     ;BIOS interrupt
	
	mov si, welcome
    call print_string
	
	jmp mainloop
   
 .chlog:
	mov si, changelog_msg
	call print_string
	
	jmp mainloop
 
 .help:
   mov si, msg_help
   call print_string
 
   jmp mainloop
 
 welcome db 'Welcome to RandomOS! (help FOR HELP)', 0x0D, 0x0A, 0
 msg_helloworld db 'Hello, Bootloader!', 0x0D, 0x0A, 0
 badcommand db 'Bad command entered.', 0x0D, 0x0A, 0
 prompt db '/>', 0
 cmd_hi db 'hi', 0
 cmd_help db 'help', 0
 cmd_changelog db 'changelog',0
 changelog_msg db '--|CHANGELOG|--',0X0D,0X0A,'RandomOS 0.60',0X0D,0X0A,'-Color command!',0X0D,0X0A,'-clear command!',0X0D,0X0A,'-64 sectors! (4 available)',0X0D,0X0A,0X0D,0X0A,0
 msg_help db 'RandomOS Commands:',0X0D,0X0A,'hi -- prints test message',0X0D,0X0A,'help -- this',0X0A,0X0D,'changelog -- check this every update!!',0X0A,0X0D,0
 
 msg_color db 'Enter color you want (EXAMPLE: 41f):',0X0D,0X0A,0
 cmd_color db 'color',0
 
 default_col db 0
 default_row db 0
 
 buffer times 4096 db 0
 
 ; |================|
 ; |calls start here|
 ; |================|
 
 print_string:
   lodsb        ; grab a byte from SI
 
   or al, al  ; logical or AL by itself
   jz .done   ; if the result is zero, get out
 
   mov ah, 0x0E
   int 0x10      ; otherwise, print out the character!
 
   jmp print_string
 
 .done:
   ret
 
 get_string:
   xor cl, cl
 
 .loop:
   mov ah, 0
   int 0x16   ; wait for keypress
 
   cmp al, 0x08    ; backspace pressed?
   je .backspace   ; yes, handle it
 
   cmp al, 0x0D  ; enter pressed?
   je .done      ; yes, we're done
 
   cmp cl, 0x70  ; chars inputted?
   je .loop      ; yes, only let in backspace and enter
 
   mov ah, 0x0E
   int 0x10      ; print out character
 
   stosb  ; put character in buffer
   inc cl
   jmp .loop
 
 .backspace:
   cmp cl, 0	; beginning of string?
   je .loop	; yes, ignore the key
 
   dec di
   mov byte [di], 0	; delete character
   dec cl		; decrement counter as well
 
   mov ah, 0x0E
   mov al, 0x08
   int 10h		; backspace on the screen
 
   mov al, ' '
   int 10h		; blank character out
 
   mov al, 0x08
   int 10h		; backspace again
 
   jmp .loop	; go to the main loop
 
 .done:
   mov al, 0	; null terminator
   stosb
 
   mov ah, 0x0E
   mov al, 0x0D
   int 0x10
   mov al, 0x0A
   int 0x10		; newline
 
   ret
 
 strcmp:
 .loop:
   mov al, [si]   ; grab a byte from SI
   mov bl, [di]   ; grab a byte from DI
   cmp al, bl     ; are they equal?
   jne .notequal  ; nope, we're done.
 
   cmp al, 0  ; are both bytes (they were equal before) null?
   je .done   ; yes, we're done.
 
   inc di     ; increment DI
   inc si     ; increment SI
   jmp .loop  ; loop!
 
 .notequal:
   clc  ; not equal, clear the carry flag
   ret
 
 .done: 	
   stc  ; equal, set the carry flag
   ret


times 30720-($-$$) db 0 

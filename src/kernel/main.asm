org 0x7e00
mov al, 'A'
mov ah, 0x0e
int 0x10
cli
hlt

; msg: db 'hello world', 0

; mov si, msg

; loop:
;   lodsb
;   or al, al
;   jz .done

;   mov ah, 0x0e
;   int 0x10

;   jmp loop

; .done:
;   cli
;   hlt
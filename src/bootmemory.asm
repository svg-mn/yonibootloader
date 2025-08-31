org 0x7c00

mov ah, 0x0e ; tty mode

mov bp, 0x8000
mov sp, bp

push "A"
push "B"

mov al, [0x7ffe] 
int 0x10

times 510 - ($-$$) db 0
dw 0xaa55 

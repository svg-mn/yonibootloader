org 0x7c00

start:
  jmp main

puts:
  ;push si
  ;push ax  

.loop:
  lodsb
  or al, al
  jz .done
  
  mov ah, 0x0e
  int 0x10

  jmp .loop

.done:
  pop si
  ret

main:
  ;mov ax, 0
  ;mov ds, ax
  ;mov es, ax

  ;mov ss, ax
  ;mov sp, ax ;0x7c00
  
  mov si, msg
  call puts
 
msg: db 'hello world'

times 510-($-$$) db 0
dw 0xaa55 

org 0x7c00

start:
  jmp main

load_segment:
  ; INT 13h AH=02h: Read Sectors From Drive
  mov ah, 0x02
  mov al, 0x01        ; Number of sectors to read
  mov ch, 0x00        ; Cylinder 0
  mov cl, 0x02        ; Sector 2 (first sector is 1
  mov dh, 0x00        ; Head 0
  mov dl, 0x00        ; Drive 0 (first floppy drive)
  mov es, ax          ; Segment to load to (0x0000)
  mov bx, 0x7e00      ; Offset to load to (0x
  int 0x13
  ret

.loop:
  lodsb
  or al, al
  jz .done
  
  mov ah, 0x0e
  int 0x10

  jmp .loop

.done:
  ret

main:
  mov si, msg
  call puts
 
msg: db 'hello world'

times 510-($-$$) db 0
dw 0xaa55 

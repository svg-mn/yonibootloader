org 0x7c00
bits 16

_main:
  call _load_segment
  mov ah, 0x02
  mov ch, 0
  mov cl, 1
  mov dh, 0
  mov dl, 0x80
  int 0x13

  cmp ah, 1
  je _print

jmp $ ; jump to current address = infinite loop

_load_segment:
  mov ax, 0x07E0    ; Set segment to 0x07E0
  mov es, ax        ; es:bx -> 0x07E0:0000 (Physical address 0x7E00)
  mov bx, 0x0000    ; Offset is 0x0000

_print:
  mov al, 'y'
  mov ah, 0x0e
  int 0x10

; padding and magic number
times 510 - ($-$$) db 0
dw 0xaa55

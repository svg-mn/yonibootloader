org 0x7c00
bits 16


msg: db 'hello world', 0

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

load_gdt:
  ; Disable interrupts
  cli

  ; Load the GDT
  lgdt [gdt_descriptor]

  ; Enable protected mode
  mov eax, cr0
  or eax, 1
  mov cr0, eax
  
  ; set to 32 bit 
  bits 32
  ; Far jump to flush the prefetch queue and load new CS
  jmp 0x08:start_protected_mode

  hlt

gdt_start:
  gdt_null:
    ; Null descriptor
    dq 0

  gdt_code:
    ; Code segment descriptor
    dw 0xFFFF       ; Limit low (bits 0-15)
    dw 0x0000       ; Base low (bits 0-15)
    db 0x00         ; Base mid (bits 16-23)
    db 0x9A         ; Access byte
    db 0xCF         ; Limit high (bits16-19=0xF) + Flags (0xC = Gran=1, 32-bit=1)
    db 0x00         ; Base high (bits 24-31)

  gdt_data:
    ; Data segment descriptor
    dw 0xFFFF       ; Limit low (bits 0-15)
    dw 0x0000       ; Base low (bits 0-15)
    db 0x00         ; Base mid (bits 16-23)
    db 0x92         ; Access byte
    db 0xCF         ; Limit high (bits16-19=0xF
    db 0x00         ; Base high (bits 24-31)

gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1  ; Size of GDT - 1
  dd gdt_start                ; Address of GDT

start_protected_mode: 
  ; Set up segment registers
  mov ax, 0x10  ; Data segment selector
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax 
  jmp $

.print:
  mov si, msg
  lodsb
  or al, al
  jz .done
  
  mov ah, 0x0e
  int 0x10

  jmp .print

.done:
  hlt
  cli

main:
  ; call print
  ; call load_segment
  call load_gdt  
times 510-($-$$) db 0
dw 0xaa55 

org 0x7c00
bits 16

; msg: db 'hello world', 0

main:
  call load_os_lba
  call load_gdt

load_os_lba:
  ; Load the OS from disk to memory using LBA
  xor ax, ax
  mov ax, 0x0000
  mov ds, ax
  mov si, dap
  mov ah, 0x42
  mov dl, 0x80
  int 0x13
  
  jc load_os_error 

  jmp load_os_success
  
  dap:
    db 0x10
    db 0x00
    dw 0x0001
    dw 0x7e00
    dw 0x0000
    ; dd 0x7e000000
    dq 0x0000000000000001
  
  load_os_error:
    mov al, 'E'
    mov ah, 0x0e
    int 0x10
    jmp load_os_error
  
  load_os_success:
    mov al, 'S'
    mov ah, 0x0e
    int 0x10
    ; jmp load_os_success
    ret
  ret



load_gdt:
  ; Load the GDT
  lgdt [gdt_descriptor]

  ; Enable protected mode
  mov eax, cr0
  or eax, 1
  mov cr0, eax
  
  ; Far jump to flush the prefetch queue and load new CS
  jmp 0x08:reloade_CS


gdt_start:
  ; Null descriptor
  dq 0

  ; Code segment descriptor
  dw 0xFFFF       ; Limit low (bits 0-15)
  dw 0x0000       ; Base low (bits 0-15)
  db 0x00         ; Base mid (bits 16-23)
  db 0x9A         ; Access byte
  db 0xCF         ; Limit high (bits16-19=0xF) + Flags (0xC = Gran=1, 32-bit=1)
  db 0x00         ; Base high (bits 24-31)
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

bits 32
reloade_CS: 
  ; Set up segment registers
  mov ax, 0x10  ; Data segment selector
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax 
  mov esp, 0x90000
  mov dword [0xB8000], 0x4D50004E 

pm_hang:
    cli
    hlt
    jmp pm_hang


times 510-($-$$) db 0
dw 0xaa55 


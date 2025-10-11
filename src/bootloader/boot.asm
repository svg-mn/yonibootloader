org 0x7C00
; BITS 16

_start:
    call load_os_lba
    call load_gdt
    ; call pm_hang
    ; call checkCPUID 

; -------------------------------------------------------------------------
; load_os_lba - use INT 13h AH=0x42 (Extended/LBA read). DS:SI -> DAP packet
; -------------------------------------------------------------------------
load_os_lba:
    xor ax, ax
    mov ds, ax              ; DS = 0x0000 (so DS:SI addresses < 64KiB)
    mov si, .dap            ; DS:SI -> Disk Address Packet
    mov ah, 0x42            ; Extended Read
    mov dl, 0x80            ; first hard disk
    int 0x13

    jc .load_os_error

    jmp .load_os_success

    .dap:
      db 0x10                 
      db 0x00                 
      dw 0x0001               
      dw 0x7e00               
      dw 0x0000               
      dq 0x0000000000000001   

    .load_os_error:
      mov al, 'E'
      mov ah, 0x0e
      int 0x10
      jmp pm_hang

    .load_os_success:
      mov al, 'S'
      mov ah, 0x0e
      int 0x10
      ret

; -------------------------------------------------------------------------
; load_gdt -> lgdt, enable PE, far jump to protected-mode entry
; -------------------------------------------------------------------------
load_gdt:
    cli
    lgdt [.gdt_descriptor]

    ; enable protected mode
    mov eax, cr0
    or  eax, 1
    mov cr0, eax

    jmp 0x08:.reloade_CS

    ; --------------------------
    ; GDT (null, code, data)
    ; --------------------------
    .gdt_start:
        dq 0x0000000000000000        ; null descriptor

    ; code descriptor
    .gdt_code:
        dw 0xFFFF                    ; limit low
        dw 0x0000                    ; base low
        db 0x00                      ; base mid
        db 0x9A                      ; access: present, ring0, code, exec/read
        db 0xCF                      ; flags + limit_high: G=1, D/B=1 (32-bit), limit high=0xF
        db 0x00                      ; base high

    ; data descriptor
    .gdt_data:
        dw 0xFFFF
        dw 0x0000
        db 0x00
        db 0x92                      
        db 0xCF
        db 0x00

    .gdt_end:

    .gdt_descriptor:
        dw .gdt_end - .gdt_start - 1  ; size - 1
        dd .gdt_start                 ; base address

    ; -------------------------------------------------------------------------
    ; Protected-mode entry (32-bit)
    ; -------------------------------------------------------------------------
    .reloade_CS:
        BITS 32
        ; load data selectors (0x10) into segment registers
        mov ax, 0x10
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax

        ; stack for protected mode
        mov esp, 0x7E00

        ; mov dword [0xB8000], 0x4D50004E
        call checkCPUID  ; jump to code segment selector (0x08) 
        call pm_hang

%include "src/bootloader/cpuid.inc"

pm_hang:
    mov dword [0xB8000], 0x4D50004E
    cli
    hlt
    jmp pm_hang



times 510-($-$$) db 0
dw 0xaa55 


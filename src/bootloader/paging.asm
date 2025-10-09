
PML4T_ADDR equ 0x1000
SIZEOF_PAGE_TABLE equ 4096

    mov edi, PML4T_ADDR
    mov cr3, edi
    xor eax, eax
    mov ecx, SIZEOF_PAGE_TABLE
    rep stosd
    mov edi, cr3

PML4T_ADDR equ 0x1000
PDPT_ADDR equ 0x2000
PDT_ADDR equ 0x3000
PT_ADDR equ 0x4000

; the page table only uses certain parts of the actual address
PT_ADDR_MASK equ 0xffffffffff000
PT_PRESENT equ 1                 ; marks the entry as in use
PT_READABLE equ 2                ; marks the entry as r/w

    ; edi was previously set to PML4T_ADDR
    mov DWORD [edi], PDPT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

    mov edi, PDPT_ADDR
    mov DWORD [edi], PDT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

    mov edi, PDT_ADDR
    mov DWORD [edi], PT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

ENTRIES_PER_PT equ 512
SIZEOF_PT_ENTRY equ 8
PAGE_SIZE equ 0x1000

    mov edi, PT_ADDR
    mov ebx, PT_PRESENT | PT_READABLE
    mov ecx, ENTRIES_PER_PT      ; 1 full page table addresses 2MiB

.SetEntry:
    mov DWORD [edi], ebx
    add ebx, PAGE_SIZE
    add edi, SIZEOF_PT_ENTRY
    loop .SetEntry      

CR4_PAE_ENABLE equ 1 << 5

    mov eax, cr4
    or eax, CR4_PAE_ENABLE
    mov cr4, eax

EFER_MSR equ 0xC0000080
EFER_LM_ENABLE equ 1 << 8

    mov ecx, EFER_MSR
    rdmsr
    or eax, EFER_LM_ENABLE
    wrmsr

CR0_PM_ENABLE equ 1 << 0
CR0_PG_ENABLE equ 1 << 31

    mov eax, cr0
    or eax, CR0_PG_ENABLE | CR0_PM_ENABLE   ; ensuring that PM is set will allow for jumping
                                            ; from real mode to compatibility mode directly
    mov cr0, eax

; Access bits
PRESENT        equ 1 << 7
NOT_SYS        equ 1 << 4
EXEC           equ 1 << 3
DC             equ 1 << 2
RW             equ 1 << 1
ACCESSED       equ 1 << 0

; Flags bits
GRAN_4K       equ 1 << 7
SZ_32         equ 1 << 6
LONG_MODE     equ 1 << 5

GDT:
    .Null: equ $ - GDT
        dq 0
    .Code: equ $ - GDT
        .Code.limit_lo: dw 0xffff
        .Code.base_lo: dw 0
        .Code.base_mid: db 0
        .Code.access: db PRESENT | NOT_SYS | EXEC | RW
        .Code.flags: db GRAN_4K | LONG_MODE | 0xF   ; Flags & Limit (high, bits 16-19)
        .Code.base_hi: db 0
    .Data: equ $ - GDT
        .Data.limit_lo: dw 0xffff
        .Data.base_lo: dw 0
        .Data.base_mid: db 0
        .Data.access: db PRESENT | NOT_SYS | RW
        .Data.Flags: db GRAN_4K | SZ_32 | 0xF       ; Flags & Limit (high, bits 16-19)
        .Data.base_hi: db 0
    .Pointer:
        dw $ - GDT - 1
        dq GDT
  
    lgdt [GDT.Pointer]
    jmp GDT.Code:Realm64

bits 64

VGA_TEXT_BUFFER_ADDR equ 0xb8000
COLS equ 80
ROWS equ 25
BYTES_PER_CHARACTER equ 2
VGA_TEXT_BUFFER_SIZE equ BYTES_PER_CHARACTER * COLS * ROWS

Realm64:
    cli                           ; the code would probably be more reliable if you did this
                                  ; before even switching from real mode
    mov ax, GDT.Data
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov rdi, VGA_TEXT_BUFFER_ADDR
    mov rax, 0
    mov rcx, VGA_TEXT_BUFFER_SIZE / 8
    rep stosq
    hlt
    jmp pm_hang
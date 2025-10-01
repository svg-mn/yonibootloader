[org 0x7c00]

EFLAGS_ID              equ 1 << 21
CPUID_EXTENSIONS       equ 0x80000000
CPUID_EXT_FEATURES     equ 0x80000001
CPUID_EDX_EXT_FEAT_LM  equ 1 << 29

checkCPUID:
    ; --- check CPUID availability ---
    pushfd
    pop eax
    mov ecx, eax
    xor eax, EFLAGS_ID
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    xor eax, ecx
    jnz .supported

.notSupported:
    mov ah, 0x0E
    mov al, 'X'        ; No CPUID
    int 0x10
    jmp pm_hang

.supported:
    mov ah, 0x0E
    mov al, 'C'        ; CPUID supported
    int 0x10

.queryCPUIDExtensions:
    mov eax, CPUID_EXTENSIONS
    cpuid
    cmp eax, CPUID_EXT_FEATURES
    jb .NoLongMode

.queryLongMode:
    mov eax, CPUID_EXT_FEATURES
    cpuid
    test edx, CPUID_EDX_EXT_FEAT_LM
    jz .NoLongMode

    mov ah, 0x0E
    mov al, 'L'        ; Long mode supported
    int 0x10
    jmp pm_hang

.NoLongMode:
    mov ah, 0x0E
    mov al, 'N'        ; No long mode
    int 0x10
    jmp pm_hang

pm_hang:
    cli
    hlt
    jmp pm_hang

times 510-($-$$) db 0
dw 0xAA55

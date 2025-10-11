EFLAGS_ID              equ 1 << 21
CPUID_EXTENSIONS       equ 0x80000000
CPUID_EXT_FEATURES     equ 0x80000001
CPUID_EDX_EXT_FEAT_LM  equ 1 << 29


checkCPUID:
    ; --- check if CPUID instruction is supported ---
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
    jz .no_cpuid       ; if cannot toggle ID bit -> no CPUID

    ; --- query extended functions ---
    mov eax, CPUID_EXTENSIONS
    cpuid
    cmp eax, CPUID_EXT_FEATURES
    jb .no_long_mode   ; if < 0x80000001 -> no long mode info

    ; --- check long mode support bit ---
    mov eax, CPUID_EXT_FEATURES
    cpuid
    test edx, CPUID_EDX_EXT_FEAT_LM
    jz .no_long_mode   ; bit 29 of EDX not set -> no long mode

    ret                ; success -> return to caller


.no_cpuid:
    mov dword [0xB8000], 0x4F4E0043  ; print "CN" for "CPUID Not supported"
    jmp error_halt


.no_long_mode:
    mov dword [0xB8000], 0x4F4E004C  ; print "LN" for "Long mode Not supported"
    jmp error_halt


error_halt:
    cli
    hlt
    jmp error_halt

EFLAGS_ID              equ 1 << 21
CPUID_EXTENSIONS       equ 0x80000000
CPUID_EXT_FEATURES     equ 0x80000001
CPUID_EDX_EXT_FEAT_LM  equ 1 << 29

; global checkCPUID

checkCPUID:
    mov dword [0xB8000], 0x4D50004E
    hlt
    
    ; jmp checkCPUID
    ; --- check CPUID availability ---
    ; pushfd
    ; pop eax
    ; mov ecx, eax
    ; xor eax, EFLAGS_ID
    ; push eax
    ; popfd
    ; pushfd
    ; pop eax
    ; push ecx
    ; popfd
    ; xor eax, ecx
    ; jnz .supported

    ; .notSupported:
    ;     jmp error

    ; .supported:

    ; .queryCPUIDExtensions:
    ;     mov eax, CPUID_EXTENSIONS
    ;     cpuid
    ;     cmp eax, CPUID_EXT_FEATURES
    ;     jb .NoLongMode

    ; .queryLongMode:
    ;     mov eax, CPUID_EXT_FEATURES
    ;     cpuid
    ;     test edx, CPUID_EDX_EXT_FEAT_LM
    ;     jz .NoLongMode

    ; .NoLongMode:
    ;     jmp error
    
    ; ret

; error:
;     hlt
;     cli
;     jmp error

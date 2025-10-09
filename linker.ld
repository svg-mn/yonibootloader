/* boot.ld - link so VMA (load address) = 0x7C00 */
ENTRY(start)

SECTIONS
{
    . = 0x7C00;

    .text : {
        *(.text)
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss COMMON)
    }
}

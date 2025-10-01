#include "helper.h"
void _start() {
    setup_paging();
    while (1){
        __asm__ volatile ("cli");
        __asm__ volatile ("hlt");
    }
}
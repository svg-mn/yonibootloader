typedef unsigned int   uint32_t;
typedef unsigned short uint16_t;
typedef unsigned char  uint8_t;

int page_directory[1024] __attribute__((aligned(4096)));
uint32_t first_page_table[1024] __attribute__((aligned(4096)));

void setup_paging() {
    for (int i = 0; i < 1024; i++) {
        page_directory[i] = 0x00000002; }

    for (int i = 0; i < 1024; i++){
        first_page_table[i] = (i * 0x1000) | 3;} // present + RW

    page_directory[0] = ((int)first_page_table) | 3;

    int pd_addr = (int)page_directory;
    __asm__ volatile ("mov %0, %%cr3" :: "r"(pd_addr));

    int cr0;
    __asm__ volatile ("mov %%cr0, %0" : "=r"(cr0));
    cr0 |= 0x80000001;  // PG + PE
    __asm__ volatile ("mov %0, %%cr0" :: "r"(cr0));
}

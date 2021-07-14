#include "arch/x86_64/gdt.h"
#include "arch/x86_64/stivale2.h"

void kmain(__attribute__((unused)) struct stivale2_struct *stivale2_struct)
{
	gdt_init();

	for (;;) asm ("hlt");
}

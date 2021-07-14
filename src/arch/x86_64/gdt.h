#ifndef DESCRIPTORS_H
#define DESCRIPTORS_H
#include <stdint.h>

typedef struct
{
	uint16_t limit;
	uint64_t base;
} __attribute__((packed)) gdt_ptr_t;

typedef struct
{
	uint16_t limit;
	uint16_t low;
	uint8_t mid;
	uint8_t access;
	uint8_t granularity;
	uint8_t high;
} __attribute__((packed)) gdt_entry_t;

void gdt_init();

#endif

CC = gcc
TARGET := cozen.elf
ISO_IMAGE = cozen.iso

INTERNALLDFLAGS := -O2 -nostdlib -static -z max-page-size=0x1000 -Tsrc/linker.ld

:FLAGS  :=       \
	-Wall		\
	-Wextra		\
	-O2		\
	-pipe
	-Isrc/               \
	-std=gnu99           \
	-ffreestanding       \
	-fno-stack-protector \
	-fno-pic	     \
	-mcmodel=kernel	     \
	-mno-80387           \
	-mno-mmx             \
	-mno-3dnow           \
	-mno-sse             \
	-mno-sse2            \
	-mno-red-zone

CFILES := $(shell find src/ -type f -name '*.c')
OBJS   := $(addsuffix .o, $(basename $(CFILES)))

.PHONY: run

all: run

run: $(ISO_IMAGE)
	@qemu-system-x86_64 -enable-kvm -M q35 -m 256M -cdrom $(ISO_IMAGE)

limine:
	@git clone https://github.com/limine-bootloader/limine.git --branch=v2.0-branch-binary --depth=1
	@$(MAKE) -C limine

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJS)
	@$(CC) $(INTERNALLDFLAGS) $(OBJS) -o $@

$(ISO_IMAGE): limine $(TARGET)
	@rm -rf iso_root
	@mkdir -p iso_root
	@cp cozen.elf \
		limine.cfg limine/limine.sys limine/limine-cd.bin limine/limine-eltorito-efi.bin iso_root/
	@xorriso -as mkisofs -b limine-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot limine-eltorito-efi.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		iso_root -o $(ISO_IMAGE)
	@limine/limine-install $(ISO_IMAGE)
	@rm -rf iso_root

clean:
	$(RM) $(OBJS) $(TARGET) $(ISO_IMAGE)

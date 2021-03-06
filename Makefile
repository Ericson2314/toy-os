QEMU ?= qemu-system-i386

arch ?= i686
target ?= $(arch)-unknown-linux-gnu

rust_kernel := ./kernel/target/$(target)/debug/libkernel.a

kernel := ./build/kernel-$(arch).bin
kernel_elf := ./build/kernel-$(arch).elf
boot_sect := ./build/boot_sect.bin

os-image := ./build/os-image

.PHONY: all
all: os-image

.PHONY: run
run: all
	bochs

.PHONY: run-qemu
run-qemu:
	$(QEMU) -fda $(os-image)

.PHONY: debug-qemu
debug-qemu: $(os-image)
	$(QEMU) -S -gdb tcp::3333 -fda $< &
	termite -e 'gdb $< -ex "target remote :3333" -ex "break *0x1000" -ex "c"'

.PHONY: disassemble
disassemble: $(kernel)
	objdump -b binary -m i386 --adjust-vma=0x1000 -D $< > dump.txt

.PHONY: clean
clean:
	@cargo clean --manifest-path ./kernel/Cargo.toml
	@rm -rf build

.PHONY: os-image
os-image: $(os-image)

$(os-image): $(boot_sect) $(kernel)
	cat $^ > $@

.PHONY: boot_sect
boot_sect: $(boot_sect)

$(boot_sect): asm/boot_sect.asm
	@mkdir -p build
	nasm asm/boot_sect.asm -f bin -o $@ -I ./asm/

.PHONY: kernel
kernel: $(kernel)

$(kernel_elf): $(rust_kernel)
	@mkdir -p build
	ld --gc-sections -m elf_i386 -o $@ -T linker.ld $^

$(kernel): $(kernel_elf)
	objcopy --output-target=binary $< $@

.PHONY: $(rust_kernel)
$(rust_kernel):
	RUSTFLAGS="-C relocation-model=static" cargo build --manifest-path ./kernel/Cargo.toml --target $(target)

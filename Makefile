# $@ = target file
# $< = first dependency
# $^ = all dependencies
# debug: $(info $$var = $(var))

# find src files in sub dirs (excluding kernel.c)
SRCDIR := src
SOURCES := $(shell find $(SRCDIR) -name "*.c" ! -name "kernel.c")

# translate to single output dir
OBJDIR := build
OBJECTS := $(patsubst %.c, $(OBJDIR)/%.o, $(notdir $(SOURCES)))

# collapse duplicate results into VPATH
SRCDIRS := $(sort $(dir $(SOURCES)))
VPATH := $(SRCDIRS)

FLAGS := -O0 -Wall -g -ffreestanding \
	-nostartfiles -nodefaultlibs \
	-nostdlib -lgcc -fno-exceptions \
	-falign-jumps -falign-functions \
	-falign-labels -falign-loops \
	-fomit-frame-pointer -fno-builtin 

all: bin/disk.img bin/kernel.bin

# Write boot.bin into first sector
# Write remaining kernel code into subsequent sectors
# Fill up rest of disk with 100 sector sized blocks of zeros
bin/disk.img: bin/boot.bin bin/kernel.bin
	dd if=bin/boot.bin > bin/disk.img
	dd if=bin/kernel.bin >> bin/disk.img
	dd if=/dev/zero bs=512 count=100 >> bin/disk.img 

# compile boot.asm directly into bin
bin/boot.bin: src/boot/boot.asm
	nasm -f bin src/boot/boot.asm -o bin/boot.bin
   
# link O files into kernel.bin
# manual ordering so kernel.o is linked into .text section first for 0x0100000 call
bin/kernel.bin: $(OBJDIR)/kernel.o $(OBJECTS) src/linker.ld
	i686-elf-gcc $(FLAGS) -T src/linker.ld $(OBJDIR)/kernel.o $(OBJECTS) -o bin/kernel.bin

# compile missing C files into O files (search VPATH)
$(OBJDIR)/%.o: %.c
	i686-elf-gcc $(FLAGS) -c $< -o $@

run:
	qemu-system-i386 -s -curses -drive file=bin/disk.img,index=0,media=disk,format=raw

clean:
	rm -rf bin/*
	rm -rf build/*

# debug

bin/kernel.elf: $(OBJDIR)/kernel.o $(OBJECTS)
	x86_64-linux-gnu-ld -m elf_i386 -o $@ -Ttext 0x1000 $^

debug: bin/disk.img bin/kernel.elf
	qemu-system-i386 -s -S -curses -drive file=bin/disk.img,index=0,media=disk,format=raw

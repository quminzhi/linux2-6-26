.PHONY: qemu initrd clean gdb build_src initrd_src build_gdb

BUSYBOX=busybox-1.20.1
KERNEL=linux-2.6.34
GDBDIR=gdb-7.9
SRC=src

V=x86_64
NPROC=4

CC=gcc
CFLAGS=-Wall -Werror -O0 -static -ggdb

TIMESTAMP := $(shell date +%Y%m%d-%H%M%S)

qemu:
	qemu-system-$(V) -kernel $(KERNEL)/arch/x86/boot/bzImage \
	-initrd initrd.img -append "console=ttyS0 root=/dev/ram" -nographic

compile_commands:
	cd $(KERNEL) && rm -rf compile_commands.json && \
		bear -- make -j$(NPROC) && cat compile_commands.json | wc -l

# COMPILE KERNEL MANUALLY
# kernel:
# 	cd $(KERNEL) && make defconfig && make menuconfig && make -j(ncpu) 

gdb:
	qemu-system-$(V) -kernel $(KERNEL)/arch/x86/boot/bzImage \
	-initrd initrd.img -append "console=ttyS0 root=/dev/ram" -nographic \
	-S -s

# The boot sector size is 16K by default in confgure when building kernel.
# Size of initrd.img should be less than 16K, or change boot sector size and
# rebuild kernel.
initrd: build_src
	dd if=/dev/zero of=initrd.img-$(TIMESTAMP) bs=4096 count=2048
	mkfs.ext3 initrd.img-$(TIMESTAMP)
	mkdir -p rootfs
	sudo mount -o loop initrd.img-$(TIMESTAMP) rootfs
	sudo cp -rf $(BUSYBOX)/_install/* ./rootfs
	sudo cp $(SRC)/app ./rootfs/tmp/app
	sudo umount ./rootfs
	rm -rf rootfs

build_src:
	$(CC) $(CFLAGS) -o $(SRC)/app $(SRC)/*.c

# DO BUSYBOX MANUALLY
# busybox:
# 	cd $(BUSYBOX) && make defconfig && make menuconfig && make install
# 	cd $(BUSYBOX) && ./build.sh

# build gdb with python support, python2.7-dev required to install
build_gdb:
	rm -rf /usr/local/bin/gdb
	cd $(GDBDIR) && make clean && \
		./configure --with-python=/usr/bin/python2.7 && \
		make && sudo make install

clean:
	rm -rf $(SRC)/app initrd.img-*

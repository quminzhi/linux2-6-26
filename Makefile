.PHONY: qemu initrd clean gdb

BUSYBOX=busybox-1.20.1
KERNEL=linux-2.6.34
V=x86_64

TIMESTAMP := $(shell date +"%Y%m%d-%H%M%S")

qemu:
	qemu-system-$(V) -kernel $(KERNEL)/arch/$(V)/boot/bzImage \
	-initrd initrd.img -append "console=ttyS0 root=/dev/ram" -nographic

# download gdb-7.9 and patch it
# https://sourceware.org/bugzilla/attachment.cgi?id=8512&action=diff
gdb:
	qemu-system-$(V) -kernel $(KERNEL)/arch/$(V)/boot/bzImage \
	-initrd initrd.img -append "console=ttyS0 root=/dev/ram" -nographic \
	-S -s

# BUILD KERNEL MANUALLY
# kernel:
# 	make defconfig
# 	make menuconfig
# 	make -j(ncpu)
save-kernel:
	cp $(KERNEL)/arch/$(V)/boot/bzImage kimages/bzImage-$(V)-$(TIMESTAMP)

# DO BUSYBOX MANUALLY
# busybox:
# 	cd $(BUSYBOX) && make defconfig && make menuconfig && make install
# 	cd $(BUSYBOX) && ./build.sh

initrd: # busybox
	dd if=/dev/zero of=initrd.img bs=4096 count=1024
	mkfs.ext3 initrd.img
	mkdir -p rootfs
	sudo mount -o loop initrd.img rootfs
	sudo cp -rf $(BUSYBOX)/_install/* ./rootfs
	sudo umount ./rootfs
	rm -rf rootfs

clean:
	rm -rf rootfs

.PHONY: init qemu rootfs clean

qemu: rootfs
	qemu-system-x86_64 -kernel linux-2.6.26/arch/x86/boot/bzImage -initrd rootfs.cpio.gz -append "console=ttyS0 init=/init" -nographic

rootfs: init
	cd rootfs && find . | cpio -o -H newc | gzip > ../rootfs.cpio.gz

init:
	gcc -static -o rootfs/init init.c

clean:
	rm -rf rootfs.cpio.gz rootfs/init
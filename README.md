# How to Compile Linux 2.6.34 on Ubuntu 14 and Execute Linux Binary with QEMU

To compile Linux 2.6.26 on Ubuntu 14 and execute the Linux binary with QEMU,
follow these steps:

## 1. Install necessary packages
Install the required packages for building the kernel and running QEMU.

```bash
sudo apt-get update
sudo apt-get install build-essential libncurses-dev bison flex libssl-dev
libelf-dev qemu
```

## 2. Download the Linux 2.6.34 kernel source
Download the kernel source from the official Linux kernel archives.

```bash
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v2.6/linux-2.6.34.tar.gz
tar -xzf linux-2.6.34.tar.gz
cd linux-2.6.34
```

## 3. Configure the kernel
Configure the kernel using the default configuration for your architecture.

```bash
make ARCH=x86_64 defconfig
make ARCH=x86_64 menuconfig
```

- device driver -> block device -> default ram disk -> change it as 16384 KB
- kernel hacking -> compile the kernel with debug info
- kernel hacking -> compile with frame pointer
- kernel hacking -> KGDB, kernel debug with remote gdb

## 4. Compile the kernel
Compile the kernel and modules.

```bash
make ARCH=x86_64 -j$(nproc)
make modules // if you want to build it as a module
```

## 5. Install the modules (optional)
Install the compiled modules.

```bash
sudo make modules_install
```

## 6. Create a disk image with busybox

Create a disk image to use with QEMU.

Install busybox-1.20.1 and make files for disk image with `build.sh`

```bash
#!/bin/bash

# Configure files for rootfs
cd _install
mkdir etc proc sys mnt dev tmp
mkdir -p etc/init.d
cat >> etc/fstab<<EOF
proc    /proc   proc    defaults        0       0
tmpfs   /tmp    tmpfs   defaults        0       0
sysfs   /sys    sysfs   defaults        0       0
EOF
cat>>etc/init.d/rcS<<EOF
echo "Welcome to linux..."
EOF
chmod 755 etc/init.d/rcS 
cat>>etc/inittab<<EOF
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
::askfirst:-/bin/sh
::ctrlaltdel:/bin/umount -a -r
EOF
chmod 755 etc/inittab
cd dev
sudo mknod console c 5 1
sudo mknod null c 1 3
sudo mknod tty1 c 4 1
cd ..
```

Make a `ext3` image `initrd.img` for linux.

```bash
dd if=/dev/zero of=initrd.img bs=4096 count=1024
mkfs.ext3 initrd.img
mkdir -p rootfs
sudo mount -o loop initrd.img rootfs
sudo cp -rf $(BUSYBOX)/_install/* ./rootfs
sudo umount ./rootfs
rm -rf rootfs
```

## 7. Run the kernel with QEMU
Use QEMU to run the compiled kernel with the created disk image.

```bash
qemu-system-$(V) -kernel $(KERNEL)/arch/x86/boot/bzImage \
	-initrd initrd.img -append "console=ttyS0 root=/dev/ram" -nographic
```

This will boot the Linux 2.6.34 kernel using QEMU with the created disk image.

# How to Compile Linux 2.6.26 on Ubuntu 14 and Execute Linux Binary with QEMU

To compile Linux 2.6.26 on Ubuntu 14 and execute the Linux binary with QEMU,
follow these steps:

## 1. Install necessary packages
Install the required packages for building the kernel and running QEMU.

```bash
sudo apt-get update
sudo apt-get install build-essential libncurses-dev bison flex libssl-dev
libelf-dev qemu
```

## 2. Download the Linux 2.6.26 kernel source
Download the kernel source from the official Linux kernel archives.

```bash
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v2.6/linux-2.6.26.tar.gz
tar -xzf linux-2.6.26.tar.gz
cd linux-2.6.26
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
make modules
```

## 5. Install the modules
Install the compiled modules.

```bash
sudo make modules_install
```

## 6. Create a disk image
Create a disk image to use with QEMU.

```bash
dd if=/dev/zero of=rootfs.img bs=1M count=1024
mkfs.ext4 rootfs.img
mkdir -p mnt
sudo mount -o loop rootfs.img mnt
sudo debootstrap --arch amd64 trusty mnt
sudo umount mnt
```

## 7. Run the kernel with QEMU
Use QEMU to run the compiled kernel with the created disk image.

```bash
qemu-system-x86_64 -kernel arch/x86/boot/bzImage -hda rootfs.img -append
"root=/dev/sda rw" -net nic -net user
```

This will boot the Linux 2.6.26 kernel using QEMU with the created disk image.

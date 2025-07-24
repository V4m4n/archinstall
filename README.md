
# ⚠️ WARNING: Scripts Are Not Finalized

> These installation scripts (`pre_chroot.sh`, `in_chroot.sh`, and `arch_install_mbr.sh`) are **unfinished** and may contain **critical bugs**.  
> Please **review and adapt the code carefully** before executing on your system.  
> It is highly recommended to full backups to avoid data loss.

---

# Arch Linux Dual Boot Installation Guide

This guide helps you set up Arch Linux as a dual-boot system (UEFI and optionally MBR) using custom shell scripts. These scripts aim to automate a portion of the setup process after preparing your ISO and partitions on a separate SSD or drive.

### Repository: [Ducmanh2712/archinstall](https://github.com/Ducmanh2712/archinstall)

---

## 📁 Scripts Overview

| Script                | Description                                      |
|-----------------------|--------------------------------------------------|
| `pre_chroot.sh`       | Run in the live ISO environment (before chroot) |
| `in_chroot.sh`        | Run after `arch-chroot` into new system         |
| `arch_install_mbr.sh` | Alternate script for legacy BIOS/MBR systems    |

---

## 🔧 Step-by-Step Instructions

### 1. Prepare ISO and Bootable Partition

You **do not need a USB drive**. You'll mount the ISO and copy its contents to a FAT32 partition on an external SSD.

#### 📥 Download Arch ISO
- Visit: [https://archlinux.org/download](https://archlinux.org/download)
- Download the latest `.iso` file.

#### 💿 Mount ISO
- Right-click the ISO file and select `Mount`.
- Copy all contents from the mounted drive (e.g., `D:`) to a new FAT32 partition.

#### 💽 Create a FAT32 Partition (Windows)
- Use `Disk Management` to shrink your external SSD and create a 1024MB FAT32 partition named `ISO`.

#### ⚙️ Set Partition as EFI (GPT only)
Open `cmd` as Administrator and run:
```cmd
diskpart
list disk
select disk <your_disk_number>
list partition
select partition <your_partition_number>
set id=c12a7328-f81f-11d2-ba4b-00a0c93ec93b
````

(Use the GUID for EFI from `help setid` in `diskpart`)

---

### 2. Boot into Arch ISO

* Reboot and enter UEFI/BIOS (`F2`, `Delete`, etc.)
* Disable **Secure Boot** and **Fast Boot**
* Set boot priority to the external SSD or manually choose the ISO partition
* Boot into **Arch Linux (UEFI mode)**

---

### 3. Run Pre-Chroot Script

After booting into the Arch Live environment:

```bash
loadkeys us        # or your preferred keymap
timedatectl set-ntp true

# Make sure your network is online
ping archlinux.org

# Fetch the script
git clone https://github.com/Ducmanh2712/archinstall
cd archinstall

# Make it executable
chmod +x pre_chroot.sh

# Edit script if needed
nano pre_chroot.sh

# Run it
./pre_chroot.sh
```

This script should:

* Partition the drive
* Format partitions
* Mount root and EFI
* Install base system via `pacstrap`
* Generate `fstab`

---

### 4. Chroot into the New System

```bash
arch-chroot /mnt
```

---

### 5. Run In-Chroot Script

Inside the chroot environment:

```bash
cd archinstall
chmod +x in_chroot.sh
nano in_chroot.sh   # Review first!
./in_chroot.sh
```

This script performs:

* Timezone and locale setup
* Hostname, root password
* Bootloader installation (likely `systemd-boot`)
* User creation and sudo setup
* Optional: Hyprland or other desktop environment (if customized)

---

## 💾 For MBR Legacy Systems

If your system uses **BIOS with MBR partitioning**, use the alternative script:

```bash
chmod +x arch_install_mbr.sh
nano arch_install_mbr.sh
./arch_install_mbr.sh
```

> ⚠️ **Make sure your drive uses MBR format.**
> You can convert via `cfdisk` or `fdisk`, or check with `parted -l`.

---

## ✅ Final Steps

After installation:

```bash
exit          # Exit chroot
umount -R /mnt
reboot
```

In your UEFI/BIOS:

* Ensure your new Arch Linux boot entry is selected
* You should now boot into a minimal Arch system

---

## 📌 Notes & Tips

* All scripts assume you're using `/dev/sda`. Adjust accordingly using `lsblk`!
* Be very cautious with `wipefs`, `mkfs`, and partition commands — **data loss is irreversible**.
* These scripts are designed for **advanced users**. Don’t run them blindly.
* Check logs and use `echo`, `set -e`, and `set -x` in scripts for debugging.

---
<!--
## 🙋 Support

If something breaks:

* Start a new issue in the [GitHub repo](https://github.com/Ducmanh2712/archinstall)
* Or carefully inspect and debug each line in the script
-->

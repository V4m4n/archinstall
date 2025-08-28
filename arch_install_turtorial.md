# Arch Linux + Hyprland Installation Tutorial

**Author:** Vaman  
**Date:** 2025-03-20

> This is a manual dual-boot Arch Linux installation guide using Hyprland on a separate SSD, designed for UEFI systems. I wrote this guide to understand the operating system better, so it will be somewhat lengthy.

---
## Table of Contents

<div class="toc">

1. [**Prepare ISO File**](#1-prepare-iso-file)
   - Download ISO file from official website
   - Mount ISO file

2. [**Prepare Separate SSD and Partitioning**](#2-prepare-separate-ssd-and-partitioning)
   - Using Disk Management
   - Using Command Line

3. [**Copy Data to Partition**](#3-copy-data-to-partition)

4. [**Set Partition Type to EFI**](#4-set-partition-type-to-efi)
   - Configure EFI System Partition
   - Handle GPT/MBR errors

5. [**Boot into Arch Linux**](#5-boot-into-arch-linux)
   - Configure UEFI/BIOS
   - Disable Secure Boot and Fast Boot

6. [**Install Operating System**](#6-install-operating-system-through-booted-arch)
   - Identify SSD drive
   - Create partition table
   - Format and mount partitions

7. [**Install Base System**](#7-install-base-system)
   - Base system installation
   - Create fstab
   - Chroot into system

8. [**System Configuration**](#8-system-configuration)
   - Set timezone
   - Configure locale
   - Set hostname and password

9. [**Install Bootloader**](#9-install-bootloader-for-uefi-system)
   - Systemd-boot installation
   - Configure boot entries

10. [**Create User**](#10-create-user)
    - Create user account
    - Configure sudo permissions

11. [**Complete Installation**](#11-complete-installation)
    - Cleanup and reboot

12. [**Install and Configure Hyprland**](#12-install-and-configure-hyprland)
    - Install Hyprland
    - Configure terminal and launcher
    - Start desktop environment

13. [**Summary and Notes**](#13-summary-and-notes)

</div>

---

## 1. Prepare ISO File

### Download ISO file from Arch Linux official website
- Click [here](https://archlinux.org/download/).
- Scroll down and select a mirror (here I choose the first one `geo.mirror.pkgbuild.com`, you can choose another mirror).

### Mount ISO file
- Right-click and select `mount`.

---

## 2. Prepare Separate SSD and Partitioning

- Check the size of the optical drive that just appeared.
    
    Example: my optical drive size is `999MB`. So I will create a partition of `1024MB` (1GB).
    
- Create a new **Simple Volume** with size **1024MB**, format **FAT32** and label **ISO**.

### Method 1: Using Disk Management

1. **Press `Win + X`, Select `Disk Management`**
    
    If prompted to choose `MBR` or `GPT`, select `GPT`

2. **Select the separate SSD drive**
    
    > ⚠️ **Warning:** Select the correct separate SSD.

3. **Create new Simple Volume**
   - Create new partition with **1024MB**:
     
     Right-click on the empty disk space and select "New Simple Volume"
     
     Enter size `1024MB`
     
   - Choose file system as FAT32
   - Enter Volume label as ISO

![Disk Management](https://www.itechguides.com/wp-content/uploads/2024/04/Disk-Management-formats-a-USB-drive-with-the-NTFS-file-system-by-default.-If-you-wish-to-format-your-drive-with-the-FAT32-file-system-select-this-option-on-the-Format-Partition-page-of-the-wizard.webp)

**Complete creating new volume**

### Method 2: Using Command Line

<details>
<summary>Details</summary>
You can also perform the above operations through cmd:

1. **Open cmd with admin privileges**

2. **Open diskpart**
   ```bash
   diskpart
   ```

3. **List drives**
   ```bash
   list disk
   ```

4. **Select disk**
   ```bash
   sel disk x
   ```
   x here is your disk number
   
   > ⚠️ **Warning:** Select the correct disk to avoid data loss

5. **Create partition with size 1024MB**
   ```bash
   create partition primary size=1024
   ```

6. **List partitions**
   ```bash
   list part
   ```

7. **Select newly created partition**
   ```bash
   sel part x
   ```
   x here is your partition number
   
   > ⚠️ **Warning:** Select the correct partition to avoid data loss

8. **Format partition as FAT32 and set label as ISO**
   ```bash
   format fs=fat32 label=ISO quick
   ```
    You can change the label as desired

9. **Assign drive letter F**
   ```bash
   assign letter=F
   ```
    You can choose another letter

10. **Exit diskpart**
    ```bash
    exit
    ```

</details>

> ⚠️ **Warning:**
> - **Select the correct disk (`sel disk`) to avoid data loss!**
> - **If you're not familiar with these operations, using `Disk Management` is safer**

---

## 3. Copy Data to Partition

- Open the optical drive that appeared when you `mounted` the ISO file.
- `Copy` everything and then `paste` into the newly created partition.
- You can then eject the optical drive by right-clicking and selecting eject.

---

## 4. Set Partition Type to EFI

1. **Open cmd with admin privileges**

2. **Open diskpart**
   ```bash
   diskpart
   ```

3. **List drives**
   ```bash
   list disk
   ```

4. **Select your disk**
   ```bash
   sel disk x
   ```
   x here is your disk number

5. **List partitions**
   ```bash
   list part
   ```

6. **Select the partition where you copied the optical drive data**
   ```bash
   sel part x
   ```
   x here is your partition number

7. **Type command**
   ```bash
   help setid
   ```

8. **Find EFI System partition ID**
   - Scroll up to find the line `EFI System partition:`
   - You'll see a code line like: `c12a7328-f81f-11d2-ba4b-00a0c93ec93b`
   - Copy that code and type the command
   
   ```bash
   set id=<your_id>
   ```
   replace `<your_id>` with the code you just got
   
   **Example:**
   ```bash
   set id=c12a7328-f81f-11d2-ba4b-00a0c93ec93b
   ```

9. **Handle errors (if any)**
   - If successful, you'll get a notification
   - In case of errors, check if your partition table is GPT or MBR by typing again
   
   ```bash
   list disk
   ```
   
   - Check if your drive is GPT, if not, type the command
   
   ```bash
   convert gpt
   ```
   
   - Then repeat the process.

---

## 5. Boot into Arch Linux

> 💡 **Information:** `BIOS` and `UEFI` are both types of `firmware`. Modern computers use `UEFI` instead of `BIOS` due to advanced features and superior performance.

### Steps to perform:

1. **Restart the computer and press `F2` to enter `UEFI`**
   - Different computer models use different keys, it could be `F12`, `Delete`, `Esc`...
   - Search for the shortcut key to enter `UEFI` for your computer model beforehand

   > ⚠️ **Warning:** Be careful when operating in `UEFI` as it can cause serious errors to your machine. Only operate with settings that are not dangerous to the machine.

2. **Turn off `secure boot` and `fast boot`**
   - `Fast boot` and `secure boot` are usually located in the `BOOT` and `SECURITY` sections

3. **Create new `boot option`**
   - Sometimes the machine will automatically create one after completing the above operations.

4. **Boot into `arch linux`**
   - Select `arch linux` and `boot` into it.

---

## 6. Install Operating System Through Booted Arch

### 6.1. Identify SSD Drive

Open terminal and use command:

```bash
lsblk -f
```

Identify the drive name (example: `/dev/sda`).

> ⚠️ **Warning:** Identify correctly to avoid data loss

### 6.2. Create Partition Table

Use `cfdisk` to create GPT table on SSD:

```bash
cfdisk /dev/sda
```

#### Create EFI (ESP) partition: about 300-512 MB, FAT32 format

This partition contains boot files and bootloader. UEFI will find this directory and boot the system.

- In the cfdisk interface, you'll see multiple partitions. Use arrow keys to move to free space.
- Select `New`.
- Choose size: Enter size for EFI partition, here I enter: `512M` (512MB).
- After creation, select the newly created partition (usually `/dev/sda3`) and select `type`.
- Choose format `EFI System Partition`(EF00).

#### Create root partition: remaining space (ext4 format)

- After creating the EFI partition, in the remaining free space, press `New` to create another new partition.
- Choose size: You can choose all remaining space for the root partition, by selecting all or entering the size as desired.
- This partition will be used as the partition containing the Arch Linux system.
- After creation, select the newly created partition (let's call it `/dev/sda4` since sda3 is already used for EFI partition, change according to your case) and select `type`.
- Choose format `linux system` (usually default, no need to select).
- *(Optional)* You can create additional swap partition if needed.

### 6.3. Format Partitions

#### EFI:
```bash
mkfs.fat -F32 /dev/sda3
```

#### Root:
```bash
mkfs.ext4 /dev/sda4
```

### 6.4. Mount Partitions

1. **Ensure you're in root directory**
   ```bash
   cd /
   ```

2. **Mount root to `/mnt`:**
   ```bash
   mount /dev/sda4 /mnt
   ```

3. **Create `boot` directory in `/mnt` and mount EFI partition there:**
   ```bash
   mkdir /mnt/boot
   ```
   
   ```bash
   mount /dev/sda3 /mnt/boot
   ```


> 💡 **Explanation of "set id" step from step 4:**
> <details>
> <summary>Details</summary>
>
> Previously we used Diskpart to "set id" for the partition. This assigns an identification code (ID) to the partition, helping `BIOS/UEFI` recognize that partition as bootable (EFI System Partition). If we create partitions using Linux (e.g., using `cfdisk`), we would set type as `EFI system partition` as above, these two operations are equivalent.
>
> </details>

---

## 7. Install Base System

### 7.1. Install base system

Use `pacstrap` to install base packages:

```bash
pacstrap /mnt base linux linux-firmware
```

### 7.2. Generate fstab file

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### 7.3. Chroot into newly installed system

```bash
arch-chroot /mnt
```

> 💡 **Chroot:**
>
> <details>
>
> <summary>Details</summary>
>
> - A command used to temporarily change the root directory (/) of a process or environment.
> - Simply put, chroot helps "change the perspective" of the system, making a directory become the root directory for commands inside it.
> - This is necessary because the Arch we're currently using for installation is called a live version (Arch live) that's pre-configured for temporary use to install another Arch, you can delete this Arch live after completing the installation.
>
> </details>

---

## 8. System Configuration

### 8.1. Set timezone

(Here I use Vietnam timezone)

```bash
ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
```

```bash
hwclock --systohc
```

### 8.2. Configure locale

1. **Open file `/etc/locale.gen` and uncomment the line:**
   ```
   en_US.UTF-8 UTF-8
   ```
   *(Or if you prefer Vietnamese locale, choose vi_VN.UTF-8 if available BUT DON'T DO THAT)*

2. **Then run:**
   ```bash
   locale-gen
   ```

3. **Create file `/etc/locale.conf`:**
   ```bash
   echo "LANG=en_US.UTF-8" > /etc/locale.conf
   ```

### 8.3. Set hostname

1. **Use command**
   ```bash
   echo "myarch" > /etc/hostname
   ```

2. **Open file `/etc/hosts` with nano or vim.**
   ```bash
   nano /etc/hosts
   ```

3. **Edit file `/etc/hosts`:**
   ```
   127.0.0.1   localhost
   ::1         localhost
   127.0.1.1   myarch.localdomain myarch
   ```

### 8.4. Set password for root

```bash
passwd
```

- Then enter to create new password

---

## 9. Install Bootloader (for UEFI system)

**Here I use systemd-boot**

### 9.1. Install systemd-boot

```bash
bootctl --path=/boot install
```

### 9.2. Create loader file

Create file `/boot/loader/loader.conf` with content:

```
default arch.conf
timeout 3
editor 0
```

### 9.3. Check PARTUUID of root partition

```bash
blkid | grep sda4
```

- Copy or remember the PARTUUID of the partition

> ⚠️ **Warning:** Make sure it's PARTUUID not UUID to avoid errors. You can use UUID instead of PARTUUID but must be accurate.

### 9.4. Create boot entry file

1. **Create file `/boot/loader/entries/arch.conf`:**
   ```bash
   nano /boot/loader/entries/arch.conf
   ```

2. **Fill in content as follows:**
   ```
   title   Arch Linux
   linux   /vmlinuz-linux
   initrd  /initramfs-linux.img
   options root=PARTUUID=<PARTUUID> rw
   ```
   
   replace `<PARTUUID>` with the PARTUUID of the root partition obtained above

3. **Or you can also use UUID**
   ```
   title   Arch Linux
   linux   /vmlinuz-linux
   initrd  /initramfs-linux.img
   options root=UUID=<UUID> rw
   ```

---

## 10. Create User

### 10.1. Create regular user account

```bash
useradd -m -G wheel -s /bin/bash your_username
```

### 10.2. Create password

```bash
passwd your_username
```

Then create new password for the user

### 10.3. Install sudo

```bash
pacman -S sudo
```

```bash
EDITOR=nano visudo
```

- In the visudo file, check if the following line is commented, if not, uncomment it, if it doesn't exist, add it:

```
%wheel ALL=(ALL:ALL) ALL
```

> 💡 This operation grants sudo usage rights to wheel users

---

## 11. Complete Installation

### 11.1. Exit chroot

```bash
exit
```

### 11.2. Unmount partitions

```bash
umount -R /mnt
```

### 11.3. Restart system

```bash
reboot
```

- Enter `BIOS/UEFI`.
- Now your machine will have a new boot option. It might have the same name as the boot option to enter arch live.
- Boot into that option
- If you see you're at root without requiring login, type

```bash
su -
```

- Then enter username and password to log in

---

## 12. Install and Configure Hyprland

After booting into the new Arch system, proceed to install Hyprland.

### 12.1. Update system

```bash
sudo pacman -Syu
```

### 12.2. Install Hyprland

Check if Hyprland is available in the main repo:

```bash
sudo pacman -S hyprland wayland wlroots xorg-xwayland
```

If not available (case needs to install from AUR), you can install an AUR helper like `yay`:

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

Then:

```bash
sudo yay -S hyprland wayland wlroots xorg-xwayland
```

### 12.3. Install some supporting applications

For example: terminal emulator, launcher, panel, etc.

```bash
sudo pacman -S alacritty wofi waybar
```

You can install other applications as needed.

### 12.4. Configure Hyprland

1. **Create configuration directory:**
   ```bash
   mkdir -p ~/.config/hypr
   ```

2. **Copy sample configuration file:**
   If the system has installed sample configuration file (e.g., at `/etc/xdg/hypr/hyprland.conf`), you can copy it:
   
   ```bash
   cp /etc/xdg/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
   ```
   
   If not, you can create your own configuration file.

3. **Edit configuration:**
   Open file `~/.config/hypr/hyprland.conf` and set up keybindings, application launch commands...
   
   **Example:**
   ```
   # Launch terminal with Super+Enter
   bind = SUPER, Return, exec, alacritty
   # Close window with Super+Q
   bind = SUPER, Q, killactive
   ```
   
   You can add `exec` lines to start utilities like wofi, waybar, or other services if needed.

   > 💡 Learn about Hyprland before installing

### 12.5. Start Hyprland

Log in and run command:

```bash
Hyprland
```

---

## 13. Summary and Notes

- **Warning:** Be careful when operating with `bootloader`, `BIOS/UEFI` and drives as it can affect other operating systems you're using.

- **Minimal system:** The above guide installs "minimal" Arch Linux and then installs Hyprland without installing other basic tools.

- **Hyprland configuration:** Customize Hyprland configuration file according to your needs (keybindings, theme, startup applications...). You can refer to [Hyprland wiki](https://wiki.hyprland.org/) for more details.

---

If you have any questions or issues during installation, you can get support by contacting support [here](https://chatgpt.com/).

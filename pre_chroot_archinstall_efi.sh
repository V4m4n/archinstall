#!/bin/bash
set -e

# Change the partition name 
DISK="/dev/sda"
EFI_PART="${DISK}3"
ROOT_PART="${DISK}4"

echo "[*] Format the partition"
mkfs.fat -F32 "$EFI_PART"
mkfs.ext4 "$ROOT_PART"

echo "[*] Mount partition"
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot/efi
mount "$EFI_PART" /mnt/boot/efi

echo "[*] Pacstrap base system"
pacstrap /mnt base linux linux-firmware

echo "[*] Make fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "[*] Copy the in_chroot.sh to the new system"
cp in_chroot.sh /mnt/root/in_chroot.sh
chmod +x /mnt/root/in_chroot.sh

echo
echo "[*] Okayyyyy, You have done the first step. Now run these following command:"
echo "    arch-chroot /mnt"
echo "    After that run the in_chroot.sh to finish"

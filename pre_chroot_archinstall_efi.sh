#!/bin/bash
set -e

DISK="/dev/sda"
EFI_PART="${DISK}3"
ROOT_PART="${DISK}4"

echo "[*] Format partitions"
mkfs.fat -F32 "$EFI_PART"
mkfs.ext4 "$ROOT_PART"

echo "[*] Mount partitions"
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot

echo "[*] Install base system"
pacstrap /mnt base linux linux-firmware

echo "[*] Generate fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "[*] Copy setup script into new system"
cp in_chroot.sh /mnt/in_chroot.sh
chmod +x /mnt/in_chroot.sh

echo
echo "[*] Done pre-install! Now run:"
echo "    arch-chroot /mnt"
echo "    bash /root/in_chroot.sh"

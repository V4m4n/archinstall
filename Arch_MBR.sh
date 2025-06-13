#!/bin/bash

DISK="/dev/sdX"
USER="admin"
HOST="arch-lxde"
LOCALE="en_US.UTF-8"
TIMEZONE="Asia/Ho_Chi_Minh"

echo "Starting setup"
sleep 2

# 1. Tạo bảng phân vùng MBR
echo "Create new MBR"
parted -s "$DISK" mklabel msdos
parted -s "$DISK" mkpart primary ext4 1MiB 513MiB
parted -s "$DISK" set 1 boot on
parted -s "$DISK" mkpart primary ext4 513MiB 100%

BOOT="${DISK}1"
ROOT="${DISK}2"

echo "Format partition"
mkfs.ext4 "$BOOT"
mkfs.ext4 "$ROOT"

echo "Mount partition"
mount "$ROOT" /mnt
mkdir /mnt/boot
mount "$BOOT" /mnt/boot

echo "pacstrap base system"
pacstrap /mnt base linux linux-firmware vim networkmanager grub sudo lxde xorg-server lightdm lightdm-gtk-greeter firefox

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<EOF

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

sed -i "s/#$LOCALE/$LOCALE/" /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

echo "$HOST" > /etc/hostname
cat <<EOL > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOST.localdomain $HOST
EOL

echo "Password for root:"
passwd

useradd -m -G wheel -s /bin/bash $USER
echo "Password for $USER:"
passwd $USER

sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

systemctl enable NetworkManager
systemctl enable lightdm

grub-install --target=i386-pc --recheck $DISK
grub-mkconfig -o /boot/grub/grub.cfg

EOF

# 15. Kết thúc
echo "Done! Now you can use and test more on your Arch + LXDE"
umount -R /mnt
echo "You can reboot to test."

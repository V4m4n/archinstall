#!/bin/bash
set -e

echo "[*] Set timezone and clock"
ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
hwclock --systohc

echo "[*] Set locale"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "[*] Set hostname"
echo "myarch" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   myarch.localdomain myarch
EOF

echo "[*] Set root password"
passwd

echo "[*] Create swapfile (16GB, pri=100)"
fallocate -l 16G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile -p 100
echo "/swapfile none swap defaults,pri=100 0 0" >> /etc/fstab

echo "[*] Install systemd-boot"
bootctl --path=/boot install

echo "[*] Create loader.conf"
mkdir -p /boot/loader/entries
cat <<EOF > /boot/loader/loader.conf
default arch.conf
timeout 3
editor 0
EOF

echo "[*] Create boot entry"
PARTUUID=$(blkid -s PARTUUID -o value /dev/sda4)
cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$PARTUUID rw resume=/swapfile
EOF

echo "[*] Create user"
read -p "Username: " username
useradd -m -G wheel -s /bin/bash "$username"
passwd "$username"

echo "[*] Install sudo and enable wheel group"
pacman -S --noconfirm sudo
echo "→ Open visudo and uncomment this line: %wheel ALL=(ALL:ALL) ALL"
EDITOR=nano visudo

echo "[*] Install network tools"
pacman -S --noconfirm dhcpcd dhclient usbmuxd inetutils
systemctl enable dhcpcd

echo "[*] Disable swap before reboot"
swapoff /swapfile

echo "[*] DONE! Now run:"
echo "exit"
echo "umount -R /mnt"
echo "reboot"

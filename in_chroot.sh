#!/bin/bash
set -e

echo "[*] Set time and clock:"
ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
hwclock --systohc

echo "[*] Locale:"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "[*] Hostname:"
echo "myarch" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   myarch.localdomain myarch
EOF

echo "[*] Set password for root"
passwd

echo "[*] Make swapfile (16GB)"
fallocate -l 16G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile -p 100
echo "/swapfile none swap defaults,pri=100 0 0" >> /etc/fstab

echo "[*] Install systemd-boot"
bootctl install

echo "[*] Make loader.conf"
cat <<EOF > /boot/loader/loader.conf
default arch.conf
timeout 3
editor 0
EOF

echo "[*] Boot entry"
PARTUUID=$(blkid -s PARTUUID -o value /dev/sda4)
cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=xxxx rw resume=/swapfile
EOF

echo "[*] Make a user to use"
read -p "Name: " Vaman # Change your user name
useradd -m -G wheel -s /bin/bash "$username"
passwd "$username"

echo "[*] Sudo for user"
pacman -S --noconfirm sudo
echo " remove the '#' of this line: %wheel ALL=(ALL:ALL) ALL"
EDITOR=nano visudo

echo "[*] Install some network tools"
pacman -S --noconfirm dhcpcd dhclient usbmuxd inetutils

echo "[*] Okayy, done"
echo "Run these following command:"
echo "exit"
echo "umount -R /mnt"
echo "reboot"

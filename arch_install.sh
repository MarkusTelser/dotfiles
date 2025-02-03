#!/usr/bin/env bash

# set the keyboard layout 
loadkeys de-latin1

# crypto shredding
cryptsetup erase /dev/nvme0n1 # remove keys from old LUKS header
wipefs --all /dev/nvme0n1 # remove the whole old LUKS header

# full erase of NVMe-drive
nvme format --ses 1 /dev/nvme0 

# check if 4k-sectors are supported and used on drive
# switch ssd to native 4k-blocks
nvme id-ns -H /dev/nvme0n1 | grep "4096 bytes"
nvme format --lbaf=1 /dev/nvme0n1

# verify the boot mode
[ -d /sys/firmware/efi/efivars ] && echo "Success: Booted in UEFI"

# connect to WiFi access point
ip link set <INTERFACE> up
iwctl station <INTERFACE> connect <SSID>

# check internet connection 
ping -c 5 8.8.8.8 

# set correct timezone
timedatectl set-timezone "Europe/Rome"
timedatectl | grep -i time

# partition disks
sudo parted /dev/nvme0n1
unit GiB
mklabel gpt
mkpart "efi partition" fat32 1MiB 551MiB # efi = 550Mib
mkpart "boot partition" ext4 551MiB 1.5GiB # boot = 1GiB 
mkpart "main partition" 1.5GiB 100% # main = REST GiB (LVM on LUKS2)
set 1 esp on
set 3 lvm on
print free
quit

# load encryption kernel modules 
modprobe dm-crypt dm-mod

# setup encryption
cryptsetup luksFormat --type luks2 /dev/nvme0n1p3
cryptsetup luksOpen --type luks2 /dev/nvme0n1p3 luks

# create LVM partitions
# "-C y" sets contiguous allocation policy (useful for SWAP)
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mappper/luks
lvcreate -C y --size 16G vg0 --name swap 
lvcreate --size 40G vg0 --name root
lvcreate --size 200G vg0 --name home
lvcreate -l +100%FREE vg0 --name ext

# format file systems
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mkfs.ext4 /dev/vg0/root
mkfs.ext4 /dev/vg0/home
mkfs.ext4 /dev/vg0/ext

# initialize and enable swap
mkswap /dev/vg0/swap
swapon /dev/vg0/swap

# mount partitions
mount /dev/vg0/root /mnt
mount --mkdir /dev/nvme0n1p2 /mnt/boot
mount --mkdir /dev/nvme0n1p1 /mnt/boot/efi
mount --mkdir /dev/vg0/home /mnt/home
mount --mkdir /dev/vg0/ext /mnt/ext

# install the basis
pacstrap -K /mnt base base-devel linux linux-firmware lvm2 sudo git neovim vi

# generate fstab file and chroot into the new system
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# set hostname 
nvim /etc/hostname

# set root password
passwd

# edit the host file
tee /etc/hosts << EOF
127.0.0.1	 localhost
::1				 localhost
127.0.1.1	 xyz
EOF

# set time zone and sync hwclock
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
hwclock --systohc
date

# localization
nvim /etc/locale.gen && locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=de-latin1" >> /etc/vconsole.conf
echo "XKBLAYOUT=de-latin1" >> /etc/vconsole.conf

# configure mkinitcpio with modules needed for the image & regenerate:
# Add 'ext4' to MODULES
# Add 'encrypt', 'lvm2' and 'resume' to HOOKS before 'filesystems'
nvim /etc/mkinitcpio.conf
mkinitcpio -p linux

# setup the boot loader grub
pacman -S grub efibootmgr 
grub-install --target=x86_64-efi --bootloader=GRUB --efi-directory=/boot/efi --removable
blkid | grep swap >> /etc/default/grub # prints UUIDs of block devices
# In /etc/default/grub edit the line GRUB_CMDLINE_LINUX to:
# GRUB_CMDLINE_LINUX="cryptdevice=/dev/nvme0n1p3:luks:allow-discards root=/dev/vg0/root"
# also add "resume=UUID=<UUID_OF_SWAP>"
# remove "quiet" from GRUB_CMDLINE_LINUX_DEFAULT
# and set "GRUB_TIMEOUT" to zero
nvim /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# install & enable network manager, dhcp- and ssh-server
pacman -S networkmanager dhcpcd openssh
systemctl enable NetworkManager dhcpcd sshd

# stop and restart
exit 
umount -R /mnt && swapoff -a
reboot

# POST-INSTALL:
# -------------

# connect to WiFi access point
ip link set <INTERFACE> up
nmcli device wifi connect <SSID> password <PASSWORD>

# set the system default keyboard mapping for X11
localectl set-x11-keymap de

# create unpriviledged user (with sudo)
visudo # uncomment: %wheel ALL=(ALL:ALL) ALL
groupadd carlos && groupadd luis
useradd -g carlos -G carlos,wheel -m carlos
useradd -d /ext -g luis -G luis,wheel -m luis 
passwd carlos && passwd luis
su -l carlos

# setup reflector script to retrieve mirror list
sudo pacman -Sy reflector
sudo tee /etc/xdg/reflector/reflector.conf << EOF
--latest 5
--sort rate
--protocol https
--country "Italy,"
--save /etc/pacman.d/mirrorlist
EOF
sudo systemctl enable --now reflector.service

# install paru (or yay) to navigate the AUR
git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si

# install graphics driver
# https://wiki.archlinux.org/title/xorg#Driver_installation
sudo pacman -S mesa nvidia nvidia-utils

# install X-Server, Display Manager, Greeter
sudo pacman -S xorg xorg-apps lightdm lightdm-slick-greeter dunst
sudo pacman -S xorg-xinit xorg-twm xorg-xclock xterm xclip # needed for startx
sudo systemctl enable lightdm.service
sudo groupadd -r autologin
gpasswd -a carlos autologin

# change GTK-3.0 theme, icons and font
sudo pacman -S materia-gtk-theme deepin-icon-theme
paru -S adwaita-qt5-git
# change gtk-icon-theme-name to "bloom-classic"
# change gtk-theme-name to "Materia-dark-compact"
# change gtk-font-name to "DejaVu Sans 11"
sudo nvim /usr/share/gtk-3.0/settings.ini

# install tray icon application
sudo pacman -S blueman network-manager-applet udiskie
paru -S clipit pa-applet-git clipmenu

# setup sound server and bluetooth
sudo pacman -S pulseaudio pulseaudio-bluetooth pamixer
sudo systemctl enable bluetooth.service

# install other applications
sudo pacman -S virtualbox virtualbox-host-modules-arch virtualbox-guest-iso 
paru -S brave-bin megasync-nopdfium spotify visual-studio-code-bin
sudo pacman -S dolphin mpv htop filelight ntfs-3g libreoffice-fresh bitwarden

# install my own dotfiles setup
git clone https://github.com/markustelser/dotfiles ~/Code/dotfiles
cd ~/Code/dotfiles && sudo ./setup.sh ~

# set up network printer and scanner
sudo pacman -S cups sane sane-airscan skanlite
sudo systemctl enable --now cups

# LUKS header backup
cryptsetup luksHeaderBackup /dev/nvme0n1p1 --header-backup-file <NAME>.img

# optional installation options are in the folder: ./extras 

# the end
exit && reboot

# TODO rewrite README
# then put "QT_QPA_PLATFORMTHEME=qt5ct" in "/etc/environment" (TODO is this useful??)

# unlock LUKS partition with keyfile
# https://tqdev.com/2022-luks-with-usb-unlock

umount /dev/sda1
mkfs.vfat /dev/sda1
blkid /dev/sda1 # verify the formatting

dd if=/dev/urandom bs=1 count=256 > <UUID>.lek # get <UUID> with `uuidgen`
cp <UUID>.lek /PATH_WHERE_USB_IS_MOUNTED # get PATH of usb device with `lsblk`

blkid --match-token TYPE=crypto_LUKS -o device # outputs encrypted luks volume
cryptsetup luksAddKey /dev/nvme0n1p3 <UUID>.lek
rm <UUID>.lek

nvim /etc/mkinitcpio.conf
# add "vfat" the drive's file system to the MODULES array
# If there are messages about bad superblock and bad codepage at boot, then you need an extra codepage module 
# to be loaded. For instance, you may need nls_iso8859-1 module for iso8859-1 codepage.
mkinitcpio -p linux

nvim /etc/default/grub
# add rootdelay=3 to GRUB_CMDLINE_LINUX (=timeout for usb-device)
# add cryptkey=device:fstype:path to GRUB_CMDLINE_LINUX
# replace device=/dev/disk/by-uuid/<UUID>, fstype=vfat and path=/<UUID>.lek
grub-mkconfig -o /boot/grub/grub.cfg

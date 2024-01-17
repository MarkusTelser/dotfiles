#!/bin/sh
set -e
if [ ! -e /mnt ]; then
    mkdir -p /mnt
    sleep 3
fi
for usbpartition in /dev/disk/by-id/usb-*-part1; do
    usbdevice=$(readlink -f $usbpartition)
    if mount -t vfat $usbdevice /mnt 2>/dev/null; then
        if [ -e /mnt/$CRYPTTAB_KEY.lek ]; then
            cat /mnt/$CRYPTTAB_KEY.lek
            umount $usbdevice
            exit
        fi
        umount $usbdevice
    fi
done
/lib/cryptsetup/askpass "Insert USB key and press ENTER: "

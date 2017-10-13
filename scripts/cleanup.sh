#!/bin/bash

# Clean up
apt-get -y --purge remove linux-headers-$(uname -r) build-essential
apt-get -y --purge autoremove
apt-get -y purge $(dpkg --list |grep '^rc' |awk '{print $2}')
apt-get -y purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}')
apt-get -y clean
# Zero out empty space so the box gets smaller
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
# We want to zero the swap, but keep the same uuid
swap_uuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
swap_name=$(readlink -f "/dev/disk/by-uuid/$swap_uuid")
/sbin/swapoff -a
dd if=/dev/zero of="/dev/disk/by-uuid/$swap_uuid" bs=1M
/sbin/mkswap -U "$swap_uuid" "$swap_name"
# Remove history file
unset HISTFILE
rm ~/.bash_history /home/vagrant/.bash_history
# sync data to disk (fix packer)
sync

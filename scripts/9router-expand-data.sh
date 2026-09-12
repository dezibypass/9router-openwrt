#!/bin/sh
# Expand SDCard leftover to /mnt/data btrfs, like AE-WRT 32GB case.
# Usage: 9router-expand-data.sh [disk]  default /dev/mmcblk1
DISK=${1:-/dev/mmcblk1}
P3=${DISK}p3
[ -b "$P3" ] && { echo "$P3 already exists"; exit 0; }
END=$(cat /sys/block/$(basename $DISK)/$(basename $DISK)p2/end 2>/dev/null)
# fallback: start at 2629632 for 1G p2 layout
START=2629632
printf "n\np\n3\n$START\n\nw\n" | fdisk $DISK
partprobe $DISK 2>/dev/null; sleep 1
mkfs.btrfs -L DATA -f $P3
mkdir -p /mnt/data
mount -o compress=zstd,noatime $P3 /mnt/data
UUID=$(block info $P3 | sed -n 's/.*UUID="\([^"]*\)".*/\1/p')
uci add fstab mount >/dev/null
uci set fstab.@mount[-1].uuid="$UUID"
uci set fstab.@mount[-1].target='/mnt/data'
uci set fstab.@mount[-1].enabled='1'
uci set fstab.@mount[-1].options='compress=zstd,noatime'
uci commit fstab
mkdir -p /mnt/data/9router-data
df -h /mnt/data

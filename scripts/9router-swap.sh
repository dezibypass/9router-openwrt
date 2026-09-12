#!/bin/sh
# 9router-swap [size-mb] [swapfile]
# Create a swapfile on /mnt/data (btrfs needs NOCOW) + enable + persist via rc.local.
# Example: 9router-swap 2048  (2GB, default)
SIZE_MB="${1:-2048}"
SWAPFILE="${2:-/mnt/data/swapfile}"
case "$SIZE_MB" in ''|*[!0-9]*) echo "size must be a number (MB)"; exit 1;; esac
[ -d "$(dirname "$SWAPFILE")" ] || { echo "dir not found: $(dirname "$SWAPFILE")"; exit 1; }
if ! grep -q " $SWAPFILE " /proc/swaps 2>/dev/null; then
  swapoff "$SWAPFILE" 2>/dev/null
fi
opkg update 2>/dev/null
opkg install chattr 2>/dev/null
rm -f "$SWAPFILE"
touch "$SWAPFILE"
# btrfs swapfiles MUST be NOCOW and fully allocated (no sparse/holes)
chattr +C "$SWAPFILE" || { echo "chattr +C failed (need btrfs + chattr pkg)"; exit 1; }
echo "writing ${SIZE_MB}MB to $SWAPFILE ..."
dd if=/dev/zero of="$SWAPFILE" bs=1M count="$SIZE_MB" || exit 1
chmod 600 "$SWAPFILE"
mkswap "$SWAPFILE" || exit 1
swapon "$SWAPFILE" || { echo "swapon failed (btrfs needs kernel 5.x + NOCOW, single device, no snapshots)"; exit 1; }
# persist across reboots (rc.local runs after /mnt/data is mounted)
if ! grep -q "swapon.*$SWAPFILE" /etc/rc.local 2>/dev/null; then
  sed -i '/^exit 0/d' /etc/rc.local 2>/dev/null
  echo "swapon $SWAPFILE 2>/dev/null || true" >> /etc/rc.local
  echo "exit 0" >> /etc/rc.local
fi
free -m
swapon -s
 echo "OK: swap $SWAPFILE active"

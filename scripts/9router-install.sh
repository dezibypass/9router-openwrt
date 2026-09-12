#!/bin/sh
# 9router-install [version] — dipanggil setelah opkg install 9router*.ipk
# Tugas: siapkan /mnt/data, install node, npm install 9router ke /mnt/data.
VER="${1:-0.5.75}"
DATA_DIR="$(uci get 9router.main.data_dir 2>/dev/null)"
[ -z "$DATA_DIR" ] && DATA_DIR="/mnt/data/9router-data"
APP_BASE="/mnt/data/9router"
echo "== 9router-install v$VER =="
opkg update
opkg install node node-npm block-mount kmod-fs-btrfs btrfs-progs
mkdir -p /mnt/data "$DATA_DIR" "$APP_BASE"
# expand SDCard sisa otomatis kalau /mnt/data masih kecil (<2G)
if ! mountpoint -q /mnt/data; then
  /usr/sbin/9router-expand-data /dev/mmcblk1 2>/dev/null || true
fi
npm install -g 9router@${VER} --prefix "$APP_BASE"
ln -sf "$APP_BASE/bin/9router" /usr/bin/9router
ln -sf /usr/sbin/9router-reset-password /usr/bin/9router-reset-password 2>/dev/null || true
# bcryptjs wajib buat reset-password (npm kadang taruh di node_modules bukan lib)
if [ -d "$APP_BASE/node_modules/bcryptjs" ] && [ ! -e "$APP_BASE/lib/node_modules/bcryptjs" ]; then
  ln -sf "$APP_BASE/node_modules/bcryptjs" "$APP_BASE/lib/node_modules/bcryptjs"
fi
npm install bcryptjs --prefix "$APP_BASE" 2>/dev/null || true
if [ -d "$APP_BASE/node_modules/bcryptjs" ] && [ ! -e "$APP_BASE/lib/node_modules/bcryptjs" ]; then
  ln -sf "$APP_BASE/node_modules/bcryptjs" "$APP_BASE/lib/node_modules/bcryptjs"
fi
/etc/init.d/9router enable
/etc/init.d/9router restart
sleep 3
netstat -tlnp 2>/dev/null | grep 20128 || ss -tlnp 2>/dev/null | grep 20128
echo "OK. Buka http://$(uci get network.lan.ipaddr 2>/dev/null || echo 192.168.1.1):$(uci get 9router.main.port 2>/dev/null || echo 20128)/login"

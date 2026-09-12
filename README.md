# 9router-openwrt

9Router on OpenWrt — Services -> 9Router in LuCI, no interactive CLI needed. Tested on Amlogic S905X (OpenWrt 24.10, aarch64); the IPK is `Architecture: all`, so it works on other boards too.

## Requirements

- OpenWrt 23.05 / 24.10 (or SNAPSHOT) with working `opkg` and internet access
- Free storage for `/mnt/data` (SD / USB / HDD). A 1GB rootfs alone is not enough.
- `node` + `node-npm` from opkg (installed automatically by `9router-install`)

## Quick install (from GitHub Releases)

1. Open the **Releases** page of this repo and download the two latest `.ipk` files (`9router_*_all.ipk` + `luci-app-9router_*_all.ipk`). Example:

```sh
# on the router via ssh
cd /tmp
# REPLACE with the newest version from the Releases page!
VER=0.5.75-1
wget https://github.com/dezibypass/9router-openwrt/releases/download/v$VER/9router_${VER}_all.ipk
wget https://github.com/dezibypass/9router-openwrt/releases/download/v$VER/luci-app-9router_1.0-1_all.ipk
opkg install 9router_${VER}_all.ipk luci-app-9router_1.0-1_all.ipk
```

2. Prepare the data storage (one time only). Do NOT blindly copy a device path — check your disks first:

```sh
lsblk
# look for a disk with unpartitioned free space (e.g. a 32GB card with only
# 1GB used, or an empty USB stick /dev/sda)
9router-expand-data /dev/<your-disk>   # e.g. /dev/mmcblk1 or /dev/sda
# this creates a new DATA btrfs partition + auto-mounts it to /mnt/data via fstab
# if /mnt/data already has plenty of free space (>2GB), you may skip this step
df -h /mnt/data
```

3. Install Node + 9Router into the data storage:

```sh
# no argument = use the default version of the package
9router-install
# or pin a specific npm version:
# 9router-install 0.5.75
```

4. Open:

- LuCI: `http://<router-ip>/cgi-bin/luci/admin/services/9router/status` (replace `<router-ip>` with your router LAN IP, e.g. `192.168.1.1`)
- Dashboard: `http://<router-ip>:<port>/login` (default port `20128`, changeable in Settings)
- First login: set your own password. Forgot it? Reset from the LuCI Status page or via ssh with `9router-reset-password <newpassword>`. The interactive `9router` CLI is not needed.

## Configuration (UCI)

```sh
uci show 9router
uci set 9router.main.port='20128'
uci set 9router.main.host='0.0.0.0'      # use 127.0.0.1 for local-only
uci set 9router.main.data_dir='/mnt/data/9router-data'  # USB/HDD path works too
uci commit 9router
/etc/init.d/9router restart
```

Or via LuCI: Services -> 9Router -> Settings.

## Managing the service

```sh
/etc/init.d/9router status
/etc/init.d/9router restart
9router-reset-password newpassword
logread -e 9router | tail -n 20
```

## Layout

- `package/net/9router/` — OpenWrt feed (Makefile + files: UCI init, config, reset-password)
- `luci-app-9router/` — LuCI Services -> 9Router (status + settings + resetpw action)
- `scripts/` — `9router-expand-data.sh`, `9router-install.sh`, `make-ipk.sh`

## Tested example (author setup, not a general requirement)

- Board: Amlogic S905X (B860H V1), OpenWrt 24.10.0 armsr/armv8 aarch64
- 32GB card: p1 BOOT 255M + p2 ROOT 1G + p3 DATA 27.9G btrfs `/mnt/data` (compress=zstd,noatime)
- `node v20.20.2` from opkg, `9router 0.5.75` in `/mnt/data/9router`, data in `/mnt/data/9router-data`, port `20128`

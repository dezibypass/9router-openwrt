# openwrt-9router (AE-WRT port)

9Router di OpenWrt aarch64 (tested Amlogic S905X AE-WRT, OpenWrt 24.10). Services -> 9Router di LuCI, tanpa CLI.

## Install cepat (dari IPK GitHub Release)

```sh
# di router (ssh root@192.168.1.1)
cd /tmp
wget https://github.com/<user>/openwrt-9router/releases/latest/download/9router_0.5.75-1_all.ipk
wget https://github.com/<user>/openwrt-9router/releases/latest/download/luci-app-9router_1.0-1_all.ipk
opkg install 9router_0.5.75-1_all.ipk luci-app-9router_1.0-1_all.ipk
9router-expand-data /dev/mmcblk1   # sekali saja, 32GB -> /mnt/data
9router-install 0.5.75             # install node + npm 9router ke /mnt/data
```

Buka:
- LuCI: `http://192.168.1.1/cgi-bin/luci/admin/services/9router/status`
- Dashboard: `http://192.168.1.1:20128/login` (default `admin123`, reset via LuCI)

## Bikin IPK dari GitHub langsung? Bisa.

Repo ini punya Actions `.github/workflows/build-ipk.yml`:
- `Actions -> build-ipk -> Run workflow` -> isi version (default 0.5.75) -> artifact `ipk-aarch64_generic`
- Push tag `v*` (misal `v0.5.75-1`) -> otomatis masuk ke **Releases** sebagai `.ipk`.
- Tanpa OpenWrt SDK. IPK dirakit gaya `ipkg-build` (`debian-binary` + `control.tar.gz` + `data.tar.gz`), `Architecture: all`.
- Build lokal juga bisa: `./scripts/make-ipk.sh 0.5.75` -> `dist/*.ipk` (sudah tested).

## Harian

```sh
uci show 9router
/etc/init.d/9router restart
9router-reset-password passbaru
9router-install 0.5.75
```

## Struktur

- `package/net/9router/` : feed OpenWrt (Makefile + files: init UCI, config, reset-password)
- `luci-app-9router/` : LuCI Services -> 9Router (status + settings + action resetpw)
- `scripts/` : `9router-expand-data.sh`, `9router-install.sh`, `make-ipk.sh`
- `.github/workflows/build-ipk.yml` : build + release IPK

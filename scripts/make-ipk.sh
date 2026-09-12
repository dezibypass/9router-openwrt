#!/bin/sh
# Build 9router + luci-app-9router .ipk TANPA OpenWrt SDK (ipkg-build manual).
# Hasil: dist/*.ipk Architecture: all (JS murni, native diunduh saat install).
# Usage: ./scripts/make-ipk.sh [VER]
set -e
VER="${1:-$(grep PKG_VERSION package/net/9router/Makefile | head -n1 | awk -F:= '{print $2}' | tr -d ' ')}"
[ -z "$VER" ] && VER="0.5.75"
REL=1
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
rm -rf "$DIST" _ipk
mkdir -p "$DIST"
mkipk() {
  name=$1; ver=$2; arch=$3; srcdir=$4
  pkgdir="$ROOT/_ipk/$name"
  builddir="$ROOT/_ipk/build-$name"
  rm -rf "$pkgdir" "$builddir"
  mkdir -p "$pkgdir/CONTROL" "$builddir"
  cp -a "$srcdir"/* "$pkgdir"/
  cat > "$pkgdir/CONTROL/control" <<EOF
Package: $name
Version: ${ver}-${REL}
Architecture: $arch
Maintainer: AE-WRT 9router port
Description: $name - 9Router AI gateway on OpenWrt
EOF
  [ -f "$ROOT/CONTROL.$name.postinst" ] && cp "$ROOT/CONTROL.$name.postinst" "$pkgdir/CONTROL/postinst" && chmod 755 "$pkgdir/CONTROL/postinst"
  echo "2.0" > "$builddir/debian-binary"
  (cd "$pkgdir/CONTROL" && tar -czf "$builddir/control.tar.gz" ./control ./postinst 2>/dev/null || tar -czf "$builddir/control.tar.gz" ./control)
  (cd "$pkgdir" && tar --exclude=./CONTROL -czf "$builddir/data.tar.gz" .)
  (cd "$builddir" && ar r "$DIST/${name}_${ver}-${REL}_${arch}.ipk" debian-binary control.tar.gz data.tar.gz)
  echo "built $DIST/${name}_${ver}-${REL}_${arch}.ipk"
}
# --- staging 9router ---
rm -rf _st9 && mkdir -p _st9/etc/init.d _st9/etc/config _st9/usr/sbin
cp "$ROOT/package/net/9router/files/9router.init.live" _st9/etc/init.d/9router 2>/dev/null || cp "$ROOT/package/net/9router/files/9router.init" _st9/etc/init.d/9router
cp "$ROOT/package/net/9router/files/9router.config" _st9/etc/config/9router
cp "$ROOT/package/net/9router/files/9router-reset-password" _st9/usr/sbin/9router-reset-password
cp "$ROOT/scripts/9router-install.sh" _st9/usr/sbin/9router-install
cp "$ROOT/scripts/9router-expand-data.sh" _st9/usr/sbin/9router-expand-data
chmod 755 _st9/etc/init.d/9router _st9/usr/sbin/9router-* 
mkipk "9router" "$VER" "all" "$ROOT/_st9"
# --- staging luci ---
rm -rf _stlu && mkdir -p _stlu/usr/lib/lua/luci/controller _stlu/usr/lib/lua/luci/model/cbi _stlu/usr/lib/lua/luci/view/9router _stlu/usr/share/luci/menu.d _stlu/usr/share/rpcd/acl.d
cp "$ROOT/luci-app-9router/luasrc/controller/9router.lua" _stlu/usr/lib/lua/luci/controller/9router.lua
cp "$ROOT/luci-app-9router/luasrc/model/cbi/9router.lua" _stlu/usr/lib/lua/luci/model/cbi/9router.lua
cp "$ROOT/luci-app-9router/luasrc/view/9router/status.htm" _stlu/usr/lib/lua/luci/view/9router/status.htm
cp "$ROOT/luci-app-9router/root/usr/share/luci/menu.d/luci-app-9router.json" _stlu/usr/share/luci/menu.d/luci-app-9router.json
cp "$ROOT/luci-app-9router/root/usr/share/rpcd/acl.d/luci-app-9router.json" _stlu/usr/share/rpcd/acl.d/luci-app-9router.json
mkipk "luci-app-9router" "1.0" "all" "$ROOT/_stlu"
ls -lh "$DIST"

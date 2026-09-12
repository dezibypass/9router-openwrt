include $(TOPDIR)/rules.mk

PKG_NAME:=9router
PKG_VERSION:=0.5.75
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=https://registry.npmjs.org/$(PKG_NAME)/-/ 
PKG_HASH:=skip

PKG_BUILD_DEPENDS:=node/host
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/9router
  SECTION:=net
  CATEGORY:=Network
  TITLE:=9Router AI gateway
  URL:=https://github.com/decolua/9router
  DEPENDS:=+node +node-npm +block-mount +kmod-fs-btrfs +btrfs-progs
  ARCH:=aarch64_generic
endef

define Package/9router/description
 9Router AI router on OpenWrt. Dashboard on port 20128.
 Data dir via UCI /etc/config/9router.
endef

define Build/Compile
endef

define Package/9router/install
	$(INSTALL_DIR) $(1)/usr/share/9router
	$(CP) ./npm-pkg/* $(1)/usr/share/9router/
	$(INSTALL_DIR) $(1)/usr/bin
	$(LN) /usr/share/9router/bin/9router $(1)/usr/bin/9router
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/9router.init $(1)/etc/init.d/9router
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/9router.config $(1)/etc/config/9router
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/9router-reset-password $(1)/usr/sbin/9router-reset-password
endef

$(eval $(call BuildPackage,9router))

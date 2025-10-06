include $(TOPDIR)/rules.mk

PKG_NAME:=cherry
PKG_VERSION:=2025.09.24
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/MetaCubeX/mihomo.git
PKG_SOURCE_VERSION:=v1.19.14
PKG_MIRROR_HASH:=1b5ad012709ffe6f087a10769be6dea77b07bf8b866cdd9f8e6ab3d98c6d7986

PKG_LICENSE:=GPL3.0+
PKG_MAINTAINER:=Joseph Mory <morytyann@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

PKG_BUILD_TIME:=$(shell date -u -Iseconds)

GO_PKG:=github.com/metacubex/mihomo
GO_PKG_LDFLAGS_X:=$(GO_PKG)/constant.Version=$(PKG_SOURCE_VERSION) $(GO_PKG)/constant.BuildTime=$(PKG_BUILD_TIME)
GO_PKG_TAGS:=with_gvisor

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/cherry
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A rule based proxy in Go.
  URL:=https://wiki.metacubex.one
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle +curl +yq firewall4 +ip-full +kmod-inet-diag +kmod-nft-socket +kmod-nft-tproxy +kmod-tun
  PROVIDES:=cherry mihomo
endef

define Package/cherry/description
  A rule based proxy in Go.
endef

define Package/cherry/conffiles
/etc/config/cherry
/etc/cherry/mixin.yaml
endef

define Package/cherry/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/cherry
	$(INSTALL_DIR) $(1)/etc/cherry/ucode
	$(INSTALL_DIR) $(1)/etc/cherry/scripts
	$(INSTALL_DIR) $(1)/etc/cherry/nftables
	$(INSTALL_DIR) $(1)/etc/cherry/profiles
	$(INSTALL_DIR) $(1)/etc/cherry/subscriptions
	$(INSTALL_DIR) $(1)/etc/cherry/run
	$(INSTALL_DIR) $(1)/etc/cherry/run/providers
	$(INSTALL_DIR) $(1)/etc/cherry/run/providers/rule
	$(INSTALL_DIR) $(1)/etc/cherry/run/providers/proxy

	$(INSTALL_DATA) $(CURDIR)/files/mixin.yaml $(1)/etc/cherry/mixin.yaml

	$(INSTALL_BIN) $(CURDIR)/files/ucode/include.uc $(1)/etc/cherry/ucode/include.uc
	$(INSTALL_BIN) $(CURDIR)/files/ucode/mixin.uc $(1)/etc/cherry/ucode/mixin.uc
	$(INSTALL_BIN) $(CURDIR)/files/ucode/hijack.ut $(1)/etc/cherry/ucode/hijack.ut

	$(INSTALL_BIN) $(CURDIR)/files/scripts/include.sh $(1)/etc/cherry/scripts/include.sh
	$(INSTALL_BIN) $(CURDIR)/files/scripts/firewall_include.sh $(1)/etc/cherry/scripts/firewall_include.sh
	$(INSTALL_BIN) $(CURDIR)/files/scripts/debug.sh $(1)/etc/cherry/scripts/debug.sh

	$(INSTALL_BIN) $(CURDIR)/files/nftables/geoip_cn.nft $(1)/etc/cherry/nftables/geoip_cn.nft
	$(INSTALL_BIN) $(CURDIR)/files/nftables/geoip6_cn.nft $(1)/etc/cherry/nftables/geoip6_cn.nft

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/cherry.conf $(1)/etc/config/cherry

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/cherry.init $(1)/etc/init.d/cherry

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(CURDIR)/files/uci-defaults/firewall.sh $(1)/etc/uci-defaults/99_firewall_cherry
	$(INSTALL_BIN) $(CURDIR)/files/uci-defaults/init.sh $(1)/etc/uci-defaults/99_init_cherry
	$(INSTALL_BIN) $(CURDIR)/files/uci-defaults/migrate.sh $(1)/etc/uci-defaults/99_migrate_cherry

	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) $(CURDIR)/files/cherry.upgrade $(1)/lib/upgrade/keep.d/cherry
endef

define Package/cherry/postrm
#!/bin/sh
if [ -z $${IPKG_INSTROOT} ]; then
	uci -q batch <<-EOF > /dev/null
		del firewall.cherry
		commit firewall
	EOF
fi
endef

define Build/Prepare
	$(Build/Prepare/Default)
	$(RM) -r $(PKG_BUILD_DIR)/rules/logic_test
endef

$(eval $(call GoBinPackage,cherry))
$(eval $(call BuildPackage,cherry))

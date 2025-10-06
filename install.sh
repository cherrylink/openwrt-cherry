#!/bin/sh

# Cherry's installer

# check env
if [[ ! -x "/bin/opkg" && ! -x "/usr/bin/apk" || ! -x "/sbin/fw4" ]]; then
	echo "only supports OpenWrt build with firewall4!"
	exit 1
fi

# include openwrt_release
. /etc/openwrt_release

# get branch/arch
arch="$DISTRIB_ARCH"
branch=
case "$DISTRIB_RELEASE" in
	*"23.05"*)
		branch="openwrt-23.05"
		;;
	*"24.10"*)
		branch="openwrt-24.10"
		;;
	"SNAPSHOT")
		branch="SNAPSHOT"
		;;
	*)
		echo "unsupported release: $DISTRIB_RELEASE"
		exit 1
		;;
esac

# feed url
repository_url="https://cherrylink.pages.dev"
feed_url="$repository_url/$branch/$arch/cherry"

if [ -x "/bin/opkg" ]; then
	# update feeds
	echo "update feeds"
	opkg update
	# get languages
	echo "get languages"
	languages=$(opkg list-installed luci-i18n-base-* | cut -d ' ' -f 1 | cut -d '-' -f 4-)
	# get latest version
	echo "get latest version"
	wget -O cherry.version $feed_url/index.json
	# install ipks
	echo "install ipks"
	eval "$(jsonfilter -i cherry.version -e "cherry_version=@['packages']['cherry']" -e "luci_app_cherry_version=@['packages']['luci-app-cherry']")"
	opkg install "$feed_url/cherry_${cherry_version}_${arch}.ipk"
	opkg install "$feed_url/luci-app-cherry_${luci_app_cherry_version}_all.ipk"
	for lang in $languages; do
		lang_version=$(jsonfilter -i cherry.version -e "@['packages']['luci-i18n-cherry-${lang}']")
		opkg install "$feed_url/luci-i18n-cherry-${lang}_${lang_version}_all.ipk"
	done
	
	rm -f cherry.version
elif [ -x "/usr/bin/apk" ]; then
	# update feeds
	echo "update feeds"
	apk update
	# get languages
	echo "get languages"
	languages=$(apk list --installed --manifest luci-i18n-base-* | cut -d ' ' -f 1 | cut -d '-' -f 4-)
	# install apks from remote repository
	echo "install apks from remote repository"
	apk add --allow-untrusted -X $feed_url/packages.adb cherry luci-app-cherry
	for lang in $languages; do
		apk add --allow-untrusted -X $feed_url/packages.adb "luci-i18n-cherry-${lang}"
	done
fi

echo "success" 

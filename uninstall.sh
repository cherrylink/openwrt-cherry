#!/bin/sh

# Cherry's uninstaller

# uninstall
if [ -x "/bin/opkg" ]; then
	opkg list-installed luci-i18n-cherry-* | cut -d ' ' -f 1 | xargs opkg remove
	opkg remove luci-app-cherry
	opkg remove cherry
elif [ -x "/usr/bin/apk" ]; then
	apk list --installed --manifest luci-i18n-cherry-* | cut -d ' ' -f 1 | xargs apk del
	apk del luci-app-cherry
	apk del cherry
fi
# remove config
rm -f /etc/config/cherry
# remove files
rm -rf /etc/cherry
# remove log
rm -rf /var/log/cherry
# remove temp
rm -rf /var/run/cherry
# remove feed
if [ -x "/bin/opkg" ]; then
	if grep -q cherry /etc/opkg/customfeeds.conf; then
		sed -i '/cherry/d' /etc/opkg/customfeeds.conf
	fi
	wget -O "cherry.pub" "https://cherrylink.pages.dev/key-build.pub"
	opkg-key remove cherry.pub
	rm -f cherry.pub
elif [ -x "/usr/bin/apk" ]; then
	if grep -q cherry /etc/apk/repositories.d/customfeeds.list; then
		sed -i '/cherry/d' /etc/apk/repositories.d/customfeeds.list
	fi
	rm -f /etc/apk/keys/cherry.pem
fi

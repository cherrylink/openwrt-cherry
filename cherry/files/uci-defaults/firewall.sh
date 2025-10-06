#!/bin/sh

. "$IPKG_INSTROOT/etc/cherry/scripts/include.sh"

uci -q batch <<-EOF > /dev/null
	del firewall.cherry
	set firewall.cherry=include
	set firewall.cherry.type=script
	set firewall.cherry.path=$FIREWALL_INCLUDE_SH
	set firewall.cherry.fw4_compatible=1
	commit firewall
EOF

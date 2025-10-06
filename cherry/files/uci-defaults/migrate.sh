#!/bin/sh

. "$IPKG_INSTROOT/etc/cherry/scripts/include.sh"

# since v1.18.0

mixin_rule=$(uci -q get cherry.mixin.rule); [ -z "$mixin_rule" ] && uci set cherry.mixin.rule=0

mixin_rule_provider=$(uci -q get cherry.mixin.rule_provider); [ -z "$mixin_rule_provider" ] && uci set cherry.mixin.rule_provider=0

# since v1.19.0

mixin_ui_path=$(uci -q get cherry.mixin.ui_path); [ -z "$mixin_ui_path" ] && uci set cherry.mixin.ui_path=ui

uci show cherry | grep -E 'cherry\.@rule\[[[:digit:]]+\].match=' | sed 's/cherry.@rule\[\([[:digit:]]\+\)\].match=.*/rename cherry.@rule[\1].match=matcher/' | uci batch

# since v1.19.1

proxy_fake_ip_ping_hijack=$(uci -q get cherry.proxy.fake_ip_ping_hijack); [ -z "$proxy_fake_ip_ping_hijack" ] && uci set cherry.proxy.fake_ip_ping_hijack=0

# since v1.20.0

mixin_api_port=$(uci -q get cherry.mixin.api_port); [ -n "$mixin_api_port" ] && {
	uci del cherry.mixin.api_port
	uci set cherry.mixin.api_listen="[::]:$mixin_api_port"
}

mixin_dns_port=$(uci -q get cherry.mixin.dns_port); [ -n "$mixin_dns_port" ] && {
	uci del cherry.mixin.dns_port
	uci set cherry.mixin.dns_listen="[::]:$mixin_dns_port"
}

# since v1.22.0

proxy_transparent_proxy=$(uci -q get cherry.proxy.transparent_proxy); [ -n "$proxy_transparent_proxy" ] && {
	uci rename cherry.proxy.transparent_proxy=enabled
	uci rename cherry.proxy.tcp_transparent_proxy_mode=tcp_mode
	uci rename cherry.proxy.udp_transparent_proxy_mode=udp_mode

	uci add cherry router_access_control
	uci set cherry.@router_access_control[-1].enabled=1
	proxy_bypass_user=$(uci -q get cherry.proxy.bypass_user); [ -n "$proxy_bypass_user" ] && {
		for router_access_control_user in $proxy_bypass_user; do
			uci add_list cherry.@router_access_control[-1].user="$router_access_control_user"
		done
	}
	proxy_bypass_group=$(uci -q get cherry.proxy.bypass_group); [ -n "$proxy_bypass_group" ] && {
		for router_access_control_group in $proxy_bypass_group; do
			uci add_list cherry.@router_access_control[-1].group="$router_access_control_group"
		done
	}
	proxy_bypass_cgroup=$(uci -q get cherry.proxy.bypass_cgroup); [ -n "$proxy_bypass_cgroup" ] && {
		for router_access_control_cgroup in $proxy_bypass_cgroup; do
			uci add_list cherry.@router_access_control[-1].cgroup="$router_access_control_cgroup"
		done
	}
	uci set cherry.@router_access_control[-1].proxy=0

	uci add cherry router_access_control
	uci set cherry.@router_access_control[-1].enabled=1
	uci set cherry.@router_access_control[-1].proxy=1

	uci add_list cherry.proxy.lan_inbound_interface=lan

	proxy_access_control_mode=$(uci -q get cherry.proxy.access_control_mode)

	[ "$proxy_access_control_mode" != "all" ] && {
		proxy_acl_ip=$(uci -q get cherry.proxy.acl_ip); [ -n "$proxy_acl_ip" ] && {
			for ip in $proxy_acl_ip; do
				uci add cherry lan_access_control
				uci set cherry.@lan_access_control[-1].enabled=1
				uci add_list cherry.@lan_access_control[-1].ip="$ip"
				[ "$proxy_access_control_mode" = "allow" ] && uci set cherry.@lan_access_control[-1].proxy=1
				[ "$proxy_access_control_mode" = "block" ] && uci set cherry.@lan_access_control[-1].proxy=0
			done
		}
		proxy_acl_ip6=$(uci -q get cherry.proxy.acl_ip6); [ -n "$proxy_acl_ip6" ] && {
			for ip6 in $proxy_acl_ip6; do
				uci add cherry lan_access_control
				uci set cherry.@lan_access_control[-1].enabled=1
				uci add_list cherry.@lan_access_control[-1].ip6="$ip6"
				[ "$proxy_access_control_mode" = "allow" ] && uci set cherry.@lan_access_control[-1].proxy=1
				[ "$proxy_access_control_mode" = "block" ] && uci set cherry.@lan_access_control[-1].proxy=0
			done
		}
		proxy_acl_mac=$(uci -q get cherry.proxy.acl_mac); [ -n "$proxy_acl_mac" ] && {
			for mac in $proxy_acl_mac; do
				uci add cherry lan_access_control
				uci set cherry.@lan_access_control[-1].enabled=1
				uci add_list cherry.@lan_access_control[-1].mac="$mac"
				[ "$proxy_access_control_mode" = "allow" ] && uci set cherry.@lan_access_control[-1].proxy=1
				[ "$proxy_access_control_mode" = "block" ] && uci set cherry.@lan_access_control[-1].proxy=0
			done
		}
	}

	[ "$proxy_access_control_mode" != "allow" ] && {
		uci add cherry lan_access_control
		uci set cherry.@lan_access_control[-1].enabled=1
		uci set cherry.@lan_access_control[-1].proxy=1
	}

	uci del cherry.proxy.access_control_mode
	uci del cherry.proxy.acl_ip
	uci del cherry.proxy.acl_ip6
	uci del cherry.proxy.acl_mac
	uci del cherry.proxy.acl_interface
	uci del cherry.proxy.bypass_user
	uci del cherry.proxy.bypass_group
	uci del cherry.proxy.bypass_cgroup
}

# since v1.23.0

routing=$(uci -q get cherry.routing); [ -z "$routing" ] && {
	uci set cherry.routing=routing
	uci set cherry.routing.tproxy_fw_mark=0x80
	uci set cherry.routing.tun_fw_mark=0x81
	uci set cherry.routing.tproxy_rule_pref=1024
	uci set cherry.routing.tun_rule_pref=1025
	uci set cherry.routing.tproxy_route_table=80
	uci set cherry.routing.tun_route_table=81
	uci set cherry.routing.cgroup_id=0x12061206
	uci set cherry.routing.cgroup_name=cherry
}

proxy_tun_timeout=$(uci -q get cherry.proxy.tun_timeout); [ -z "$proxy_tun_timeout" ] && uci set cherry.proxy.tun_timeout=30

proxy_tun_interval=$(uci -q get cherry.proxy.tun_interval); [ -z "$proxy_tun_interval" ] && uci set cherry.proxy.tun_interval=1

# since v1.23.1

uci show cherry | grep -o -E 'cherry\.@router_access_control\[[[:digit:]]+\]=router_access_control' | cut -d '=' -f 1 | while read -r router_access_control; do
	for router_access_control_cgroup in $(uci -q get "$router_access_control.cgroup"); do
		[ -d "/sys/fs/cgroup/$router_access_control_cgroup" ] && continue
		[ -d "/sys/fs/cgroup/services/$router_access_control_cgroup" ] && {
			uci del_list "$router_access_control.cgroup=$router_access_control_cgroup"
			uci add_list "$router_access_control.cgroup=services/$router_access_control_cgroup"
		}
	done
done

# since v1.23.2

env_disable_safe_path_check=$(uci -q get cherry.env.disable_safe_path_check); [ -n "$env_disable_safe_path_check" ] && uci del cherry.env.disable_safe_path_check

env_skip_system_ipv6_check=$(uci -q get cherry.env.skip_system_ipv6_check); [ -z "$env_skip_system_ipv6_check" ] && uci set cherry.env.skip_system_ipv6_check=0

# since v1.23.3

uci show cherry | grep -o -E 'cherry\.@router_access_control\[[[:digit:]]+\]=router_access_control' | cut -d '=' -f 1 | while read -r router_access_control; do
	router_access_control_proxy=$(uci -q get "$router_access_control.proxy")
	router_access_control_dns=$(uci -q get "$router_access_control.dns")
	[ -z "$router_access_control_dns" ] && uci set "$router_access_control.dns=$router_access_control_proxy"
done

uci show cherry | grep -o -E 'cherry\.@lan_access_control\[[[:digit:]]+\]=lan_access_control' | cut -d '=' -f 1 | while read -r lan_access_control; do
	lan_access_control_proxy=$(uci -q get "$lan_access_control.proxy")
	lan_access_control_dns=$(uci -q get "$lan_access_control.dns")
	[ -z "$lan_access_control_dns" ] && uci set "$lan_access_control.dns=$lan_access_control_proxy"
done

# since v1.24.0

proxy_reserved_ip=$(uci -q get cherry.proxy.reserved_ip); [ -z "$proxy_reserved_ip" ] && {
	uci add_list cherry.proxy.reserved_ip=0.0.0.0/8
	uci add_list cherry.proxy.reserved_ip=10.0.0.0/8
	uci add_list cherry.proxy.reserved_ip=127.0.0.0/8
	uci add_list cherry.proxy.reserved_ip=100.64.0.0/10
	uci add_list cherry.proxy.reserved_ip=169.254.0.0/16
	uci add_list cherry.proxy.reserved_ip=172.16.0.0/12
	uci add_list cherry.proxy.reserved_ip=192.168.0.0/16
	uci add_list cherry.proxy.reserved_ip=224.0.0.0/4
	uci add_list cherry.proxy.reserved_ip=240.0.0.0/4
}

proxy_reserved_ip6=$(uci -q get cherry.proxy.reserved_ip6); [ -z "$proxy_reserved_ip6" ] && {
	uci add_list cherry.proxy.reserved_ip6=::/128
	uci add_list cherry.proxy.reserved_ip6=::1/128
	uci add_list cherry.proxy.reserved_ip6=::ffff:0:0/96
	uci add_list cherry.proxy.reserved_ip6=100::/64
	uci add_list cherry.proxy.reserved_ip6=64:ff9b::/96
	uci add_list cherry.proxy.reserved_ip6=2001::/32
	uci add_list cherry.proxy.reserved_ip6=2001:10::/28
	uci add_list cherry.proxy.reserved_ip6=2001:20::/28
	uci add_list cherry.proxy.reserved_ip6=2001:db8::/32
	uci add_list cherry.proxy.reserved_ip6=2002::/16
	uci add_list cherry.proxy.reserved_ip6=fc00::/7
	uci add_list cherry.proxy.reserved_ip6=fe80::/10
	uci add_list cherry.proxy.reserved_ip6=ff00::/8
}

# commit
uci commit cherry

# exit with 0
exit 0

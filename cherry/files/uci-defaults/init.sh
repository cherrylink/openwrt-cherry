#!/bin/sh

. "$IPKG_INSTROOT/etc/cherry/scripts/include.sh"

# check cherry.config.init
init=$(uci -q get cherry.config.init); [ -z "$init" ] && return

# generate random string for api secret and authentication password
random=$(awk 'BEGIN{srand(); print int(rand() * 1000000)}')

# set cherry.mixin.api_secret
uci set cherry.mixin.api_secret="$random"

# set cherry.@authentication[0].password
uci set cherry.@authentication[0].password="$random"

# remove cherry.config.init
uci del cherry.config.init

# commit
uci commit cherry

# exit with 0
exit 0

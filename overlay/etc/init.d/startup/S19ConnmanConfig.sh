#!/bin/sh

WIFI_CONFIG_PATH=/var/lib/connman/wifi.config
WIFI_AP_NAME=`cat /etc/wifi.ap`
WIFI_AP_PASS=`cat /etc/wifi.passwd`

echo "[service_wifi]
Type=wifi
Name=$WIFI_AP_NAME
Passphrase=$WIFI_AP_PASS
IPv4.method=dhcp
" > $WIFI_CONFIG_PATH

echo "Connman wifi.config created"
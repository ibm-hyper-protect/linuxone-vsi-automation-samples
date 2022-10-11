#!/bin/sh
openvpn --config /vpn/vpn.ovpn &
sleep 15s
rm -f index.html
wget <address>:<port>
cat index.html
killall openvp

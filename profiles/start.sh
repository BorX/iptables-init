#!/usr/bin/env bash

source "$PROFILES_DIR/clear.sh"

moduleHelper_enable "$MODULES_DIR/related-logging"
moduleHelper_enable "$MODULES_DIR/local"

iptablesInit_splitTcpUdp

moduleHelper_enable "$MODULES_DIR/bootps-bootpc"
moduleHelper_enable "$MODULES_DIR/in-ssh"
moduleHelper_enable "$MODULES_DIR/out-dns"
moduleHelper_enable "$MODULES_DIR/out-http"
moduleHelper_enable "$MODULES_DIR/out-https"
moduleHelper_enable "$MODULES_DIR/out-newbiecontest"
moduleHelper_enable "$MODULES_DIR/out-ntp"
moduleHelper_enable "$MODULES_DIR/out-smtp"
moduleHelper_enable "$MODULES_DIR/out-ssh"
moduleHelper_enable "$MODULES_DIR/out-whois"
moduleHelper_enable "$MODULES_DIR/icmp"
moduleHelper_enable "$MODULES_DIR/out-ping"
moduleHelper_enable "$MODULES_DIR/logging"
moduleHelper_enable "$MODULES_DIR/security"

moduleHelper_enable "$MODULES_DIR/blacklist"
moduleHelper_enable "$MODULES_DIR/in-port_knocking"

for command in ip6tables iptables; do
	for chain in INPUT OUTPUT FORWARD; do
		$command --table filter --policy $chain DROP
	done
done

source "$PROFILES_DIR/status.sh"

echo
echo "La configuration sera annulée dans 60 secondes."
echo "Appuyer sur CTRL-C pour l'appliquer définitivement..."
sleep 60
source "$PROFILES_DIR/clear.sh"


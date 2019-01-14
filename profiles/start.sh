#!/usr/bin/env bash

source "$PROFILES_DIR/clear.sh"

source "$PROFILES_DIR/start/02_related-logging"
source "$PROFILES_DIR/start/04_local"

splitTcpUdp

readonly action='add'
readonly actFlg='-A'
source "$MODULES_DIR/bootps-bootpc"
source "$MODULES_DIR/in-ssh"
source "$MODULES_DIR/out-dns"
source "$MODULES_DIR/out-http"
source "$MODULES_DIR/out-https"
source "$MODULES_DIR/out-newbiecontest"
source "$MODULES_DIR/out-ntp"
source "$MODULES_DIR/out-smtp"
source "$MODULES_DIR/out-ssh"
source "$MODULES_DIR/out-whois"
source "$MODULES_DIR/icmp"
source "$PROFILES_DIR/start/35_out-ping"
source "$PROFILES_DIR/start/70_logging"
source "$PROFILES_DIR/start/81_security"

source "$PROFILES_DIR/start/84_blacklist"
source "$MODULES_DIR/in-port_knocking"

for command in ip6tables iptables; do
	for chain in INPUT OUTPUT FORWARD; do
		$command -P $chain DROP
	done
done

source "$PROFILES_DIR/status.sh"
echo
echo "La configuration sera annulée dans 60 secondes."
echo "Appuyer sur CTRL-C pour l'appliquer définitivement..."
sleep 60
source "$PROFILES_DIR/clear.sh"


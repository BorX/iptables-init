#!/usr/bin/env bash

source "$PROFILES_DIR/clear.sh"

source "$PROFILES_DIR/start/02_related-logging"
source "$PROFILES_DIR/start/04_local"

splitTcpUdp

source "$PROFILES_DIR/start/10_rules-default-action"
source "$RULES_DIR/bootps-bootpc"
source "$RULES_DIR/in-ssh"
source "$RULES_DIR/out-dns"
source "$RULES_DIR/out-http"
source "$RULES_DIR/out-https"
source "$RULES_DIR/out-newbiecontest"
source "$RULES_DIR/out-ntp"
source "$RULES_DIR/out-smtp"
source "$RULES_DIR/out-ssh"
source "$RULES_DIR/out-whois"
source "$RULES_DIR/icmp"
source "$PROFILES_DIR/start/35_out-ping"
source "$PROFILES_DIR/start/70_logging"
source "$PROFILES_DIR/start/81_security"

source "$PROFILES_DIR/start/84_blacklist"
source "$RULES_DIR/in-port_knocking"

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


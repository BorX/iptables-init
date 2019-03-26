#!/usr/bin/env bash

loadProfile clear

enmod related-logging
enmod local
enmod splitTcpUdp
enmod bootps-bootpc
enmod in-ssh
enmod out-dns
enmod out-http
enmod out-https
enmod out-newbiecontest
enmod out-ntp
enmod out-smtp
enmod out-ssh
enmod out-whois
enmod icmp
enmod out-ping
enmod logging
enmod security
enmod blacklist
enmod in-port_knocking

for command in ip6tables iptables; do
	for chain in INPUT OUTPUT FORWARD; do
		$command --table filter --policy $chain DROP
	done
done

loadProfile status

echo
echo "La configuration sera annulée dans 60 secondes."
echo "Appuyer sur CTRL-C pour l'appliquer définitivement..."
sleep 60
loadProfile clear


#!/usr/bin/env bash

enmod backup

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
echo "Une sauvegarde de la configuration précédente sera appliquée dans 30 secondes."
echo "Appuyer sur CTRL-C pour appliquer définitivement la nouvelle configuration..."
sleep 30
dismod backup
echo
echo "La nouvelle configuration a été annulée par une restauration de la sauvegarde précédente."

echo
echo "Un nettoyage de toutes les tables sera appliqué dans 30 secondes."
echo "Appuyer sur CTRL-C pour garder la configuration actuelle..."
sleep 30
loadProfile clear


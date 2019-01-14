#!/usr/bin/env bash

for command in ip6tables iptables; do
	for table in security raw mangle nat filter; do
		printf "====================================================== %-9s %8s ======================================================\n" "$command" "$table"
		$command --table $table -nvL
	done
done

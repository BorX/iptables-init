#!/usr/bin/env bash

for command in ip6tables iptables; do
	for table in security raw mangle nat filter; do
		$command --table $table --zero
	done
done

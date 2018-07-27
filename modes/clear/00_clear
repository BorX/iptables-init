#!/usr/bin/env bash

declare -A tables
tables=(['security']='INPUT FORWARD OUTPUT' ['raw']='PREROUTING OUTPUT' ['mangle']='PREROUTING INPUT FORWARD OUTPUT POSTROUTING' ['nat']='PREROUTING INPUT OUTPUT POSTROUTING' ['filter']='INPUT FORWARD OUTPUT')

for command in iptables ip6tables; do
	for table in security raw mangle nat filter; do
		for chain in ${tables[$table]}; do
			$command --table $table --policy $chain ACCEPT
		done
	done
done

for table in security raw mangle nat filter; do
	ip6tables --table $table -F
	ip6tables --table $table -X
done

for table in security raw mangle; do
	iptables --table $table -F
	iptables --table $table -X
done

keepDocker=true
if $keepDocker; then
	# Flush all chains but FORWARD and docker chains
	iptables -nL | sed -n 's/^Chain \([^ ]*\) .*/\1/p' | grep -vi docker | grep -v '^FORWARD$'                   | xargs -rn1 iptables -F

	# Delete all rules in FORWARD but docker rules
	iptables --line-numbers -nvL FORWARD | grep -iv docker | awk 'NR>2{print $1}' | sort -rn                     | xargs -rn1 iptables -D FORWARD 

	# Delete all chains but INPUT, OUTPUT, FORWARD and docker chains
	iptables -nL | sed -n 's/^Chain \([^ ]*\) .*/\1/p' | grep -vi docker | grep -vE '^INPUT$|^OUTPUT$|^FORWARD$' | xargs -rn1 iptables -X
else
	for table in nat filter; do
		iptables --table $table -F
		iptables --table $table -X
	done
fi

iptables-init v4
================

Command line
------------
```
iptables-init/init [ -h | --help ]
iptables-init/init [ -f | --file ConfFile ] [ -q | --quiet ] [ --network-interface iface ] [ --trusted-list '@ip [ @ip [ ... ] ]' ] [ --trusted-icmp '@ip [ @ip [ ... ] ]' ] start
iptables-init/init stop | status | blupd | cron | monitor
iptables-init/init bladd @ip [ @ip [ ... ] ]
```

Default behavior
----------------
Works without config file (just the script).
Default config file in /etc/default/iptables-init (another one can by specified by command line).

ipset is optional
-----------------
Works if [ipset](http://ipset.netfilter.org/) is not installed.

ToDo
----
External directory for easy add-ons
Service launched at startup


iptables-init v3
================
Shell script to easily initialize iptables rules by incorporating recurrent security.

Simplification
--------------
Compared to [v2](https://github.com/BorX/iptables-init/tree/v2.1), too generic, this version is oriented for staying simple.

ipset
-----
[ipset](http://ipset.netfilter.org/) is used to manage sets of IPs (blacklisted, allowed on SSH port, ICMP, ...).

IPv6 management
---------------
All is closed.

Blacklists management
---------------------
Inspired by [trick77/ipset-blacklist](https://github.com/trick77/ipset-blacklist).  
The blacklist is refreshed from sets of blacklists downloaded from the internet.  
Instead of 1 blacklisted IP = 1 rule, all blacklisted IPs are referenced in one set managed by ipset.

Logging
-------
The previous version was too verbose.  
`iptables -vL` is enough to understand which rule accepts or drops any packet.

ToDo
----
No need to adapt script (use of config file or use of ipset)

Example of result
-----------------
```
# iptables -nvL
Chain INPUT (policy DROP 140 packets, 11232 bytes)
 pkts bytes target     prot opt in     out     source               destination
    1    40 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* BlackList    */ match-set blacklist src,dst
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* No multicast */ PKTTYPE = multicast
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* No broadcast */ PKTTYPE = broadcast
 2324  323K TCP_IN     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* Split TCP    */
  100 11306 UDP_IN     udp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* Split UDP    */
  240  7680 ACCEPT     icmp --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* ICMP         */ match-set icmp src
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* NO_LOG_POLLUTION:Port  21 */ tcp dpt:21
    4   172 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* NO_LOG_POLLUTION:Port  23 */ tcp dpt:23
    6   240 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* NO_LOG_POLLUTION:Port  80 */ tcp dpt:80
    6   264 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* NO_LOG_POLLUTION:Port 443 */ tcp dpt:443
  140 11232 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Logs                      */ LOG flags 0 level 4 prefix " [INPUT DROPPED] "

Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* BlackList    */ match-set blacklist src,dst
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* No multicast */ PKTTYPE = multicast
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* No broadcast */ PKTTYPE = broadcast
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x06/0x06
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x3F/0x00
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x3F/0x3F
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x29/0x29

Chain OUTPUT (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* BlackList    */ match-set blacklist src,dst
 2014  231K TCP_OUT    tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* Split TCP    */
   17  1138 UDP_OUT    udp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* Split UDP    */
  240  7680 ACCEPT     icmp --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* ICMP         */ match-set icmp dst
    0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Logs         */ LOG flags 0 level 4 prefix "[OUTPUT DROPPED] "

Chain TCP_IN (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x06/0x06
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x3F/0x00
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x3F/0x3F
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x29/0x29
 2162  140K ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /*  IN SSH             */ tcp dpt:443 match-set trustedLst src
  136  180K ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT HTTP            */ tcp spt:80 ctstate RELATED,ESTABLISHED
    0     0 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT HTTPS           */ tcp spt:443 ctstate RELATED,ESTABLISHED
    0     0 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT SMTP            */ tcp spt:25 ctstate RELATED,ESTABLISHED
    6  3032 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT Whois           */ tcp spt:43 ctstate RELATED,ESTABLISHED
    0     0 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT Whois           */ tcp spt:4321 ctstate RELATED,ESTABLISHED
    0     0 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT SSH             */ tcp spt:22 ctstate RELATED,ESTABLISHED

Chain TCP_OUT (1 references)
 pkts bytes target     prot opt in     out     source               destination
 1919  224K ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /*  IN SSH             */ tcp spt:443 match-set trustedLst dst ctstate RELATED,ESTABLISHED
   89  7559 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT HTTP            */ tcp dpt:80
    0     0 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT HTTPS           */ tcp dpt:443
    0     0 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT SMTP            */ tcp dpt:25
    6   339 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT Whois           */ tcp dpt:43
    0     0 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT Whois           */ tcp dpt:4321
    0     0 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT SSH             */ tcp dpt:22

Chain UDP_IN (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     udp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT NTP             */ udp spt:123 ctstate RELATED,ESTABLISHED
   14  3394 ACCEPT     udp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT DNS             */ udp spt:53 ctstate RELATED,ESTABLISHED

Chain UDP_OUT (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     udp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT NTP             */ udp dpt:123
   17  1138 ACCEPT     udp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT DNS             */ udp dpt:53
```


===============================================================================


iptables-init v2
================

All details are in the [wiki](https://github.com/BorX/iptables-init/wiki).

Tous les détails sont dans le [wiki](https://github.com/BorX/iptables-init/wiki).


Objectifs
---------

### Préconfigurer les règles contre les attaques les plus courantes
Ce script ajoute à la table filter les règles conseillées par un important nombre de références en sécurité sur le web (cf. [wiki](https://github.com/BorX/iptables-init/wiki) pour les détails).
XMAS, NULL-NULL, paquets fragmentés, flood, ...
cf. [fichier iptables_filter](https://github.com/BorX/iptables-init/blob/master/iptables_filter)


### Tracer efficacement dans les fichiers de log les paquets bloqués
Les fonctions développées dans ce script font que chaque règle dispose d'un identifiant propre lui permettant d'être distinguée dans les logs.
Ainsi, il est aisé de retrouver la règle correspondant à une trace iptables dans les logs.
cf. [wiki](https://github.com/BorX/iptables-init/wiki) : Exemple de configuration iptables initialisée par ce script


### Organiser l’administration des règles Iptables

Ce script se distingue des autres scripts d'initialisation d'iptables.
Son organisation modulaire le rend plus simple à comprendre, à modifier et donc à faire évoluer.
Il permet notamment de :

- distinguer l’administration des règles Iptables pour les différentes tables (raw, nat, mangle, filter)
Ce script permet de modifier la configuration d'une table principale d'iptables en ne touchant qu'au fichier correspondant.  Les fichiers correspondant aux autres tables ne sont pas touchés.
Cette organisation est particulièrement intéressante pour gérer ses scripts en configuration (meilleur suivi, versionning optimisé, simplification du branching, ...).
cf. [wiki](https://github.com/BorX/iptables-init/wiki) : Schéma de fonctionnement global de Netfilter

- distinguer l’administration des règles personnelles de l’administration des règles communes
Ce script propose une organisation de découpage modulaire permettant d'isoler ses propres règles iptables des autres règles.
cf. [wiki](https://github.com/BorX/iptables-init/wiki) : Schéma de fonctionnement de la chaîne Filter/INPUT
cf. [fichier iptables_perso](https://github.com/BorX/iptables-init/blob/master/iptables_perso)

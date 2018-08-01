iptables-init v5
================

- All tables management (security, raw, mangle, nat, filter)
- Management by profiles (customizable)
- Easy loading of pre-configured rules
- Efficient Blacklists : Static blacklist refreshed everyday from internet + Live blacklist from abusing attempts


```
# /etc/iptables/init/init
usages:
/etc/iptables/init/init status
/etc/iptables/init/init profiles
/etc/iptables/init/init [ -f | --file ConfFile ] [ -q | --quiet ] [ --network-interface iface ] [ --trusted-list '@ip [ ... ]' ] [ --trusted-icmp '@ip [ ... ]' ] profile profilename
/etc/iptables/init/init rules
/etc/iptables/init/init [ -f | --file ConfFile ] [ -q | --quiet ] [ --network-interface iface ] [ --trusted-list '@ip [ ... ]' ] [ --trusted-icmp '@ip [ ... ]' ]  add | del  rule [ ... ]
/etc/iptables/init/init [ -h | --help ]
```
```
# /etc/iptables/init/blacklistctl
usages:
/etc/iptables/init/blacklistctl update | preparecrontab
/etc/iptables/init/blacklistctl bladd @ip [ @ip [ ... ] ]
```

Blacklists
----------

### Static
Inspired by [trick77/ipset-blacklist](https://github.com/trick77/ipset-blacklist).
The blacklist is refreshed from sets of blacklists downloaded from the internet.
#### Manual
```
# /etc/iptables/init/blacklistctl update
Blacklist refreshed in 52 seconds. 107459 -> 111157 (+3698)
```
#### Crontab
```
# /etc/iptables/init/blacklistctl preparecrontab
```
This will add this comment in crontab and will edit it:
```
#00 07 * * * /etc/iptables/init/blacklistctl update
```
Just uncomment it and blacklist will be refreshed every morning:
```
Date: Mon, 16 Jul 2018 07:00:52 +0200
From: Cron Daemon <root@myserver>
To: root@myserver
Subject: Cron <root@myserver> /etc/iptables/init/blacklistctl update

Blacklist refreshed in 51 seconds. 135419 -> 141886 (+6467)
```


### Live
4 bad attempts in 10 minutes -> @IP blocked by 'raw' table
#### Table raw - Chain PREROUTING
```
target     prot opt in     out     source               destination         
DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* BlackListLive */ match-set blacklist-live src,dst
DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* BlackList     */ match-set blacklist src,dst
```

#### Table filter - Chain INPUT
```
target     prot opt in     out     source               destination         
           all  --  *      *       0.0.0.0/0            0.0.0.0/0            recent: SET name: blacklist side: source mask: 255.255.255.255
BLACKLIST  all  --  *      *       0.0.0.0/0            0.0.0.0/0            recent: UPDATE seconds: 600 hit_count: 4 name: blacklist side: source mask: 255.255.255.255
```

#### Table filter - Chain BLACKLIST
```
target     prot opt in     out     source               destination         
RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            match-set trustedLst src,dst recent: REMOVE name: blacklist side: source mask: 255.255.255.255
LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            LOG flags 0 level 4 prefix "      [BLACKLIST] "
SET        all  --  *      *       0.0.0.0/0            0.0.0.0/0            add-set blacklist-live src
```


Profiles
-----
```
# /etc/iptables/init/init profiles
+- clear
|   +- 00_clear
|   +- 99_status
|   |   +- 00_status
+- start
|   +- 00_clear
|   |   +- 00_clear
|   |   +- 99_status
|   |   |   +- 00_status
|   +- 04_local
|   +- 05_split-tcp-upd
|   +- 10_rules-default-action
|   +- 11_in-ssh
|   +- 11_out-dns
|   +- 11_out-http
|   +- 11_out-https
|   +- 11_out-ntp
|   +- 11_out-smtp
|   +- 11_out-ssh
|   +- 11_out-whois
|   +- 30_icmp
|   +- 70_logging
|   +- 81_security
|   +- 84_blacklist
|   +- 87_default-policies
|   +- 96_status
|   |   +- 00_status
|   +- 97_wait
|   +- 98_clear
|   |   +- 00_clear
|   |   +- 99_status
|   |   |   +- 00_status
+- status
|   +- 00_status
```

### Profile 'status'
- Just calls one script (step 00)

### Profile 'clear'
- Calls one script (step 00)
- Invokes profile 'status' (step 99)

### Profile 'start'
- Invokes, at step 00, profile 'clear' (including profile 'status')
- Executes different scripts
- Invokes, at step 96, profile 'status'
- Executes, a step 97, a "wait" script (60 seconds to press Ctrl+c before a new invoke of profile 'clear', to prevent connection blocking)

### Profile configuration

#### How profile 'start' is configured ?
```
# ls -la /etc/iptables/init/profiles/clear/
total 12
drwx------ 2 root root 4096 juil.  6 18:48 ./
drwx------ 7 root root 4096 juil.  6 11:27 ../
-rw------- 1 root root 1373 juil.  6 17:58 00_clear
lrwxrwxrwx 1 root root    9 juil.  6 11:55 99_status -> ../status/
```

#### How profile 'start' is configured ?
```
# ls -la /etc/iptables/init/profiles/start/
total 48
drwx------ 2 root root 4096 juil. 10 18:14 ./
drwx------ 7 root root 4096 juil.  6 11:27 ../
lrwxrwxrwx 1 root root    8 juil.  6 14:22 00_clear -> ../clear/
-rw------- 1 root root  164 juil.  6 18:31 04_local
-rw------- 1 root root  383 juil.  6 15:21 05_split-tcp-upd
-rw------- 1 root root   47 juil. 10 15:29 10_rules-default-action
lrwxrwxrwx 1 root root   18 juil.  6 14:48 11_in-ssh -> ../../rules/in-ssh
lrwxrwxrwx 1 root root   19 juil.  6 14:48 11_out-dns -> ../../rules/out-dns
lrwxrwxrwx 1 root root   20 juil.  6 14:48 11_out-http -> ../../rules/out-http
lrwxrwxrwx 1 root root   21 juil.  6 14:48 11_out-https -> ../../rules/out-https
lrwxrwxrwx 1 root root   19 juil.  6 14:48 11_out-ntp -> ../../rules/out-ntp
lrwxrwxrwx 1 root root   20 juil.  6 14:48 11_out-smtp -> ../../rules/out-smtp
lrwxrwxrwx 1 root root   19 juil.  6 14:48 11_out-ssh -> ../../rules/out-ssh
lrwxrwxrwx 1 root root   21 juil.  6 14:48 11_out-whois -> ../../rules/out-whois
lrwxrwxrwx 1 root root   16 juil.  6 17:44 30_icmp -> ../../rules/icmp
-rw------- 1 root root  558 juin   8 18:02 70_logging
-rw------- 1 root root  807 juin   8 15:35 81_security
-rw------- 1 root root 1106 juil.  6 00:37 84_blacklist
-rw------- 1 root root  188 juil.  6 15:21 87_default-policies
lrwxrwxrwx 1 root root    9 juil.  6 14:23 96_status -> ../status/
-rw------- 1 root root  153 juil.  6 15:30 97_wait
lrwxrwxrwx 1 root root    8 juil.  6 15:28 98_clear -> ../clear/
```

It's easy to change this profile or to create a new profile
```
cp -a /etc/iptables/init/profiles/start/ /etc/iptables/init/profiles/new_profile/
```


Rules
-----
```
# /etc/iptables/init/init rules
icmp
in-ssh
out-dns
out-http
out-https
out-ntp
out-smtp
out-ssh
out-whois
```

```
# /etc/iptables/init/init del out-ssh
# /etc/iptables/init/init add out-ssh
```


Status
-----
In profile 'clear'
```
# /etc/iptables/init/init status
================================= ip6tables security =================================
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= ip6tables      raw =================================
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= ip6tables   mangle =================================
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= ip6tables      nat =================================
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= ip6tables   filter =================================
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= iptables  security =================================
Chain INPUT (policy ACCEPT 1 packets, 52 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= iptables       raw =================================
Chain PREROUTING (policy ACCEPT 1 packets, 52 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= iptables    mangle =================================
Chain PREROUTING (policy ACCEPT 1 packets, 52 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 1 packets, 52 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= iptables       nat =================================
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= iptables    filter =================================
Chain INPUT (policy ACCEPT 1 packets, 52 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
```

In profile 'start'
```
# /etc/iptables/init/init status
================================= ip6tables security =================================
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= ip6tables      raw =================================
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= ip6tables   mangle =================================
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= ip6tables      nat =================================
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= ip6tables   filter =================================
Chain INPUT (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= iptables  security =================================
Chain INPUT (policy ACCEPT 163 packets, 15972 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 140 packets, 28797 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= iptables       raw =================================
Chain PREROUTING (policy ACCEPT 163 packets, 15972 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    8   256 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* BlackListLive */ match-set blacklist-live src,dst
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* BlackList     */ match-set blacklist src,dst

Chain OUTPUT (policy ACCEPT 140 packets, 28797 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= iptables    mangle =================================
Chain PREROUTING (policy ACCEPT 163 packets, 15972 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 163 packets, 15972 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 140 packets, 28797 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 140 packets, 28797 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= iptables       nat =================================
Chain PREROUTING (policy ACCEPT 1 packets, 60 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 1 packets, 60 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 16 packets, 1109 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 16 packets, 1109 bytes)
 pkts bytes target     prot opt in     out     source               destination         
================================= iptables    filter =================================
Chain INPUT (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* No multicast */ PKTTYPE = multicast
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* No broadcast */ PKTTYPE = broadcast
    0     0 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0            /* Local        */
  148 14280 TCP_IN     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Split TCP    */
   15  1692 UDP_IN     udp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Split UDP    */
    0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Logs         */ LOG flags 0 level 4 prefix "  [INPUT DROPPED] "
    0     0            all  --  *      *       0.0.0.0/0            0.0.0.0/0            recent: SET name: blacklist side: source mask: 255.255.255.255
    0     0 BLACKLIST  all  --  *      *       0.0.0.0/0            0.0.0.0/0            recent: UPDATE seconds: 600 hit_count: 4 name: blacklist side: source mask: 255.255.255.255

Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* No multicast */ PKTTYPE = multicast
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* No broadcast */ PKTTYPE = broadcast
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x06/0x06
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x3F/0x00
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x3F/0x3F
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x29/0x29
    0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Logs         */ LOG flags 0 level 4 prefix "[FORWARD DROPPED] "

Chain OUTPUT (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* BlackListLive */ match-set blacklist-live src,dst
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* BlackList     */ match-set blacklist src,dst
    0     0 ACCEPT     all  --  *      lo      0.0.0.0/0            0.0.0.0/0            /* Local        */
  125 27748 TCP_OUT    tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Split TCP    */
   15  1049 UDP_OUT    udp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Split UDP    */
    0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Logs         */ LOG flags 0 level 4 prefix " [OUTPUT DROPPED] "

Chain BLACKLIST (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            match-set trustedLst src,dst recent: REMOVE name: blacklist side: source mask: 255.255.255.255
    0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            LOG flags 0 level 4 prefix "      [BLACKLIST] "
    0     0 SET        all  --  *      *       0.0.0.0/0            0.0.0.0/0            add-set blacklist-live src

Chain TCP_IN (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x06/0x06
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x3F/0x00
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x3F/0x3F
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Scans Xmas and Null */ tcp flags:0x29/0x29
  127  8949 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /*  IN SSH             */ ctstate NEW,ESTABLISHED tcp dpt:443 match-set trustedLst src
    0     0 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT HTTP            */ ctstate ESTABLISHED tcp spt:80
    0     0 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT HTTPS           */ ctstate ESTABLISHED tcp spt:443
   21  5331 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT SMTP            */ ctstate ESTABLISHED tcp spt:25
    0     0 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT SSH             */ ctstate ESTABLISHED tcp spt:22
    0     0 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT Whois           */ ctstate ESTABLISHED tcp spt:43
    0     0 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT Whois           */ ctstate ESTABLISHED tcp spt:4321

Chain TCP_OUT (1 references)
 pkts bytes target     prot opt in     out     source               destination         
  104 15371 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /*  IN SSH             */ ctstate ESTABLISHED tcp spt:443 match-set trustedLst dst
    0     0 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT HTTP            */ ctstate NEW,ESTABLISHED tcp dpt:80
    0     0 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT HTTPS           */ ctstate NEW,ESTABLISHED tcp dpt:443
   21 12377 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT SMTP            */ ctstate NEW,ESTABLISHED tcp dpt:25
    0     0 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT SSH             */ ctstate NEW,ESTABLISHED tcp dpt:22
    0     0 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT Whois           */ ctstate NEW,ESTABLISHED tcp dpt:43
    0     0 ACCEPT     tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT Whois           */ ctstate NEW,ESTABLISHED tcp dpt:4321

Chain UDP_IN (1 references)
 pkts bytes target     prot opt in     out     source               destination         
   15  1692 ACCEPT     udp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT DNS             */ ctstate ESTABLISHED udp spt:53
    0     0 ACCEPT     udp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            /* OUT NTP             */ ctstate ESTABLISHED udp spt:123

Chain UDP_OUT (1 references)
 pkts bytes target     prot opt in     out     source               destination         
   15  1049 ACCEPT     udp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT DNS             */ ctstate NEW,ESTABLISHED udp dpt:53
    0     0 ACCEPT     udp  --  *      eth0    0.0.0.0/0            0.0.0.0/0            /* OUT NTP             */ ctstate NEW,ESTABLISHED udp dpt:123
```


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

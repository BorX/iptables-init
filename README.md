Installation
============
ToDo Documentation

Utilisation
===========
Configuration
-------------
Pour tous les détails, voir § Fonctionnement.

### iptables-config
#### Paramètre 1
ToDo Documentation

#### Paramètre 2
ToDo Documentation

### iptables_perso
Modification des règles personnalisables
ToDo Documentation

Arrêt
-----
`# iptables-init stop`

Lancement
---------
`# ./iptables-init start`

Note :
Si le script est exécuté via une connexion sur un serveur distant (par exemple via une connexion SSH), cette connexion risque d’être bloquée par des règles iptables trop restrictives.
Pour limiter un éventuel blocage à seulement 2 minutes :
`# ./iptables-init start; sleep 120; ./iptables-init stop`

Objectifs
=========
Easy initialization iptables rules
Shell script to easily initialize iptables rules by incorporating recurrent security

Tracer efficacement dans les fichiers de log les paquets bloqués
----------------------------------------------
ToDo Documentation

Proposer des barrières pour contrer les attaques les plus courantes
----------------------------------------------
XMAS, NULL-NULL, paquets fragmentés, flood, ...
ToDo Documentation

Organiser l’administration des règles Iptables
----------------------------------------------
Ce script se distingue des autres scripts d'initialisation d'iptables.
Son organisation modulaire le rend plus simple à comprendre, à modifier et donc à faire évoluer.

### Distinguer l’administration des règles Iptables pour les différentes tables (raw, nat, mangle, filter)
Ce script permet la modification d'une table principale d'iptables sans modifier les autres.
Cette organisation est particulièrement intéressante pour gérer ses scripts en configuration (par exemple, sous forme de branche Git).

### Distinguer l’administration des règles personnelles de l’administration des règles communes
Ce script propose une organisation de découpage modulaire permettant d'isoler ses propres règles iptables des autres règles.


Fonctionnement
==============
ToDo Documentation

ToDo
====
Documentation
-------------

Traduction
----------
### Commentaires
### Documentation


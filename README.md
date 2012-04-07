English
=======

All details are in the [wiki](https://github.com/BorX/iptables-init/wiki).


Goals
-----
Shell script to easily initialize iptables rules by incorporating recurrent security

ToDo Translation



Français
========

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

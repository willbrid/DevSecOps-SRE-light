# Partie 2 : Mise en réseau de base et utilitaires réseau

- Affichons les informations sur les périphériques réseau

```
ip link show
```

ou

```
ip link
```

- Affichons les informations sur les périphériques réseau en ajoutant les informations de statistique sur les paquets qui ont été reçus (**RX**) ou transférés (**TX**).

```
ip -s link
```

- désactivons/réactivons notre interface réseau **eth0**

```
sudo ip link set eth0 down
sudo ip link set eth0 up
```

- Augmentons la valeur MTU (Maximum Transmission Unit) de notre interface réseau **eth0**

```
sudo ip link set eth0 mtu 9100
```

- Affichons les informations uniquement sur notre interface eth0 dont le MTU a été mise à jour

```
ip link show eth0
```

- Activons ou désactivons le mode **promiscuité** sur notre interface **eth0**

```
sudo ip link set eth0 promisc on
sudo ip link set eth0 promisc off
```

Ce mode est souvent utilisé en sécurité afin de permettre à tout le trafic d'aller au CPU de telle sorte qu'il peut être lu. Cela signifie que l'interface ne filtrera aucune des données. Donc, si nous souhaiterons dépanner par exemple un problème de sécurité, il existe divers utilitaires qui voudront que ce mode **promiscuité** soit activé afin que nous puissions réellement lire les informations.

- Affichons la table de routage du kernel

```
ip route show
```

Exemple de sortie de cette commande
```
default via 192.168.1.1 dev eth0 proto dhcp metric 100
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.106 metric 100
```

Elle permet de fournir les informations telles que : <br>
--- la passerelle par défaut (commençant par le mot clé **default**) qui est la route dans lequel un paquet va transiter si aucune autre route ne correspond. <br>

--- une route (**192.168.1.0/24 dev eth0**) qui permettra de nous fait savoir que tout ce qui est destiné à une adresse précise doit être envoyé via l'interface mentionnée. <br>

- Exécutons la commande **ss** avec les options **-tupln**

```
ss -tupln
```

Les différentes significations de ces options : <br>
--- **t** : qui va afficher les connexions TCP. <br>
--- **u** : qui va montrer les connexions UDP. <br>
--- **l** : qui va afficher uniquement les sockets actifs (en écoute). <br>
--- **n** : qui va éviter de résoudre les noms de services. <br>
--- **p** : qui va montrer les processus utilisant le socket. <br>

- Exécutons la commande **dig** sur le domaine **acloudguru.com**

```
dig acloudguru.com
```

Elle permet d'afficher au niveau de la section **ANSWER SECTION** : <br>
--- le nom de la requête du serveur, qui est acloudguru.com <br>
--- le **ttl** (time to live) qui est de 60 <br> 
--- **IN**, qui signifie Internet <br>
--- **A** qui est pour l'enregistrement d'adresse, c'est un type d'entrée DNS <br>
--- l'adresse IP réelle qui sera associée au nom d'hôte <br>

- Exécutons la commande **ping** sur les domaines **google.com** et **acloudguru.com**

```
ping google.com
ping acloudguru.com
```
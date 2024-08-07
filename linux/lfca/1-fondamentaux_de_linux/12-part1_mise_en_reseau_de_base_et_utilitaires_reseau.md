# Partie 1 : Mise en réseau de base et utilitaires réseau

# Définition

- Le périphérique loopback est une interface réseau virtuelle spéciale qui permet la communication interne à un ordinateur. Il a une adresse de **127.0.0.1** (IPV4) et **::1** (IPV6) et est mappé sur **localhost**.

- **ip** : affiche et manipule le routage, les périphériques réseau, les politiques de routage et les tunnels. Remplace les commandes **ifconfig** et **route** désormais obsolètes. Intègre des objets pour gérer les différents aspects des réseaux (ex : **ip objet**). Certains objets notables pour la commande ip sont les suivants : <br>

--- **address** : affiche les adresses et leurs propriétés, ajoute de nouvelles adresses et supprime les anciennes. Chaque périphérique réseau doit avoir au moins une adresse pour utiliser le protocole correspondant (ipv4 ou ipv6). <br>

--- **link** : affiche les attributs de périphérique réseau, ajouter/supprimer les périphériques réseau et modifier l'état des périphériques réseau. <br>

--- **route** : affiche et manipule les entrées dans la table de routage du noyau. <br>

- **fichiers de configuration réseau et persistance** : les modifications apportées avec la commande **ip** ne persisteront pas lors d'un redémarrage. Pour rendre les modifications permanentes, les fichiers de configuration réseau doivent être mis à jour directement ou via l'utilitaire de ligne de commande. Distribution basée sur les emplacements des fichiers de configuration réseau : <br>
--- **/etc/network** : pour les hébergeurs debian <br>
--- **/etc/sysconfig/network** : pour suse <br>
--- **/etc/sysconfig/network-scripts** pour redhat <br>

- **ss** : un utilitaire utilisé pour analyser sur les sockets réseau et afficher les statistiques des sockets. Remplace la commande **netstat** désormais obsolète.

- **dig** : un utilitaire de recherche de serveur de noms de domaine qui offre une flexibilité pour interroger les serveurs de noms DNS. Il est plus robuste que son prédécesseur **nslookup** et offre plus de fonctionnalités que la simple commande **host**.

- **ping** : utilisé pour envoyer une requête **ICMP ECHO_REQUESTS**, pour obtenir **ICMP ECHO_RESPONSE** d'un hôte ou d'une passerelle. <br>
ICMP (internet control message protocol).

## Pratiques

- Affichons les interfaces réseau

```
ip address show
```

Il permettra de voir si une interface est **UP** ou **DOWN** et d'afficher d'autres informations : le nom de l'interface, l'adresse MAC, informations d'adresse IPV4 et IPV6... 

- Affichons les interfaces réseau avec les statistiques

```
ip -s address
```

ou

```
ip -s addr
```

Il permettra en plus de nous donner des informations sur les paquets qui ont été reçus (**RX**) ou transférés (**TX**).

- Ajoutons une adresse IP à notre interface **eth0**

```
sudo ip address add 192.168.7.5/24 dev eth0
```

Si l'interface portait déjà une adresse, alors une seconde adresse sera créée.

- Affichons les informations sur notre interface **eth0**

```
ip addr show dev eth0
```

- Supprimons l'adresse IP précédemment créé sur notre interface eth0

```
sudo ip addr del 192.168.7.5/24 dev eth0
```
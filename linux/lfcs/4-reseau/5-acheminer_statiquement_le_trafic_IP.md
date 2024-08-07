# Acheminer statiquement le trafic IP

Parfois, il est nécessaire de contrôler le chemin emprunté par une requête réseau. En tant qu'administrateur système Linux, nous devons peut-être créer des routes statiques pour gérer le trafic réseau.

Un réseau est une autoroute conçue pour acheminer les paquets d’informations vers leur destination. Parfois, un administrateur Linux doit fermer une route en raison de problèmes ou de travaux.

- Affichons la configuration réseau de notre serveur

```
ip addr show
```

- Affichons la table de routage de notre serveur

```
ip route show
```

- Installons et utilisons la commande **traceroute** pour voir comment cette machine accède à l'un des serveurs DNS de Google **8.8.0.0**

Sous Ubuntu
```
sudo apt install traceroute
```

Sous Rocky linux
```
sudo dnf install traceroute
```

Exécution de la commande

```
traceroute 8.8.0.0
```

Dans le résultat de cette commande, le premier saut est mon routeur par défaut. Ensuite, le paquet effectue plusieurs sauts. Pour certains sauts, leur périphérique n'est pas configuré pour envoyer une réponse : c'est pour nous avons des étoiles à la place. Après plusieurs sauts, nous atteignons enfin le serveur DNS de Google. Chacun de ces sauts doit généralement avoir des routes configurées pour leur dire quoi faire avec les paquets à mesure qu'ils arrivent.

- Forçons notre serveur **ubuntu-server** à utiliser notre serveur **rocky-server** comme passerelle

Activons le routage sur notre serveur **rocky-server**

```
sudo su
echo 1 > /proc/sys/net/ipv4/ip_forward
exit
```

```
sudo sysctl -p
```

Vérifions si la configuration a été appliquée

```
sudo sysctl net.ipv4.ip_forward
```

Ajoutons une route sur notre serveur **ubuntu-server** afin d'atteindre le DNS Google en passant par notre serveur **rocky-server**

```
sudo ip route add 8.8.0.0/16 proto static metric 10 via inet 192.168.56.110 dev enp0s8
```

- **ip route add** : c'est la commande pour ajouter une route IP.
- **8.8.0.0/16** : c'est l'adresse réseau et le masque de sous-réseau qui spécifient la plage d'adresses IP à atteindre via cette route. Dans ce cas, c'est le réseau 8.8.0.0 avec un masque de sous-réseau de 16 bits, ce qui signifie que les adresses IP comprises entre 8.8.0.0 et 8.8.255.255 sont incluses.
- **proto static** : cela spécifie le protocole utilisé pour cette route. Dans ce cas, c'est **static**, ce qui signifie que cette route est définie manuellement par l'utilisateur.
- **metric 10** : c'est la métrique associée à cette route. La métrique est utilisée par le système d'exploitation pour déterminer la priorité des routes lorsqu'il y a plusieurs chemins possibles vers une destination. Une métrique inférieure indique une priorité plus élevée. Dans ce cas, la métrique est définie à 10.
- **via inet 192.168.56.110** : c'est l'adresse IP de la passerelle à utiliser pour atteindre le réseau spécifié. L'adresse IP de la passerelle est **192.168.56.110**.
- **dev enp0s8** : c'est le nom de l'interface réseau sortante à utiliser pour acheminer le trafic vers la passerelle spécifiée. Dans ce cas, c'est l'interface réseau **enp0s8**.

Si nous consultons la table de routage du serveur **ubuntu-server** nous verrons qu'une route a été ajoutée

```
ip route show
```

Si nous exécutons la commande **traceroute** sur le DNS Google **8.8.0.0** sur le serveur **ubuntu-server**, nous constaterons qu'il existe un saut pointant sur le serveur **rocky-server**

```
traceroute 8.8.0.0
```

Supprimons la route nouvellement créée sur le serveur **ubuntu-server**, nous exécutons la commande

```
sudo ip route del 8.8.0.0/16 proto static metric 10 via inet 192.168.56.110 dev enp0s8
```

Si nous consultons la table de routage du serveur **ubuntu-server** nous verrons que la route a été supprimée

```
ip route show
```
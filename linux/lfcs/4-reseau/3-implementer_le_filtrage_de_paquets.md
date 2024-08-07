# Implémenter le filtrage de paquets

Un administrateur système Linux doit protéger les systèmes contre les attaques externes. Le filtrage de paquets avec **iptables** est une option qui peut nous aider à protéger nos systèmes. Protéger une machine en réseau sur Internet peut aujourd’hui s’avérer un défi.

- Afficher la configuration actuelle d'iptables

```
sudo iptables -L
```

- Supprimons toutes les règles dans toutes les chaines

```
sudo iptables --flush
```

### Rejectons les requêtes **ICMP** sur notre vm **Rocky** venant de notre vm **Ubuntu**

- Effectuons un ping avec 3 paquets depuis notre vm ubuntu vers notre vm Rocky

```
ping -c3 192.168.56.110
```

- Appliquons la règle **iptables** pour rejeter les requêtes **ICMP** à destination de notre serveur **Rocky** sur l'interface **enp0s8** portant notre adresse IP **192.168.56.110**

```
sudo iptables -A INPUT --protocol icmp --in-interface enp0s8 -j REJECT
```

- Listons les règles **iptables** afin de confirmer notre configuration

```
sudo iptables -L
```

- Effectuons à nouveau un ping avec 3 paquets depuis notre vm **Ubuntu** vers notre vm **Rocky**

```
ping -c3 192.168.56.110
```

Nous constaterons un message d'erreur "**Destination Port Unreachable**".

- Effaçons notre règle précédemment configurée sur le serveur **Rocky**

```
sudo iptables --flush
```

### Bloquons les requêtes **ICMP** sur notre vm **Rocky** venant de notre vm **Ubuntu**

- Appliquons la règle **iptables** pour bloquer les requêtes **ICMP** à destination de notre serveur Rocky sur l'interface **enp0s8** portant notre adresse IP **192.168.56.110**

```
sudo iptables -A INPUT --protocol icmp --in-interface enp0s8 -j DROP
```

- Effectuons à nouveau un ping avec 3 paquets depuis notre vm **Ubuntu** vers notre vm **Rocky**

```
ping -c3 192.168.56.110
```

Nous constaterons qu'aucun retour n'est renvoyé par le serveur **Rocky**.

- Effaçons notre règle précédemment configurée sur le serveur **Rocky**

```
sudo iptables --flush
```
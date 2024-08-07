# Démarrer, arrêter et vérifier l'état des services réseau

En tant qu'administrateur système Linux, nous devons comprendre quelles applications réseau sont actives, quels ports sont ouverts et quel trafic arrive au système. Pour cela, nous utiliserons la commande **netstat** pour faire ressortir toutes ces informations.

- Listons toutes les sockets

```
sudo netstat -a | more
```

Si nous examinons cette sortie, nous pouvons voir des éléments tels que :

- **Proto** : Le protocole utilisé par cette prise (par exemple, TCP ou UDP).
- **RECV-Q** : La file d’attente de réception. Ce sont des octets entrants qui ont été reçus et sont tamponnés, en attente du processus local qui utilise cette connexion pour la lire et la consommer.
- **Send-Q** : La file d’attente d’envoi. Cela montre les octets prêts à être envoyés de la file d’attente d’envoi.
- **Adresse locale** : Les détails de l’adresse de destination locale de la connexion.
- **Adresse distante** : L’adresse et le numéro de port de l'origine de la connexion.
- **Etat de la connexion** : L’état de la prise locale **Established**, **Listen**, **Closed**,... Pour les sockets UDP, ceci est généralement vide.

Dans la première partie de cette liste, on peut voir les entrées **tcp** et **tcp6**. Ceci est suivi des entrées **udp** et **udp6**, et enfin, il répertorie les entrées **Unix**. Si nous faisons défiler une page ou deux, nous pouvons voir que de nombreuses informations sont renvoyées par la commande.

- Comptons le nombre de sockets

```
sudo netstat -a | wc -l
```

- Affichons toutes les sockets tcp

```
sudo netstat -at
```

L'option **-t** permet de lister uniquement les sockets tcp.

- Affichons les sockets tcp du serveur à l'état **LISTEN**

```
sudo netstat -lt
```

L'option **-l** permet d'afficher les sockets du serveur à l'état **LISTEN**.

- Affichons toutes les sockets udp

```
sudo netstat -au
```

L'option **-u** permet de lister uniquement les sockets udp.

- Affichons les sockets udp du serveur à l'état **LISTEN**

```
sudo netstat -lu
```

- Affichons toutes les sockets tcp déjà établies

```
sudo netstat -t
```

- Affichons toutes les sockets tcp avec le nom du programme/PID associé à ces sockets

```
sudo netstat -apt
```

L'option **-p** permet d'afficher le nom du programme/PID des sockets.

- Affichons toutes les sockets tcp à l'état **LISTEN** avec le nom du programme/PID associé à ces sockets

```
sudo netstat -lpt
```

- Affichons les statistiques réseau des sockets tcp

```
sudo netstat -st
```

Nous pouvons voir le nombre de paquets reçus, le nombre de paquets vers un port inconnu, le nombre de récepteurs, le nombre de paquets envoyés, le nombre d'erreurs de tampon de réception et d'envoi.

- Affichons les statistiques réseau des sockets udp

```
sudo netstat -su
```

- Affichons la table de routage

```
sudo netstat -r
```

- Affichons la table d'interfaces

```
sudo netstat -i
```

Cela renvoie des informations sur les paquets sur chacune de nos interfaces. Les colonnes commençant par **RX** sont destinées aux paquets reçus, les colonnes commençant par **TX** sont destinées aux paquets transmis. La colonne **Flight** nous indique quels drapeaux sont définis sur une interface. <br>
Si nous examinons les indicateurs pour l'interface **enp0s8**, **B** signifie que leur adresse de diffusion est disponible, **M** signifie qu'elle est configurée pour la multidiffusion, **R** signifie que l'interface est en cours d'exécution et **U** signifie que l'interface est opérationnelle.

- Affichons plus d'information avec les options **-ie**

```
sudo netstat -ie
```

Elle est similaire à la commande **ifconfig**.

- Affichons la table d'interfaces en realtime grace à l'option **-c**

```
sudo netstat -ci
```
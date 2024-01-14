# Monitoring

#### Utilisation l'interface socket stats

Nous allons monitorer la santé de notre environnement HAProxy à l'aide de la méthode **socket stats**. <br>
L'interface **socket stats** n'est pas activée par défaut. Pour l'activer, il est nécessaire d'ajouter une ligne dans la section **global** de la configuration haproxy. Une deuxième ligne est recommandée pour définir un délai d'attente plus long, toujours apprécié lors de l'émission de commandes à la main.

L'interface **socket stats** prend en charge deux modes de fonctionnement : <br>

--- **interactif** <br>

Le mode non interactif est le mode par défaut lorsque **socat** se connecte au socket. Dans ce mode, une seule ligne peut être envoyée. Il est traité dans son ensemble, les réponses sont renvoyées et la connexion se ferme après la fin de la réponse. C'est le mode utilisé par les scripts et les outils de monitoring. Il est possible d'envoyer plusieurs commandes dans ce mode, elles doivent être délimitées par un point-virgule (';'). Si une commande doit utiliser un point-virgule ou un antislash (ex : dans une valeur), elle doit être précédée d'un antislash ('\'). <br>

--- **non interactif** <br>

Le mode interactif affiche une invite ('>') et attend que les commandes soient saisies sur la ligne, puis les traite, et affiche à nouveau l'invite pour attendre une nouvelle commande. Ce mode est entré via la commande "prompt" qui doit être envoyée sur la première ligne en mode non interactif. Ce mode est un interrupteur à bascule, si "prompt" est envoyé en mode interactif, il est désactivé et la connexion se ferme après le traitement de la dernière commande de la même ligne.

- Activons l'interface **socket stats**

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
global
  stats socket /var/lib/haproxy/haproxy.sock mode 600 level admin
  stats timeout 2m  
...
```

```
sudo systemctl restart haproxy
sudo systemctl status haproxy
```

Nous pouvons vérifier la présence du fichier **/var/lib/haproxy/haproxy.sock**

```
sudo ls -l /var/lib/haproxy/haproxy.sock
```

- Installons l'outil **netcat**

```
sudo dnf install nc
```

- Affichons les statistiques HAProxy

```
sudo echo "show stat" | sudo nc -U /var/lib/haproxy/haproxy.sock
```

- Affichons en temps réel et sous forme de tableau les statistiques HAProxy

```
sudo watch -n 1 'echo "show stat" | nc -U /var/lib/haproxy/haproxy.sock | cut -d "," -f 1,2,5-11,18,24,36,50,62 | column -s, -t'
```

La commande **watch -n 1** permet de visualiser en temps réel à intervalle d'une séconde les statistiques **haproxy**. La commande **nc -U /var/lib/haproxy/haproxy.sock** permet de consulter le fichier socket Unix **/var/lib/haproxy/haproxy.sock** de HAProxy. La commande **column** avec son option **-t** permet de formater une liste sous forme de tableau et son option **-s** permet de préciser le délimitteur de tableau.

- Interagissons avec **socket stats** en mode interactif

```
sudo nc -U /var/lib/haproxy/haproxy.sock
```

```
prompt
```

Une fois l'invite affiché, nous pouvons saisir les commandes :

```
help # pour afficher l'aide sur une commande
show pools # pour afficher les informations sur tous les pairs de connexion
show stat # pour afficher les statistiques pour chaque serveur
quit # pour quitter l'invite
```

#### Utilisation l'interface web stats

Nous pouvons monitorer la santé de notre environnement HAProxy à l'aide de la méthode **web stats**. <br>
Nous pouvons configurer cette interface web sur un port et restreindre l'accès uniquement aux personnes aurotisées. Cette méthode web est statique (il faut rafraichir la page pour visualiser de nouvelles statistiques) et éphémère.
<br>
Pour l'activer nous suivrons ces étapes ci-dessous :

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
...
# Stats Page
listen stats
  bind *:8050
  stats enable
  stats uri /
  stats hide-version
```

```
sudo firewall-cmd --permanent --add-port=8050/tcp
sudo firewall-cmd --reload
```

```
sudo systemctl restart haproxy
sudo systemctl status haproxy
```

Nous pourrons accéder à l'interface via le lien 

```
http://192.168.56.8:8050
```

#### Utilisation de la commande halog

**Halog** est un outil de traitement de logs pour HAProxy. Nous allons installer **Halog**.

- Téléchargeons pour la même version 2.6 l'archive dev de HAProxy

```
cd ~
wget https://www.haproxy.org/download/2.6/src/devel/haproxy-2.6-dev12.tar.gz
```

```
tar -xvzf haproxy-2.6-dev12.tar.gz
cd haproxy-2.6-dev12
```

```
make admin/halog/halog
sudo cp admin/halog/halog /usr/local/sbin/.
```

Pour vérifier l'installation, nous pouvons exécuter la commande de visualisation de l'aide de **halog**

```
halog -h
```

- Affichons les logs de trafic (/var/log/haproxy-combined-traffic.log) avec halog

```
sudo cat /var/log/haproxy-combined-traffic.log | halog -srv -H | column -t
```

L'option **-srv** de halog permet d'afficher les statistiques par serveur et l'option **-H** permet d'afficher uniquement les requêtes **http**. La commande **column** avec son option **-t** permet de formater une liste sous forme de tableau.

```
sudo cat /var/log/haproxy-combined-traffic.log | halog -u -H -q | column -t
```

L'option **-u** de halog permet d'afficher les statistiques par url, l'option **-H** permet d'afficher uniquement les requêtes **http** et l'option **-q** permet de ne pas signaler les erreurs/avertissements.
<br><br>
Utilisons **halog** pour afficher les URL avec des erreurs 429

```
sudo cat /var/log/haproxy-combined-traffic.log | halog -u -H -q -hs 429 | column -t
```

Utilisons **halog** pour répertorier les URL en fonction du nombre d'erreurs générées

```
sudo cat /var/log/haproxy-combined-traffic.log | halog -ue -H -q | column -t
```
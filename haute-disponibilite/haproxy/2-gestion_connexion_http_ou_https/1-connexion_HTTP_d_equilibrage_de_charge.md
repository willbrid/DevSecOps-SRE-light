# Connexions HTTP d'équilibrage de charge

Tout ce que nous avons à faire, est de configurer HAProxy.

- Créeons une configuration HAProxy

Nous allons modifier le fichier de configuration "stock" HAProxy à **/etc/haproxy/haproxy.cfg** pour servir nos sites. Nous allons supprimer les configurations de **frontend** et de **backend** d'origine et créer les nôtres.<br>
Sur notre système, nous avons 2 sites configurés, avec 3 conteneurs de serveur Web dans chacun. Ils ont été préremplis avec un fichier texte de test sur **/test.txt** qui identifie le site et le serveur auxquels nous accédons.<br>
De plus, nous allons ajouter un bloc de configuration pour activer le portail Web sur notre socket UNIX de statistiques.

```
ssh vagrant@192.168.56.8
```

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
# Site Frontends
frontend site1
  bind *:8000
  default_backend site1

frontend site2
  bind *:8100
  default_backend site2

# Site 1 Backend
backend site1
  balance roundrobin
  server site1-web1 127.0.0.1:8081 check
  server site1-web2 127.0.0.1:8082 check
  server site1-web3 127.0.0.1:8083 check

# Site 2 Backend
backend site2
  balance roundrobin
  server site2-web1 127.0.0.1:8084 check
  server site2-web2 127.0.0.1:8085 check
  server site2-web3 127.0.0.1:8086 check

# Stats Page
listen stats
  bind *:8050
  stats enable
  stats uri /
  stats hide-version  
```

Dans les règles de notre firewalld, on ajoute les ports d'écoute de notre site frontend, puis on retire les ports de nos 6 serveurs afin qu'ils ne soient plus accessibles directement depuis une autre machine.

```
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --permanent --add-port=8100/tcp
sudo firewall-cmd --permanent --add-port=8050/tcp

sudo firewall-cmd --permanent --remove-port=8081/tcp
sudo firewall-cmd --permanent --remove-port=8082/tcp
sudo firewall-cmd --permanent --remove-port=8083/tcp
sudo firewall-cmd --permanent --remove-port=8084/tcp
sudo firewall-cmd --permanent --remove-port=8085/tcp
sudo firewall-cmd --permanent --remove-port=8086/tcp

sudo firewall-cmd --reload
```

```
sudo systemctl enable --now haproxy
sudo systemctl status haproxy
```

- Testez notre configuration HAProxy

--- Nous pouvons utiliser l'interface Web des statistiques en nous connectant à notre serveur sur le port **8050** avec un navigateur en saisissant l'adresse :

```
http://192.168.56.8:8050/
```

--- Nous pouvons utiliser un navigateur Web pour charger les sites sur les ports 8000 et 8100 sur notre serveur, et si nous actualisons ces sites, nous verrons les serveurs changer de manière circulaire.

```
http://192.168.56.8:8000/test.txt
http://192.168.56.8:8100/test.txt
```

Voyons ce qui se passe lorsque nous perdons un serveur. Nous fermerons 1 conteneur sur chaque site : <br>

**Site1**
```
podman stop site1_server3
```

**Site2**
```
podman stop site2_server2
```

Nous constatons que nous avons fermé 1 conteneur sur chaque site.
La vérification de l'interface Web des statistiques en se connectant à notre serveur sur le port 8050 avec un navigateur montre que les serveurs sont en panne. <br>
Nous pouvons à nouveau utiliser un navigateur Web pour charger les sites sur les ports 8000 et 8100 sur notre serveur, et si nous actualisons ces sites, nous verrons les serveurs changer de manière circulaire - moins les 2 serveurs Web que nous avons fermés. HAProxy nous a acheminé autour de la panne ! <br>
À quoi ressemblerait une panne totale du site ? 

```
podman stop -a
```

La vérification de l'interface Web des statistiques en se connectant à notre serveur sur le port 8050 avec un navigateur montre que tous les serveurs sont en panne. <br>
Nous pouvons à nouveau utiliser un navigateur Web pour charger les sites sur les ports 8000 et 8100 sur notre serveur, et si nous actualisons ces sites, nous verrons que HAProxy renvoie immédiatement un **503**, nous indiquant que le service n'est pas disponible.<br>
Redémarrons de tous les conteneurs Web :

```
podman start site{1..2}_server{1..3}
```

La vérification de l'interface Web des statistiques en se connectant à notre serveur sur le port 8050 avec un navigateur montre que tous les serveurs sont à nouveau opérationnels.
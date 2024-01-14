# Équilibrage de charge HTTPS

**Contexte** : nos sites traitent le trafic via HTTP. Nous devons renforcer notre sécurité et ajouter une sécurité via SSL/TLS. Nous souhaitons également gérer le traitement SSL au niveau de l'équilibreur de charge et desservir plusieurs sites avec la même interface HAProxy.

- Configurons les entrées **/etc/hosts** sur la machine client

En guise de test nous allons attribuer des noms d'hôte à nos sites Web en les ajoutant au fichier /etc/hosts sur la machine client. Nous allons utiliser **www.site1.com** pour le premier site et **www.site2.com** pour le second. Ils pointeront tous les deux vers l'adresse IP **192.168.56.8**.

```
ssh vagrant@192.168.56.7
```

```
vi /etc/hosts
```

```
# Local websites
192.168.56.8 www.site1.com
192.168.56.8 www.site2.com
```

Nous pouvons vérifier en saisissant

```
ping www.site1.com
ping www.site2.com
```

- Gérons le trafic par nom d'hôte

Nous pouvons gérer les modifications de notre backend HTTP en utilisant la capacité de HAProxy à réécrire le trafic HTTP qu'il utilise comme proxy. HAProxy fonctionne au niveau des couches d'application HTTP, 5 à 7, de sorte qu'il peut inspecter et manipuler les paquets dans ces couches. <br>
Nous allons apporter la modification suivante à notre fichier **/etc/haproxy/haproxy.cfg**

```
vi /etc/haproxy/haproxy.cfg
```

```
# Single frontend for http on port 80
frontend http-in
  bind *:80
  mode http
  acl site-1 hdr(host) -i www.site1.com
  acl site-2 hdr(host) -i www.site2.com
  use_backend site1 if site-1
  use_backend site2 if site-2
```

Redémarrons HAProxy pour récupérer notre changement de configuration :

```
sudo systemctl restart haproxy
```

Nous configurons le pare-feu pour accepter le trafic sur le port 80 et bloquer le trafic sur les ports 8000 et 8100 :

```
sudo firewall-cmd --permanent --add-port=80/tcp

sudo firewall-cmd --permanent --remove-port=8000/tcp
sudo firewall-cmd --permanent --remove-port=8100/tcp

sudo firewall-cmd --reload
```

Tout le trafic HTTP est maintenant géré sur le port 80 . Nous vérifierons le domaine pour lequel la demande est envoyée et l'enverrons au bon backend.
<br>
Nous allons nous assurer que nous pouvons accéder aux deux backends, en utilisant un nom d'hôte unique pour chacun.

```
curl -s http://www.site1.com/test.txt
```

```
curl -s http://www.site2.com/test.txt
```

- Configurer pour le trafic HTTPS uniquement

Nous allons apporter la modification suivante à notre fichier **/etc/haproxy/haproxy.cfg** .

Générons d'abord nos certificats privés
```
sudo mkdir /etc/haproxy/certs
```

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/haproxy/certs/ha-selfsigned.key -out /etc/haproxy/certs/ha-selfsigned.crt
```

```
cd /etc/haproxy/certs
sudo cp ha-selfsigned.crt ha-selfsigned_crt_key.crt
sudo su
cat ha-selfsigned.key >> ha-selfsigned_crt_key.crt
```

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
# Single frontend for https
frontend https-in
  bind *:443 ssl crt /etc/haproxy/certs/ha-selfsigned_crt_key.crt force-tlsv12
  mode http
  acl site-1 hdr(host) -i www.site1.com
  acl site-2 hdr(host) -i www.site2.com
  use_backend site1 if site-1
  use_backend site2 if site-2
```

Redémarrons HAProxy pour récupérer notre changement de configuration :

```
sudo systemctl restart haproxy
```

Nous configurons le pare-feu pour accepter le trafic sur le port 443

```
sudo firewall-cmd --permanent --add-port=443/tcp

sudo firewall-cmd --reload
```

Nous n'écoutions que le trafic HTTPS sur le port 443 . Nous allons récupérer nos certificats SSL dans le répertoire /etc/haproxy/certs/. Ensuite, nous vérifierons le domaine pour lequel la demande est envoyée et l'enverrons au bon backend. <br>

Nous allons nous assurer que nous pouvons accéder à notre fichier **test.txt** en utilisant HTTPS depuis la machine client.

```
curl -k https://www.site1.com/test.txt
curl -k https://www.site2.com/test.txt
```

Que se passe-t-il si nous essayons d'utiliser HTTP ? Nous ne gérons pas le trafic HTTP à ce stade. Configurons HAProxy pour qu'il accepte également le trafic HTTP, en le redirigeant vers HTTPS.

- Configurer la gestion du trafic HTTP

La configuration de la gestion du trafic HTTP est aussi simple que de lier le port 80 à notre interface et de configurer une redirection pour HTTP vers HTTPS.

Nous allons apporter la modification suivante à notre fichier **/etc/haproxy/haproxy.cfg** .

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
# Single frontend for http and https
frontend http-https-in
  mode http
  bind *:80
  bind *:443 ssl crt /etc/haproxy/certs/ha-selfsigned_crt_key.crt force-tlsv12
  http-request redirect scheme https unless { ssl_fc }
  acl site-1 hdr(host) -i www.site1.com
  acl site-2 hdr(host) -i www.site2.com
  use_backend site1 if site-1
  use_backend site2 if site-2
```

Redémarrons HAProxy pour récupérer notre changement de configuration :

```
sudo systemctl restart haproxy
```

Vérifions des connexions HTTP et HTTPS à l'aide de curl :

```
curl -kL http://www.site1.com/test.txt
curl -kL http://www.site2.com/test.txt
```

```
curl -kL https://www.site1.com/test.txt
curl -kL https://www.site2.com/test.txt
```

Tout fonctionne maintenant ! Nos utilisateurs peuvent se connecter avec HTTP ou HTTPS et seront redirigés vers HTTPS s'ils utilisent HTTP.
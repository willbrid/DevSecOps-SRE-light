# Utilisation de HAProxy pour protéger les services HTTP

- Installation d'**Apache Bench** sur le serveur **haproxy-client**

Nous allons d'abord dans un premier installé **Apache Bench** l'utilitaire qui permettra d'envoyer les requêtes http sur notre serveur **haproxy-client**.

```
sudo dnf install httpd-tools
```

- Exécution des requêtes http sur le site 1 et sur le site 2 depuis nos deux clients

```
ab -n 100000 -c 100 https://www.site1.com/ > ~/ab_site1.log > /dev/null 2>&1 &
```

```
ab -n 100000 -c 100 https://www.site2.com/ > ~/ab_site2.log > /dev/null 2>&1 &
```

Nous pouvons vérifier sur l'interface web http://192.168.56.8:8050/ et constaté les changements du nombre de session au niveau du frontend et des backend.

- Configuration du blocage du nombre de requêtes par secondes par adresse IP

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
frontend http-https-in
  mode http
  bind *:80
  bind *:443 ssl crt /etc/haproxy/certs/ha-selfsigned_crt_key.crt force-tlsv12
  http-request redirect scheme https unless { ssl_fc }
  http-request track-sc0 src table per_ip_rates
  http-request deny deny_status 429 if { sc_http_req_rate(0) gt 100 }
  http-request deny deny_status 500 if { req.hdr(user-agent) -i -m sub curl }
  http-request deny deny_status 503 if { src -f /etc/haproxy/blocked.acl }
  acl site-1 hdr(host) -i www.site1.com
  acl site-2 hdr(host) -i www.site2.com
  use_backend site1 if site-1
  use_backend site2 if site-2

# Backend for per_ip_rates
backend per_ip_rates
  stick-table type ip size 1m expire 10m store http_req_rate(10s)
...
```

La ligne **http-request track-sc0 src table per_ip_rates** au niveau du bloc frontend active le suivi des sessions pour les adresses IP sources des requêtes HTTP. Cela permet à HAProxy de suivre les sessions pour chaque adresse IP source et de stocker cette information dans une table nommée "per_ip_rates".
Plus précisément, cette ligne configure HAProxy pour enregistrer chaque session en utilisant l'adresse IP source comme clé, et stocker cette information dans la table "per_ip_rates". Cette table peut être utilisée pour suivre le nombre de sessions actives et le taux de requêtes pour chaque adresse IP source.

<br>

La ligne **http-request deny deny_status 429 if { sc_http_req_rate(0) gt 100 }** au niveau du bloc frontend configure une règle qui permet de refuser les requêtes HTTP qui dépassent un certain taux de requêtes par seconde. Plus précisément, cette ligne configure HAProxy pour refuser les requêtes HTTP et renvoyer un code de statut "429 Too Many Requests" si le taux de requêtes HTTP pour l'adresse IP source est supérieur à 100 sur un certain nombre de secondes (dans notre cas sur 10 secondes). Le taux de requêtes HTTP pour l'adresse IP source est calculé en utilisant la table de persistance "sc_http_req_rate(0)" qui stocke le taux de requêtes pour chaque adresse IP source sur une période de temps donnée (dans ce cas, toutes les requêtes depuis le début de la session).

<br>

La ligne **http-request deny deny_status 500 if { req.hdr(user-agent) -i -m sub curl }** au niveau du bloc frontend configure une règle qui permet de refuser les requêtes HTTP si la valeur de l'en-tête "User-Agent" correspond à celle d'un client utilisant l'outil en ligne de commande "curl". Plus précisément, cette ligne configure HAProxy pour refuser les requêtes HTTP et renvoyer un code de statut "500 Internal Server Error" si la valeur de l'en-tête "User-Agent" contient la chaîne de caractères "curl". L'option "-i" indique une recherche insensible à la casse, tandis que l'option "-m sub" indique une recherche par sous-chaîne (c'est-à-dire que la chaîne "curl" peut apparaître n'importe où dans la valeur de l'en-tête).

<br>

La ligne **http-request deny deny_status 503 if { src -f /etc/haproxy/blocked.acl }** au niveau du bloc frontend configure une règle qui permet de refuser les requêtes HTTP provenant d'adresses IP spécifiques qui sont listées dans un fichier ACL (Access Control List) nommé "blocked.acl". Plus précisément, cette ligne configure HAProxy pour refuser les requêtes HTTP et renvoyer un code de statut "503 Service Unavailable" si l'adresse IP source de la requête est incluse dans le fichier d'ACL "blocked.acl". L'option "-f" indique que l'adresse IP source doit être vérifiée par rapport à un fichier contenant une liste d'adresses IP bloquées.

<br>

La ligne avec **stick-table type ip size 1m expire 10m store http_req_rate(10s)** au niveau du bloc backend définit une table de persistence qui est utilisée pour suivre les connexions des clients et leurs taux de requêtes (nombre de requêtes HTTP par unité de temps). Plus précisément, cette ligne configure la table de persistence en utilisant l'adresse IP du client comme clé, avec une taille maximale de 1 million d'enregistrements et une durée d'expiration de 10 minutes pour chaque enregistrement. La table stocke également une valeur pour chaque adresse IP : "http_req_rate(10s)" qui représente le taux de requêtes pour cette adresse IP au cours des dernières 10 secondes.

- Configuration du fichier avec l'adresse IP du serveur client1

```
sudo vi /etc/haproxy/blocked.acl
```

```
192.168.56.9
```

- Stoppons le processus **ab** depuis nos deux clients

```
pkill ab
```

- Redemarrons le service haproxy sur le serveur **haproxy-server**

```
sudo systemctl restart haproxy
```

- Exécution à nouveau des requêtes http sur le site 1 et sur le site 2 depuis nos deux clients

```
ab -n 100000 -c 100 https://www.site1.com/ > ~/ab_site1.log > /dev/null 2>&1 &
```

```
ab -n 100000 -c 100 https://www.site2.com/ > ~/ab_site2.log > /dev/null 2>&1 &
```

- vérifions que nos deux processus **ab** sont bien lancés depuis nos deux clients

```
pgrep ab
```

Nous pouvons constater via l'interface web **http://192.168.56.8:8050/** que le nombre de requêtes entrant sur le frontend **http-https-in** qui ont été bloquées.
<br>
Nous pouvons aussi vérifier si les requêtes **curl** ont été bloquées depuis un client

```
curl -k https://www.site1.com
curl -k https://www.site2.com
```

```
# Résultat
<html><body><h1>500 Internal Server Error</h1>
An internal server error occurred.
</body></html>
```

Nous pouvons aussi tester le blocage depuis une source d'adresse mentionnée dans le fichier **/etc/haproxy/blocked.acl**. <br>

Sur le serveur client1, on aura une réponse avec un code de statut 503 : 
```
wget --no-check-certificate -O - https://www.site1.com/test.txt
```

```
# Résultat
2023-04-23 17:35:51 erreur 503 : Service Unavailable.
```

Sur le serveur client, on aura une réponse avec un code de statut 200 (ce qui prouve aussi que le **user-agent** de **curl** est différent de celui de **wget**) :
```
wget --no-check-certificate -O - https://www.site1.com/test.txt
```

```
# Résultat
requête HTTP transmise, en attente de la réponse… 200 OK
...
```
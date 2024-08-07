# Restreindre l'acces aux serveurs http via un proxy

Nous pouvons avoir des serveurs Web sur notre réseau avec des exigences d'accès spécifiques. En tant qu'administrateur système Linux, nous devons être capable de configurer un proxy pour contrôler l'accès. Il est essentiel de protéger les systèmes pour assurer la sécurité de nos utilisateurs et de nos données, tout en respectant les bonnes pratiques réseau.

Nous utiliserons ici un serveur **Squid**. **Squid** est un serveur proxy open source qui agit comme une passerelle ou un filtre pour contrôler le trafic et les requêtes entrant dans nos serveurs. La configuration de **Squid** se trouve dans le fichier **/etc/squid/squid.conf**.

Les entrées du fichier de configuration **Squid**

- **acl** : liste de contrôle d'accès
- **http_access** : accorder (**allow**) ou refuser (**deny**) les ACL basées sur l'accès
- **http_port** : port d'écoute de **Squid**
- **core_dump** : répertoire où sont stockés les fichiers **core dump**
- **refresh_pattern** : valeurs utilisées pour déterminer si un objet mis en cache est obsolète et doit être actualisé

### Installation de Squid

Sous Ubuntu

```
sudo apt install -y squid
```

Sous Rocky linux

```
sudo dnf install -y squid
```

### Configuration du service squid sur rocky-server

Nous allons configurer notre service proxy squid sur notre serveur **rocky-server** en définissant une acl qui autorisera les serveurs de notre plage de réseau **192.168.56.0/24** à accéder au proxy. Ces serveurs devront aussi accéder au site internet via ce proxy.

```
sudo vi /etc/squid/squid.conf
```

```
acl localnetrange src 192.168.56.0/24

# http_access allow localnet
http_access allow localhost
http_access allow localnetrange

request_header_access Referer deny all
request_header_access X-Forwarded-For deny all
request_header_access Via deny all
request_header_access Cache-Control deny all

forwarded_for off
```

```
sudo systemctl enable --now squid
sudo systemctl status squid
```

```
sudo firewall-cmd --add-service=squid
sudo firewall-cmd --runtime-to-permanent
```

- **request_header_access Referer deny all** : cette configuration empêche le serveur proxy de transmettre l'en-tête **"Referer"** dans les requêtes HTTP des clients. L'en-tête **"Referer"** contient généralement l'URL de la page précédente à partir de laquelle le client a navigué. En le déniant, nous masquons cette information des serveurs distants auxquels le proxy accède.

- **request_header_access X-Forwarded-For deny all** : L'en-tête **"X-Forwarded-For"** est généralement ajouté par les proxies pour indiquer l'adresse IP du client d'origine. En déniant cet en-tête, nous empêchons le serveur proxy Squid de transmettre cette information au serveur final. Cela peut être utile pour des raisons de confidentialité ou de sécurité.

- **request_header_access Via deny all** : L'en-tête **"Via"** est ajouté par les proxies pour indiquer les proxies intermédiaires à travers lesquels la requête a été acheminée. En déniant cet en-tête, nous masquons cette information aux serveurs distants.

- **request_header_access Cache-Control deny all** : L'en-tête **"Cache-Control"** est utilisé pour spécifier les directives de cache que les serveurs et les clients doivent respecter. En déniant cet en-tête, nous empêchons le serveur proxy Squid de transmettre les directives de contrôle de cache aux serveurs distants, ce qui peut affecter le comportement de mise en cache.

- **forwarded_for off** : cette configuration est utilisée pour désactiver l'ajout de l'en-tête **"X-Forwarded-For"** aux requêtes HTTP sortantes.
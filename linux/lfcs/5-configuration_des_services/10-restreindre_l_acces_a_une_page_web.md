# Restreindre l'accès à une page Web

La gestion des serveurs Web est une compétence importante, mais en tant qu'administrateur système Linux, nous devons être capable de sécuriser nos sites Web afin d'empêcher tout accès non autorisé. Il existe de nombreuses façons pour un administrateur Linux de sécuriser un site Web, parmi lesquels la restriction via les adresses IP.

### Détails de configuration d'Apache2

--- Les restrictions d'accès sont placées dans le fichier **apache2.conf** (**Ubuntu**) ou **httpd.conf** (**Rocky Linux**) <br>
--- Les récommandations de configuration <br>
----- faire toujours une copie de sauvegarde du fichier de configuration avant d'apporter des modifications <br>
----- utiliser la commande **apachectl configtest** pour valider les fichiers de configuration avant de redémarrer les services Apache2

### Configuration d'un bloc virtualhost sur nos 2 serveurs **ubuntu-server** et **rocky-server**

Sous **Ubuntu**, nous considérons le bloc **virtualhost** par défaut dans le fichier **/etc/apache2/sites-available/000-default.conf**.

Sous **Rocky**, nous configurons un bloc **virtualhost** et une page par défaut dans le fichier **/var/www/html/index.html**.

```
sudo vi /etc/httpd/conf.d/default.conf
```

```
<VirtualHost *:80>
    DocumentRoot /var/www/html
    ServerAdmin webmaster@localhost
    ErrorLog logs/error.log
	CustomLog logs/access.log custom-log-format
</VirtualHost>
```

```
sudo apachectl configtest
sudo systemctl restart httpd
sudo systemctl status httpd
```

```
sudo vi /var/www/html/index.html
```

```
<html>
<body>
<div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
Default Page
</div>
</body>
</html>
```

Sur nos deux serveurs **ubuntu-server** et **rocky-server**, créons une page dans un repertoire **test**

```
sudo mkdir /var/www/html/test
```

```
sudo vi /var/www/html/test/index.html
```

```
<html>
<body>
<div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
Test Page
</div>
</body>
</html>
```

Testons nos pages via l'utilitaire **lynx**

```
lynx localhost
```

```
lynx localhost/test
```

Testons l'accés à la page **test** de notre serveur **ubuntu-server** depuis notre serveur **rocky-server**

```
lynx 192.168.56.111/test
```

### Configurons une restriction pour autoriser l'accès à notre page **test** uniquement pour l'adresse locale de nos serveurs

Sous **Ubuntu**

```
sudo vi /etc/apache2/sites-available/000-default.conf
```

```
...
<Directory /var/www/html/test/>
    Order allow,deny
    Allow from 127
    Allow from ::1
</Directory>
```

```
sudo apachectl configtest
sudo systemctl restart apache2
sudo systemctl status apache2
```

Sous **Rocky linux**

```
sudo vi /etc/httpd/conf.d/default.conf
```

```
...
<Directory /var/www/html/test/>
    Order allow,deny
    Allow from 127
    Allow from ::1
</Directory>
```

```
sudo apachectl configtest
sudo systemctl restart httpd
sudo systemctl status httpd
```

Si nous essayons d'accéder à la page **test** de notre serveur **ubuntu-server** depuis notre serveur **rocky-server**, nous verrons un message **403 Forbidden**

```
lynx 192.168.56.111/test
```
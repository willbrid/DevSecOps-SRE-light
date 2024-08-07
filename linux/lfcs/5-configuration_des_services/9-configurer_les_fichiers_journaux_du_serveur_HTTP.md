# Configurer les fichiers journaux du serveur HTTP

Être capable de manipuler le format d'un fichier journal **Apache2** peut rendre la création de rapports et la gestion des journaux beaucoup plus facile pour un administrateur système Linux. De nombreux administrateurs système Linux utilisent un logiciel d'agrégation de journaux ou un logiciel d'analyse similaire pour consolider et gérer les fonctions de reporting.

#### Détails du fichier journal Apache2

Les formats de fichiers journaux sont stockés dans le fichier de configuration Apache2 ou Httpd, en fonction de notre distribution. <br>
Le format **error.log** ne peut pas être modifié, uniquement le format **access.log**.

Format de logs : <br>
--- **%h** = Nom d'hôte (Adresse IP si la résolution de nom est désactivée) <br>
--- **%u** = Utilisateur (si le site est authentifié) <br>
--- **%t** = La date et l'heure à laquelle la requête a été faite <br>
--- **%r** = Le type de requête <br>
--- **%>s** = Statut de la requête (200, 404, etc.) <br>
--- **\"%{User-agent}i\"** = Navigateur utilisé pour effectuer la requête

Sous **Ubuntu**

```
cat /etc/apache2/apache2.conf | grep LogFormat
```

Sous **Rocky linux**

```
cat /etc/httpd/conf/httpd.conf | grep LogFormat
```

#### Configurer un format de logs personnalisé pour apache2

Sous **Ubuntu**

```
sudo vi /etc/apache2/apache2.conf
```

```
...
LogFormat "%{User-agent}i" agent
LogFormat "HOST: %h - DATETIME: %t - REQUESTED: %r - STATUS: %>s" custom-log-format
...
```

```
sudo systemctl restart apache2
sudo systemctl status apache2
```

Sous Rocky linux

```
sudo vi /etc/httpd/conf/httpd.conf
```

```
...
<IfModule log_config_module>
...
LogFormat "HOST: %h - DATETIME: %t - REQUESTED: %r - STATUS: %>s" custom-log-format
...
</IfModule>
...
```

```
sudo systemctl restart httpd
sudo systemctl status httpd
```

#### Appliquer un format de logs personnalisé à la configuration du site par défaut

Sous **Ubuntu**

```
sudo vi /etc/apache2/sites-available/000-default.conf
```

```
...
CustomLog ${APACHE_LOG_DIR}/access.log custom-log-format
...
```

testons nos configurations

```
sudo apachectl configtest
```

Redémarrons le service apache2

```
sudo systemctl restart apache2
sudo systemctl status apache2
```

Sous **Rocky linux**

```
sudo vi /etc/httpd/conf/httpd.conf
```

```
...
<IfModule log_config_module>
...
# CustomLog "logs/access_log" combined
CustomLog "logs/access_log" custom-log-format
...
</IfModule>
...
```

testons nos configurations

```
sudo apachectl configtest
```

Redémarrons le service httpd

```
sudo systemctl restart httpd
sudo systemctl status httpd
```

- Exécutons à nouveau la commande **lynx localhost** et vérifions que notre format personnalisé de logs est bien pris en compte

```
lynx localhost
```

Sous Ubuntu

```
sudo less /var/log/apache2/access.log
```

Sous Rocky linux

```
sudo less /var/log/httpd/access_log
```
# Configurer un serveur HTTP

Les compétences nécessaires pour installer et configurer des services Web sur un serveur Linux sont des connaissances précieuses pour tout administrateur système, puisque Linux est une plate-forme d'hébergement Web populaire.

- Installation d'**apache2**

Sous **Ubuntu**

```
sudo apt install -y apache2
```

Sous **Rocky linux**

```
sudo dnf install -y httpd
```

- Vérifions le statut du service apache2

Sur **Ubuntu**

```
sudo systemctl status apache2
```

Sous **Rocky linux**

```
sudo systemctl status httpd
```

Sur **Rocky linux**, le service apache2 (httpd) n'est pas activé par défaut. Nous pouvons l'activer avec la commande

```
sudo systemctl enable --now httpd
```

- Consultons la page web par défaut du service apache2 avec l'utilitaire **lynx**

--- Installons **lynx**

Sous **Ubuntu**

```
sudo apt install -y lynx
```

Sous **Rocky linux**

```
sudo dnf config-manager --set-enabled powertools
sudo dnf install -y lynx
```

--- Affichons la page web par défaut

```
lynx localhost
```

- Fichiers clés, répertoires et commandes

Sous **ubuntu**

--- **/var/www/html** : le répertoire "home" du site par défaut <br>
--- **/etc/apache2** : le répertoire de l'application **apache2**, contient tous les répertoires et fichiers de configuration <br>
--- **/etc/apache2/sites-available/000-default.conf** : le fichier de configuration **apache2** du site par défaut <br>
--- **/etc/apache2/sites-enabled/** : le répertoire qui contient les fichiers de configuration de tous les sites Web activés. Il contient des liens symboliques vers les fichiers **conf** dans le répertoire **sites-available** <br>
--- **apachectl configtest** : commande qui validera le fichier de configuration

Sous **Rocky linux**

--- **conf** : ce répertoire contient les fichiers de configuration principaux d'apache2 <br>
----- **httpd.conf** : le fichier de configuration principal d'apache où nous configurons des paramètres tels que les ports d'écoute, les hôtes virtuels, les modules chargés, etc. <br>
--- **conf.modules.d/** : ce répertoire contient des fichiers de configuration spécifiques aux modules apache. Chaque fichier est généralement responsable de charger ou de configurer un module spécifique d'Apache. <br>
--- **conf.d/** : ce répertoire contient des fichiers de configuration supplémentaires qui peuvent être inclus dans **httpd.conf**. Ces fichiers peuvent inclure des configurations spécifiques aux hôtes virtuels, des règles de redirection, des paramètres de sécurité, etc.
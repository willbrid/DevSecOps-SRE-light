# Configuration des groupes de serveurs

Étant donné que nous avons configuré deux groupes distincts dans notre fichier d'inventaire, **app** et **db** , nous pouvons cibler les commandes uniquement sur les serveurs de ces groupes.

## Configuration des serveurs d'application

Notre application Web utilise Django, nous devons donc nous assurer que Django et ses dépendances sont installés.
<br>
- Installons python3
```
ansible app -b -m yum -a "name=python3-pip state=present"
```

- Installons Django
```
ansible app -b -m pip -a "name=django<4 state=present"
```

- Vérifions que Django est installé et fonctionne correctement
```
ansible app -a "python3 -m django --version"
```

## Configuration du serveur de base de données
Installons MariaDB et démarrons-le.

```
ansible db -b -m yum -a "name=mariadb-server state=present"
ansible db -b -m service -a "name=mariadb state=started enabled=yes"
```

Ensuite, configurons le pare-feu du système pour nous assurer que seuls les serveurs d'applications peuvent accéder à la base de données.
<br>
- Assurons que firewalld est installé et démarré sur le serveur de base de données

```
ansible db -b -m yum -a "name=firewalld state=present"
ansible db -b -m service -a "name=firewalld state=started enabled=yes"
```

- configurons la zone database et acceptons uniquement les communications sur le port 3306
```
ansible db -b -m firewalld -a "zone=database state=present permanent=yes"
ansible db -b -m firewalld -a "source=192.168.56.0/24 zone=database state=enabled permanent=yes"
ansible db -b -m firewalld -a "port=3306/tcp zone=database state=enabled permanent=yes"
```

Si nous essayons de nous connecter à la base de données à partir des serveurs d'applications (ou de notre machine hôte) à ce stade, nous ne pourrons pas nous connecter, car MariaDB doit encore être configurée.
Généralement, nous ferions cela en nous connectant au serveur et en exécutant mysql_secure_installation. Heureusement, Ansible peut contrôler un serveur MariaDB avec ses modules mysql_* assortis. Pour l'instant, nous devons autoriser l'accès à MySQL pour un utilisateur à partir de nos serveurs d'applications. Les modules MySQL nécessitent que le module **PyMySQL** soit présent sur le serveur géré.

- installons le module python3 PyMysql
```
ansible db -b -m yum -a "name=python3-PyMySQL state=present"
```

- créeons un utilisateur **django** avec pour mot de passe **12345** à utiliser par nos serveurs d'application 
```
ansible db -b -m mysql_user -a "name=django host=% password=12345 priv=*.*:ALL state=present"
```

## Modification d'un seul serveur
- vérifions le status du démon de synchronisation de l'heure chrony sur les serveurs d'application
```
ansible app -b -a "systemctl status chronyd"
```

- redémarrons le démon chrony sur l'un des serveurs d'application
```
ansible app -b -a "service chronyd restart" --limit "192.168.56.4"
```

Dans cette commande, nous avons utilisé l'argument **--limit** pour limiter la commande à un hôte spécifique dans le groupe spécifié. **--limit** correspondra soit à une chaîne exacte, soit à une expression régulière (préfixée par **∼** ). La commande ci-dessus pourrait être énoncée plus simplement si nous souhaitons appliquer la commande uniquement au serveur **.4** (en supposant qu'il n'y a pas d'autres serveurs avec une adresse IP se terminant par **.4**), ce qui suit fonctionnerait exactement de la même manière.

```
ansible app -b -a "service chronyd restart" --limit "*.4"
ansible app -b -a "service chronyd restart" --limit ~".*\.4"
```
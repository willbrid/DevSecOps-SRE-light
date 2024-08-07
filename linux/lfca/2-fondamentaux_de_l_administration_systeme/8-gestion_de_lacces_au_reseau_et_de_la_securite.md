# Gestion de l'accès au réseau et de la sécurité

## Définition

- gestion de base du service **firewalld**

--- **firewalld** : fournit un pare-feu géré dynamiquement qui prend en charge des groupes de règles appelés **zones**. <br>
--- **firewall-cmd** : le client en ligne de commande pour **firewalld**. <br>
--- Les zones prédéfinies : **drop**, **block**, **public**, **external**, **internal**, **dmz**, **work**, **home**, **trusted** <br>

```
firewall-cmd --state
firewall-cmd --list-services
firewall-cmd --lists-ports
firewall-cmd --get-active-zones
firewall-cmd --get-default-zone
firewall-cmd --list-all-zones
firewall-cmd --list-all
firewall-cmd [--permanent] [--zone=zone] --add-port=5000/tcp
firewall-cmd [--permanent] [--zone=zone] --add-service=http
firewall-cmd --reload
```

```
# Installer, démarrer et activer firewalld
## Sous Rocky
sudo yum install firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

## Sous Ubuntu
sudo apt install firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
```

- gestion des accès **ssh** sur l'hôte <br>

--- **sshd_config** : fichier de configuration du démon ssh openssh <br>
--- **AllowUsers** : ce mot-clé peut être suivi d'une liste de modèles de nom d'utilisateur, séparés par des espaces. Si spécifié, la connexion n'est autorisée que pour les noms d'utilisateur qui correspondent à l'un des modèles. <br>
--- **AllowGroups** : ce mot-clé peut être suivi d'une liste de modèles de noms de groupes, séparés par des espaces. si spécifié, la connexion n'est autorisée que pour les utilisateurs dont le groupe principal ou la liste de groupes supplémentaires correspond à l'un des modèles.

<br>

Example
```
# vi /etc/ssh/sshd_config
PermitRootLogin no

PubkeyAuthentication yes

# The default is check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/autorized_keys
AuthorizedKeysFile .ssh/authorized_keys

AllowUsers john jane joe
AllowGroups operations development
```

## Pratiques

- affichons le statut du service firewalld

```
sudo firewall-cmd --state
```

- affichons la liste des services ajoutées au parefeu

```
sudo firewall-cmd --list-services
```

- affichons les zones actives

```
sudo firewall-cmd --get-active-zones
```

- affichons la zone par défaut

```
sudo firewall-cmd --get-default-zone
```

- affichons en détails toutes les zones

```
sudo firewall-cmd --list-all-zones
```

- affichons en détails toutes les zones actives

```
sudo firewall-cmd --list-all
```

- autorisons le service http dans la zone **public**

```
sudo firewall-cmd --permanent --add-service=http
```

Par défaut si l'option **--zone** n'est pas mentionnée alors c'est la zone par défaut qui est considérée : ici la zone **public**. <br>
L'option **--permanent** permet de persister la règle afin qu'elle soit toujours active même après le redemarrage du serveur.

- rechargeons les configurations afin que de nouvelles autorisations soient prises en compte

```
sudo firewall-cmd --reload
```

Pour vérifier, nous pouvons à nouveau lister en détails les zones actives

```
sudo firewall-cmd --list-all
```

- affichons les 4 dernières lignes du fichier **/etc/passwd** pour voir les 4 utilisateurs ajoutés

```
tail -4 /etc/passwd
```

- autorisons les utilisateurs **cloud_user**, **rodrigue** et **willbrid** à accéder par ssh

```
sudo vim /etc/ssh/sshd_config
```

```
AllowUsers cloud_user rodrigue willbrid
```

```
sudo systemctl restart sshd
```

Ainsi si nous essayons de nous connecter avec un utilisateur non autorisé, la tentative d'accès sera rejetée.

- affichons les groupes des utilisateurs **cloud_user**, **rodrigue**, **willbrid**, **super** et **lois**

```
id cloud_user
id rodrigue
id willbrid
id super
id lois
```

Les utilisateurs **cloud_user**, **rodrigue** et **super** ont le même groupe **ops**.

- autorisons le groupe **ops** à accéder par ssh

```
sudo vim /etc/ssh/sshd_config
```

```
# AllowUsers cloud_user rodrigue willbrid
AllowGroups ops
```

```
sudo systemctl restart sshd
```

Si nous essayons de nous connecter avec les utilisateurs **willbrid** et **lois** qui ne font pas parti du groupe **ops**, la tentative d'accès sera rejetée.
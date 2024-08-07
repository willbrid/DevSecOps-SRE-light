# Créer, supprimer et modifier des groupes locaux et des adhésions à des groupes

La gestion de l'accès des utilisateurs est l'une des nombreuses tâches importantes pour un administrateur système Linux. L’utilisation de groupes peut contribuer à rendre cette tâche beaucoup plus facile.

La gestion de groupe est une autre activité courante, mais critique, que nous effectuerons en tant qu'administrateur système.

### Ajouter un groupe à notre système

- **groupadd**

```
groupadd newgroup
```

--- Commande disponible sur toutes les distributions, idéale pour les scripts

- **addgroup**

Interactif
```
addgroup
```

```
addgroup newgroup
```

--- script de haut niveau, non disponible sur toutes les distributions

- **gpasswd**

```
gpasswd groupname
```

--- Utilisé pour définir un mot de passe pour un groupe

**Exemple**

Listons l'ensemble des groupes d'un système

```
cat /etc/group
```

Les informations contenues dans le fichier **/etc/group** : la première colonne est le **nom du groupe**, la deuxième colonne n'est plus utilisée et sera un **x**, la troisième colonne est le **GUID** du groupe et la dernière colonne est une liste des utilisateurs membres du groupe.

Ajoutons les groupes **group1** et **group2**

```
sudo groupadd group1
```

```
sudo groupadd group2
```

Vérifions la présence du groupe **group1**

```
cat /etc/group | grep group1
```

Ajoutons le groupe **group2** (**addgroup** disponible sous ubuntu)

```
sudo addgroup group2
```

Vérifions la présence du groupe **group2**

```
cat /etc/group | grep group2
```

Listons tous les groupes auxquels l'utilisateur courant appartient

```
groups
```

```
id
```

Listons tous les groupes auxquels un utilisateur (par exemple l'utilisateur **sshd**) appartient

```
groups sshd
```

```
id sshd
```

Changeons le mot de passe du groupe **group1**

```
sudo gpasswd group1
```

Connectons nous au groupe **group1**

```
newgrp group1
```

La commande est utilisée pour modifier l'**ID de groupe actuel** lors d'une session de connexion. Si le mot de passe a été défini alors l'on sera amené à entrer ce mot de passe.

Créons un fichier **test1** et affichons son groupe

```
touch test1
ls -l test1
```

Nous constatons que le fichier **test1** appartient au groupe **group1**.

Quittons de la session du groupe **group1**

```
exit
```

### Gérer les utilisateurs et les groupes

- **usermod**

```
usermod -aG groupname useraccount
```

--- Ajoute un utilisateur à un groupe <br>
--- a = ajouter, G = groupe

- **gpasswd**

```
gpasswd -d username groupname
```

--- Supprime un utilisateur d'un groupe 

**Exemple**

Ajoutons l'utilisateur **sshd** au groupe **group1**

```
sudo usermod -aG group1 sshd
```

Vérifions les groupes de l'utilisateur **sshd**

```
cat /etc/group | grep sshd
```

Ajoutons l'utilisateur **sshd** au groupe **group2**

```
sudo gpasswd -a sshd group2
```

Enlevons l'utilisateur **sshd** au groupe **group1**

```
sudo gpasswd -d sshd group1
```

**NB**: On peut aussi modifier le groupe d'un utilisateur directement dans le fichier **/etc/group** grace à un éditeur tel que : **vim**. Mais cette méthode n'est pas récommandée.

### Supprimer un groupe de notre système

- **groupdel**

```
groupdel groupname
```

--- Commande disponible sur toutes les distributions

- **delgroup**

```
delgroup groupname
```

--- Utilitaire de haut niveau, non disponible sur toutes les distributions <br>
--- Peut être exécuté de manière interactive

**Exemple**

Supprimons le groupe **group1**

```
sudo groupdel group1
```

Vérifions la présence du groupe **group1**

```
cat /etc/group | grep group1
```

Supprimons le groupe **group2** (disponible sous ubuntu)

```
sudo delgroup group2
```

### Utilitaire d'édition du fichier /etc/group

L'on peut éditer le fichier **/etc/group** grâce à l'utilitaire **vigr**.

```
sudo vigr
```
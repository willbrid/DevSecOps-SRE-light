# Créer, supprimer et modifier des comptes d'utilisateurs locaux

En tant qu'administrateur système Linux, la maintenance des utilisateurs est une tâche simple mais très importante que nous effectuerons pour gérer l'accès à nos systèmes.

La gestion des utilisateurs est l'une des activités les plus courantes mais les plus critiques que nous effectuerons en tant qu'administrateur système.

### Ajouter un utilisateur à notre système

- **useradd**

```
useradd newUser
```

--- Commande disponible sur toutes les distributions <br>
--- Crée uniquement un compte, définit le shell par défaut sur **/bin/sh**

**Exemple**

Créons un utilisateur **testuser1**

```
sudo useradd testuser1
```

Vérifions que l'utilisateur est bien créé

```
sudo cat /etc/passwd
```

Affichons l'identifiant d'utilisateur et de groupe de l'utilisateur **testuser1**

```
id testuser1
```

Vérifions que l'utilisateur **testuser1** n'a pas de repertoire personnel

```
ls -alh /home
```

Créons un utilisateur **testuser2** sans son repertoire personnel et le shell **/bin/bash**

```
sudo useradd -M -s /bin/bash testuser2
```

Vérifions que l'utilisateur **testuser2** n'a pas de repertoire personnel

```
ls -alh /home
```

Ajoutons un mot de passe à l'utilisateur **testuser2**

```
sudo passwd testuser2
```

- **adduser**

```
adduser newUser
```

--- Utilitaire de haut niveau, non disponible sur toutes les distributions <br>
--- Créera un compte et un répertoire personnel, puis demandera un mot de passe

**Exemple**

Créons un utilisateur **testuser3**

```
sudo adduser testuser3
```

### Modifier un utilisateur sur notre système

- **usermod**

```
usermod -c "Commentaire" useraccount
```

--- Commande utilisée pour mettre à jour un compte utilisateur existant <br>
--- Peut mettre à jour n'importe quel attribut d'un compte utilisateur à l'exception du compte

**Exemple**

Mettons à jour l'attribut commentaire sur le compte utilisateur **testuser2**

```
sudo usermod -c "Compte testuser2" testuser2
```

Vérifions que l'utilisateur **testuser2** est bien modifié

```
sudo cat /etc/passwd
```

Ajoutons l'utilisateur **testuser2** au groupe **lxd**

```
sudo usermod -aG lxd testuser2
```

Vérifions que l'utilisateur **testuser2** appartient au groupe **lxd**

```
id testuser2
```

### Supprimer un utilisateur de notre système

- **userdel**

```
userdel useraccount
```

--- Commande héritée disponible sur toutes les distributions <br>
--- Combiner avec **-r** pour supprimer le répertoire personnel

**Exemple**

Supprimons l'utilisateur **testuser2**

```
sudo userdel testuser2
```

- **deluser** (disponible par défaut sur ubuntu)

```
deluser useraccount
```

--- Utilitaire de haut niveau, non disponible sur toutes les distributions <br>
--- Peut créer une sauvegarde du répertoire personnel avant de supprimer le compte

**Exemple**

Supprimons l'utilisateur **testuser3** en sauvegardant son répertoire personnel

```
sudo deluser --backup --backup-to /home --remove-home testuser3
```
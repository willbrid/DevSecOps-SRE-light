# Cas pratique

### Créer un groupe tester

Utilisons la commande **groupadd** avec l'option **-r** pour créer le groupe tester

```
sudo groupadd -r tester
```

Pour vérifier nous faisons

```
cat /etc/group | grep tester
```

### Créer un utilisateur test1 en l'ajoutant comme membre du groupe tester

Utilisons la commande **useradd** avec l'option **-G** pour l'intégrer dans le groupe **tester**

```
sudo useradd -G tester test1
```

Pour vérifions nous faisons

```
cat /etc/passwd | grep test1
```

```
id test1
```

### Définir un mot de passe temporaire (que l'utilisateur devra modifier lors de sa première connexion)

Mot de passe : **testtest**
```
sudo passwd test1
```

### Permettre à test1 de changer son mot de passe lors de la prochaine connexion

```
sudo chage -d0 test1
```

### Ajouter vagrant au groupe tester

Utilisons la commande **usermod** avec les options **-aG** pour ajouter **vagrant** au groupe **tester**

```
sudo usermod -aG tester vagrant
```

Pour vérifier, nous faisons

```
id vagrant
```

### Créer le répertoire /usr/local/test_scripts appartenant à l'utilisateur vagrant et définisser l'autorisation GID pour le groupe tester sans accès aux autres

```
sudo mkdir /usr/local/test_scripts
```

```
sudo chown vagrant:tester /usr/local/test_scripts
```

Pour vérifier, nous faisons

```
ls -ld /usr/local/test_scripts
```

```
stat /usr/local/test_scripts
```

Permettons à tous les membres du groupe **tester** d'avoir accès au repertoire **/usr/local/test_scripts** et supprimerons tout accès à toute autre personne

```
sudo chmod g+ws,o-rx /usr/local/test_scripts
```

Pour vérifier, nous faisons

```
ls -ld /usr/local/test_scripts
```

```
stat /usr/local/test_scripts
```

Le résultat signifie que le propriétaire et le groupe ont tous deux des autorisations de lecture/écriture/exécution, et que personne d'autre n'a d'autorisations. Cela signifie également que tout ce qui est créé dans ce répertoire appartiendra au groupe **tester**, quel que soit l'utilisateur qui crée le fichier.

La commande **chmod +s** définit à la fois les bits **UID** et **GID**, la commande **chmod u+s** définit uniquement le bit **UID** et la commande **chmod g+s** définit uniquement le bit **GID**.

Les bits **UID** et **GID** permettent au programme de s'exécuter en tant que propriétaire et/ou groupe du propriétaire - plutôt qu'en tant qu'utilisateur et groupe de celui qui l'a réellement démarré. Par exemple, un programme peut toujours s'exécuter comme s'il avait été démarré par **root**. <br>
Disons que nous avons un **fichier exécutable** avec la propriété **root:adm**. La commande **chmod g+s** donnerait à un utilisateur du groupe **adm** d'exécuter le fichier et la commande **chmod +s** permettrait à un utilisateur du groupe **adm** de s'exécuter avec tous les privilèges **root**.

### Test

Connectons nous avec l'utilisateur **test1**

```
su - test1
```

Il nous est demandé de changer notre mot de passe. Nous mettons le nouveau mot de passe **cooltest**.

Accédons au repertoire **/usr/local/test_scripts**

```
cd /usr/local/test_scripts
```

Créons le repertoire **dir1** et le fichier **file1**

```
mkdir dir1
touch file1
```

Pour vérifons nous faisons

```
ls -l /usr/local/test_scripts
```

Nous constaterons que le contenu de ce repertoire appartient automatiquement au groupe **tester**.
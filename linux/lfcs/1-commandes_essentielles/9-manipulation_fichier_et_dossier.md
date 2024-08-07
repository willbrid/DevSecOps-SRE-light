# Créer, supprimer, copier et déplacer des fichiers et des répertoires

### Créer un fichier 

```
cd ~
```

Plusieurs façons de créer un fichier

```
touch filename1.txt
nano filename2.txt
command > filename3.txt
```

**Exemple :**

```
touch filename1.txt
nano filename2.txt # avec pour contenu : <Bonjour tout le monde>
echo "Bonjour tout le monde" > filename3.txt
cat filename3.txt > filename4.txt
```

### Copier un fichier

```
cp filename1.txt filename.txt
```

### Déplacer un fichier

```
mv filename1.txt Documents/filename1.txt
```

### Rénommer un fichier

```
mv filename.txt filename4.txt
```

### Créer un répertoire

```
mkdir path/to/directory
```

**Exemple :**

```
mkdir target1
mkdir target2
```

### Supprimer un fichier

```
rm filename4.txt
rm Documents/filename1.txt
```

### Supprimer un répertoire

- Ne fonctionne que si le répertoire est vide

```
rmdir directory
```

**Exemple :**

```
rmdir target1
```

- Supprime tous les fichiers ainsi que le répertoire

```
rm -r directory
```

**Exemple :**

```
rm -r target2
```

- Dangereux ! Supprime tous les fichiers et répertoires sans avertissement

```
rm -rf directory
```

### Transférer des fichiers en toute sécurité sur le réseau

Ici nous utiliserons nos deux serveurs provisionnés via vagrant : 

--- **rocky-server**, son user **vagrant** et son repertoire **/opt/app** contenant 2 fichiers **file1** et **file2**

```
sudo mkdir /opt/app && sudo chown -R vagrant:vagrant /opt/app && touch /opt/app/file1  /opt/app/file2
```

--- **ubuntu-server**, son user **vagrant** et son repertoire **/opt/api**

```
sudo mkdir /opt/api && sudo chown -R vagrant:vagrant /opt/api
```

- Sur le serveur **rocky-server** 

Utilisons **ls -lR /opt/** localement sur le serveur **rocky-server** et à distance sur le serveur **ubuntu-server** par ssh depuis le serveur **rocky-server**

```
ls -lR /opt
```

```
ssh vagrant@192.168.56.111 ls -lR /opt
```

Copions en toute sécurité le répertoire **/opt/app** du serveur **rocky-server** vers le répertoire **/opt/api** du serveur **ubuntu-server**

```
scp -rp /opt/app vagrant@192.168.56.111:/opt/api
```

L'option **-r** la rend récursif et **-p** lui permet de conserver les horodatages et les autorisations.

Créons un fichier **file3** dans le répertoire **/opt/app** du serveur **rocky-server**

```
touch /opt/app/file3
```

Synchronisons le répertoire **/opt/api/app** du serveur **ubuntu-server** avec le répertoire **/opt/app** du serveur **rocky-server**

```
rsync -aP /opt/app/ vagrant@192.168.56.111:/opt/api/app/
```

Vérifions que les répertoires **/opt/api/app** du serveur **ubuntu-server** et **/opt/app** du serveur **rocky-server** sont les mêmes.

Sur **rocky-server**
```
ls -lR /opt/app
```

Sur **ubuntu-server** depuis le serveur **rocky-server**
```
ssh vagrant@192.168.56.111 ls -lR /opt/api/app
```

Nous pouvons utiliser la commande **rsync** pour vérifier que le **contenu**, les **horodatages** et les **autorisations** sont les mêmes.

```
rsync -naP /opt/app/ vagrant@192.168.56.111:/opt/api/app/
```

L'option **-n** (**--dry-run**) permet d'effectuer un **dry-run** sans aucune modification, l'option **-a** permet d'activer le mode **archive** et l'option **-P** est équivalent aux options combinées **--partial --progress** qui permettent de conserver les fichiers partiellement transférés (**--partial**) et d'afficher la progression pendant le transfert (**--progress**). Si l'on souhaite conserver les autorisations de fichiers il faudrait utiliser l'option **-p** (**--perms**).
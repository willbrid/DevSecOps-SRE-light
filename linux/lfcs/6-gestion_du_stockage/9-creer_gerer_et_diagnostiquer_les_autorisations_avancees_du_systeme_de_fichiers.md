# Créer, gérer et diagnostiquer les autorisations avancées du système de fichiers

Les autorisations **RWE** standard ne fournissent pas toujours l'accès correct aux utilisateurs, un administrateur système Linux doit donc savoir comment utiliser les autorisations avancées pour combler les lacunes. Pour répondre à des exigences d'autorisation et/ou à des situations inhabituelles, un administrateur système Linux dispose d'options supplémentaires : le **sticky bit** , **setgid** et **setuid**.

### Sticky bit (1 -> o+t)

Autorisation définie sur un répertoire qui autorise uniquement le propriétaire ou l'utilisateur root à supprimer ou renommer le contenu du répertoire.

- Créons un groupe **docker** et ajoutons l'utilisateur **vagrant** à ce groupe

```
sudo groupadd docker
```

```
sudo usermod -aG docker vagrant
```

L'on se déconnecte, puis se reconnecte avec l'utilisateur **vagrant** pour que les changements prennent effet.

- Créons un repertoire **/opt/perms** et configurons l'autorisation sur propriétaire **root** et groupe propriétaire **docker**

```
sudo mkdir /opt/perms
```

```
sudo chown -R root:docker /opt/perms
```

- Appliquons le **Sticky bit** sur le repertoire **/opt/perms**

```
sudo chmod 1770 /opt/perms
```

Nous pouvons vérifier en listant le contenu du repertoire **/opt**, puis constater la présence d'une lettre **T** à la fin de la 3ème colonne de la section d'autorisation au niveau de la ligne affichant le repertoire **perms**

```
ls -alh /opt
```

- Dans le repertoire **/opt/perms**, créons le fichier **cloudfile** avec l'utilisateur **vagrant** et **rootfile** avec l'utilisateur **root**, ensuite modifions le groupe propriétaire du fichier **rootfile** pour le groupe **docker** et enfin donnons lui les autorisations **660**

```
cd /opt/perms
```

```
touch cloudfile
```

```
sudo touch rootfile
```

```
sudo chown :docker rootfile
```

```
sudo chmod 660 rootfile
```

Editons le fichier **rootfile** avec l'utilisateur **vagrant**

```
vi rootfile
```

```
Hello rootfile
```

Donc nous constatons qu'effectivement nous pouvons éditer ce fichier.

Si nous essayons de supprimer le fichier **rootfile** avec l'utilisateur **vagrant**, nous aurons en sortie un message précisant que nous n'avons pas les autorisations.

```
rm rootfile
```

### Setgid (2 -> g+s)

- Lorsqu'il est défini sur un exécutable, au lieu de s'exécuter avec les privilèges du groupe de l'utilisateur qui l'a exécuté, il s'exécutera avec ceux du groupe propriétaire du fichier.

- Lorsqu'il est défini sur un répertoire, il modifie le comportement par défaut afin que le groupe des fichiers créés à l'intérieur du répertoire ne soit pas celui de l'utilisateur qui les a créés mais celui du groupe sur le répertoire parent lui-même

--- Appliquons le **Setgid** sur le repertoire **/opt/perms** avec son même **Sticky bit**

```
sudo chmod 2770 /opt/perms
```

Pour vérifier la configuration du **Setgid**, nous listons le contenu du repertoire **/opt**, puis nous constaterons la présence d'une lettre **s** à la fin de la 2ème colonne de la section d'autorisation au niveau de la ligne affichant le repertoire **perms**.

```
ls -alh /opt
```

Appliquons le **Sticky bit** et **Setgid** sur le repertoire **/opt/perms**

```
sudo chmod 3770 /opt/perms
```

--- Dans le repertoire **/opt/perms**, créons le fichier **cloudfile2** avec l'utilisateur **vagrant** et **rootfile2** avec l'utilisateur **root**,

```
cd /opt/perms
```

```
touch cloudfile2
```

```
sudo touch rootfile2
```

```
ls -alh
```

Nous constatons que tout nouveau fichier créé dans le repertoire **/opt/perms** aura **docker** comme groupe propriétaire.

### Setuid (4 -> u+s)

- Autorisation définie sur un fichier de sorte que lorsqu'un exécutable est lancé, il s'exécutera avec les privilèges du propriétaire plutôt qu'avec ceux de l'utilisateur.

Par exemple le fichier exécutable **/usr/bin/passwd** possède la configuration du **Setuid**. Nous pouvons le vérifier en appliquant la commande **ls** sur le fichier **/usr/bin/passwd**, puis nous constaterons la présence d'une lettre **s** à la fin de la 1ère colonne de la section d'autorisation.

```
ls -alh /usr/bin/passwd
```

Pour appliquer la configuration **Setuid** sur un fichier

```
sudo chmod 4755 filename
```

### Rechercher un fichier ayant une configuration précise

- Recherchons tous les fichiers avec la configuration **Setgid**

```
sudo find / -type d -perm -2000
```

- Recherchons tous les fichiers avec les configurations **Sticky bit** et **Setgid**

```
sudo find / -type d -perm -3000
```
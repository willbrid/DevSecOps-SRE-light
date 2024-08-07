# Répertorier, définir et modifier les autorisations de fichiers standard

Tout le monde a accès à un fichier contenant des données sensibles. Un associé a appelé et doit posséder un répertoire de projet.

- Préréquis

```
cd ~ && mkdir projects && echo "This file is named info.txt" > projects/info.txt
```

### Quelles sont les options d'autorisation ?

Nous pouvons afficher les informations d'autorisation et de propriété à l'aide de la commande **ls** avec l'option **-l**. 

```
drwxr-xr-x 5 linux linux 4096 Oct 4 14:06 Documents
```

- La première partie de la première colonne peut avoir 3 valeurs :

--- le premier est un **-** qui indique qu'il s'agit d'un fichier <br>
--- la deuxième valeur est un **d**, qui indique un répertoire <br>
--- et la troisième valeur est un **l**, qui indique un lien 

- La partie suivante de la première colonne concerne les autorisations réelles des fichiers. Ceux-ci sont affichés sous forme de 3 groupes de 3 lettres :

--- Le premier groupe de 3 lettres est destiné à l'utilisateur ou au propriétaire du fichier. <br>
--- Le deuxième groupe de 3 lettres est destiné au groupe. <br>
--- Et la troisième série de 3 lettres est destinée à tous les autres utilisateurs.

Nous pouvons utiliser le processus symbolique ou le processus octal. La lettre **r** signifie **lire**, la lettre **w** signifie **écrire** et la lettre **x** signifie **exécuter**. En valeurs octales, la **valeur de lecture** est un **4**, la **valeur d’écriture** est un **2** et la **valeur d’exécution** est un **1**.

Et puis il existe également des autorisations spéciales :

--- Le premier est le **suid** : il s'agit d'une autorisation spéciale qui permet à un fichier en cours d'exécution de s'exécuter avec les privilèges du propriétaire. Le **suid** est représenté par un **s** et a une valeur octale de **4000**.

--- Le deuxième est le **sguid**. Ceci est similaire au **suid**, mais il permet au fichier d'être exécuté avec les privilèges de groupe plutôt qu'avec les privilèges de propriétaire. Ceci est également représenté par un **s** et a une valeur octale de **2000**.

--- Le troisième est le **sticky** : il s'agit d'une autorisation spéciale qui interdit à un utilisateur non propriétaire ou non groupe de déplacer, supprimer ou renommer un fichier. Ceci est représenté par la lettre **t** et a une valeur octale de **1000**.

- Pour la troisième et quatrième colonne, ces 2 valeurs indiquent ici le **propriétaire** et le **groupe**. La première valeur est le **propriétaire**. Dans cet exemple, il s'agit de Linux. La deuxième valeur indique le **groupe**. Dans cet exemple, le groupe est également **Linux**.

### Exemples de modification des autorisations

- Accorder un accès complet à tout le monde

```
chmod 777 filename
```

```
chmod u+rwx filename
```

**u=user, g=group, o=other** <br>
La 2ème commande doit être répétée pour chaque ensemble. <br>

Exemples: 

```
cd ~/projects
```

```
chmod 777 info.txt
```

```
ls -lhF
```

- Supprimer l'accès à l'exécution du groupe et autres

```
chmod 766 filename
```

```
chmod g-x,o-x filename
```

**u=user, g=group, o=other** <br>
La 2ème commande doit être répétée pour chaque ensemble.

Exemples :

```
chmod g-x,o-x info.txt
```

```
ls -lhF
```

### Exemples de modification du propriétaire

- Changer le propriétaire et groupe du fichier/répertoire

```
chown owner directoryname
chown :group directoryname
chown owner:group directoryname
chown owner filename
chown :group filename
chown owner:group filename
```

Exemples

```
sudo chmod root info.txt
sudo chmod :root info.txt
sudo chmod root:root info.txt
```

```
ls -lhF
```
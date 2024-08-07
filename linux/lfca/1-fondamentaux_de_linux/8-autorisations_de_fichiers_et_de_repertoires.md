# Autorisations de fichiers et de répertoires

## Définition

- **chown** : change le propriétaire du fichier et le groupe. L'option -R peut être utilisée pour modifier les fichiers et les répertoires de manière récursive.

- **chgrp** : change le groupe propriétaire.

- **chmod** : modifie les autorisations d'un fichier. Le format peut être : <br>
--- en mode symbolique : lire (r), écrire (w), exécuter (x) <br>
--- en mode octal (0-7) : lecture (4), écriture (2), exécution (1) <br>

Lorsque nous exécutons la commande **ls -l**, parmi les informations qu'elle affiche, nous avons les groupes de 3 autorisations qui vont spécifier chacun l'autorisation pour l'**utilisateur** (**u** : user), le **groupe** (**g** : group) et **autre utilisateur** (**o** : other). <br>
Par exemple en appliquant la commande :

```
ls -l test01
```

on aura en sortie :

```
-rw-rw-r--. 1 cloud_user cloud_user 5 Jan 17 21:20 test01
```

## Pratiques

- hypothèse

Nous nous loguons avec notre utilisateur courant (dans notre cas **cloud_user**) et nous substituons d'utilisateur avec l'utilisateur **rodrigue** précédemment créé.

```
su - rodrigue
```

Dans le repertoire **/tmp**, créons un fichier test2 avec pour contenu **secret text**.

```
cd /tmp
vim test2
```

```
secret text
```

Dans ce même repertoire **/tmp**, creons un fichier **test1** et un repertoire **ops_team**. Puis dans ce repertoire (**ops_team**), créons un fichier **test1**.

```
cd /tmp
echo "Bonjour tout le monde" > test1
mkdir ops_team
mkdir dev_team
touch ops_team/test1
```

Si nous exécutons la commande **ls -l**, on aura :

```
drwxr-xr-x. 2 rodrigue ops  19 Jan 19 04:25 ops_team
-rw-r--r--. 1 rodrigue ops  12 Jan 19 04:25 test2
```

Le premier symbole le plus à gauche représente le **descripteur du type de fichier** : il permet d'indiquer si c'est un fichier (**-**), un repertoire (**d**) ou un lien symbolique(**l**).

- enlevons l'autorisation de lecture sur le fichier test2 à tous les autres utilisateurs.

```
chmod o-r test2
ls -l
```

```
-rw-r-----. 1 rodrigue ops  12 Jan 19 04:25 test2
```

- au fichier **test1**, appliquons les autorisations de :

--- lecture-écriture à l'utilisateur <br>
--- lecture-écriture aux groupes de l'utilisateur <br>
--- lecture aux autres utilisateurs <br>

```
chmod 664 test1
```

```
-rw-rw-r--. 1 rodrigue ops   0 Jan 19 04:36 test1
```

- au repertoire **ops_team**, ajoutons l'autorisation d'écriture aux groupes de l'utilisateur et enlevons l'autorisation d'exécution aux autres utilisateurs.

```
chmod g+w,o-x ops_team
```

- au repertoire **dev_team**, ajoutons l'autorisation de lecture, écriture et d'exécution à l'utilisateur, puis de lecture, écriture aux groupes de l'utilisateur et enfin enlevons l'autorisation d'exécution aux autres utilisateurs.

```
chmod u+r+w+x,g+r+w,o-x dev_team
```

- Revenons à notre utilisateur courant (dans notre cas **cloud_user**)

```
exit
```

--- Essayons d'afficher le contenu du fichier **/tmp/test2**

```
cat /tmp/test2
```

Nous aurons en sortie : ce qui signifie que nous n'avons pas les droits de lecture sur ce fichier puisque tous les autres utilisateurs n'ont aucun droit sur ce fichier.

```
cat: test2: Permission denied
```

```
-rw-r-----. 1 rodrigue ops  12 Jan 19 04:25 test2
```

--- Essayons d'afficher le contenu du fichier **/tmp/test1**

```
cat /tmp/test1
```

Nous aurons en sortie :

```
Bonjour tout le monde
```

Nous constatons que nous pouvons effectivement afficher ce contenu (qui est vide). Cependant nous ne pouvons pas modifier ce fichier puisque tous les autres utilisateurs ont uniquement les droits de lecture sur ce fichier.

```
-rw-rw-r--. 1 rodrigue ops  22 Jan 19 05:05 test1
```

--- Essayons d'accéder au repertoire **/tmp/ops_team**

```
cd /tmp/ops_team
```

Nous aurons en sortie :

```
-bash: cd: /tmp/ops_team/: Permission denied
```

C'est normal puisque sur ce repertoire, les autres utilisateurs ont uniquement les droits de lecture (pas de droit d'exécution pour pouvoir y accéder).

- changeons le groupe propriétaire du repertoire **/tmp/ops_team**

```
sudo chgrp cloud_user /tmp/ops_team
ls -ld /tmp/ops_team
```

```
drwxrwxr--. 2 rodrigue cloud_user 19 Jan 19 04:25 /tmp/ops_team/
```

Si nous souhaitons changer de groupe propriétaire du répertoire **/tmp/ops_team** de manière récursive, nous faisons :

```
sudo chgrp -R cloud_user /tmp/ops_team
```

L'option **-R** permet d'opérer le changement de manière récursive (c'est à dire le repertoire et tout son contenu).

- Nous pouvons à présent accéder (ou lister) à son contenu avec l'utilisateur **cloud_user**

```
cd /tmp/ops_team
ls -l /tmp/ops_team
```
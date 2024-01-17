# Introduction à Git [part1]

**Git** est un système de gestion de versions décentralisé (DVCS) qui permet de suivre les modifications dans les fichiers et les répertoires au fil du temps. Il a été développé par Linus Torvalds en 2005 pour la gestion du noyau Linux, mais il est depuis devenu l'un des systèmes de gestion de versions les plus populaires et largement utilisés dans le développement logiciel.

- Vérifier la version de **git installée

```
git --version
```

- Vérifier que si Git est déjà configuré avec ces informations : email (**user.email**) et nom d'utilisateur (**user.name**)

```
git config --list
```

- Configurer les informations : email (**user.email**) et nom d'utilisateur (**user.name**)

```
git config --global user.email "ngaswilly77@gmail.com"
git config --global user.name "willbrid"
```

- Configurer notre ordinateur pour que les nouveaux projets utilisent la branche principale **main**

```
git config --global init.defaultBranch main
```

- Créer un référentiel git

Nous allons créer un nouveau référentiel pour notre projet **Miam Miam Food**.

```
mkdir miam-miam-food
```

```
cd miam-miam-food
```

Prouvons qu’il ne s’agit pas encore d’un dépôt Git

```
git status
```

Transformons le répertoire en dépôt Git

```
git init
```

Prouvons qu’il s’agit maintenant d’un dépôt Git

```
git status
```

- Créer un fichier **main.go** dans le repertoire **miam-miam-food**

```
vi main.go
```

```
package main

import "fmt"

func main() {
    fmt.Println("Bonjour et Bienvenu chez MIAM MIAM FOOD !")
}
```

Notre répertoire contient un fichier, mais Git ne suit pas encore ce fichier, puisque nous ne l'avons pas officiellement ajouté au référentiel.

- Ajouter le fichier **main.go** au référentiel

```
git add main.go
```

Si nous exécutons à nouveau **git status**, nous verrons que **main.go** est désormais inclus dans une liste de modifications à valider, ce qui signifie qu'il a été ajouté à la zone d'attente de validation mais n'a pas encore été validé.

```
git status
```

- Effectuer un commit du fichier **main.go**

```
git commit --message "add entry point of project"
```

Si nous exécutons à nouveau **git status**, nous verrons qu'aucun fichier n'est en attente de validation, ce qui signifie que notre fichier **main.go** a été conservée en toute sécurité dans le référentiel et que toutes les modifications futures y seront suivies par Git.

```
git status
```

- Afficher les informations pour chaque validation (**commit**) : le **SHA**, l'**auteur**, la **date** et le **message**

```
git log
```

- Exclure un fiichier ou un repertoire du référentiel git

créeons un fichier **secret.txt** et un repertoire **build** dont nous ne souhaiterons pas ajouter dans notre référentiel

```
echo "password: 12345678" > secret.txt
mkdir build
```

Avec la commande **git status** nous constatons que git nous avertit que le fichier **secret.txt** et le répertoire **build** sont non validés.

```
git status
```

Créons notre fichier **.gitignore** afin d'ignorer le fichier **secret.txt** et le répertoire **build**

```
vi .gitignore
```

```
# fichier contenant les paramètres d'authentification
secret.txt

# fichier de build de notre projet
build/
```

Ajoutons le fichier **.gitignore** à notre référentiel

```
git add .gitignore
```

```
git commit --message "exclude secret file and build repository project"
```

Avec la commande **git status** nous constatons que git ne nous avertit plus du fichier **secret.txt** et répertoire **build** non validés.

```
git status
```
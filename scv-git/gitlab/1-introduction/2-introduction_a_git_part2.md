# Introduction à Git [part2]

### Etiqueter un commit

L'**étiquetage** est simple : c'est un moyen d'ajouter une étiquette permanente à un commit. Il existe de nombreuses raisons d'étiqueter, mais les deux plus courantes sont d'étiqueter la version exacte du code qui est publiée auprès des clients et de disposer d'un moyen pratique de revenir à une version particulière du code si nous devons annuler un grand nombre de modifications.

- Etiquetons notre projet

```
git tag version-1-0-alpha
```

- Listons les étiquettes de notre projet

```
git tag --list
```

- supprimons l'étiquette **version-1-0-alpha** de notre projet

```
git tag --delete version-1-0-alpha
```

### Gérer les branches

Une branche est une référence de code qui pointe vers un commit spécifique. Les branches sont utilisées pour travailler sur des fonctionnalités isolées, des correctifs de bugs, des tâches, etc., sans perturber le reste du code. Chaque branche représente une ligne de développement indépendante.

Lorsque nous créons une nouvelle branche, elle est basée sur le commit actuel (la version du code à ce moment-là). Nous pouvons apporter des modifications à cette branche sans affecter la branche principale (habituellement appelée "master" ou "main"). Une fois que nous avons terminé de travailler sur la branche, nous pouvons la fusionner avec la branche principale pour intégrer les modifications.

Les branches facilitent la collaboration et le développement parallèle dans les projets Git, permettant à plusieurs personnes de travailler sur différentes fonctionnalités ou corrections en même temps.

- Créons une branche pour la fonctionnalité login

```
git branch login-feature
```

- Listons l'ensemble des branches existantes

```
git branch
```

- Il existe deux commandes différentes que nous pouvons utiliser pour passer à une autre branche

```
git checkout login-feature
```

ou

```
git switch login-feature
```

- Dans la branche **login-feature**, faisons une petite modification

```
vi main.go
```

```
package main

import "fmt"

func main() {
    fmt.Println("Bonjour et Bienvenu chez MIAM MIAM FOOD !")
    fmt.Println("La fonctionnalité login sera prêt bientôt !")
}
```

On supposera que la fonctionnalité **login** est terminée. Validons cette modification dans la branche **login-feature**.

```
git add main.go
```

```
git commit -m "feat: implement login feature"
```

- Fusionnons la branche **login-feature** à la branche **main**

```
git switch main 
```

```
git merge login-feature
```

- Supprimons la branche **login-feature**

```
git branch --delete login-feature
```

Si nous n'avons pas fusionné une branche avant d'essayer de la supprimer, Git nous avertira et ne supprimera pas cette branche. Nous pouvons forcer la suppression de la branche.

```
git branch --delete --force login-feature
```

### Gérer des conflits de fusion

Lorsque nous essayons de fusionner une branche dans une autre, nous rencontrerons parfois ce qu’on appelle un **conflit de fusion**. Cela signifie que quelqu'un d'autre a modifié les mêmes lignes du même fichier que nous et qu'il a déjà fusionné sa branche dans **main** avant que nous ayons la possibilité de fusionner notre branche dans **main**. Lorsque nous essayons de fusionner notre branche, Git ne sait pas s'il doit conserver les modifications apportées par l'autre développeur ou les modifications que nous essayons de fusionner.

Pour poursuivre notre fusion, nous devons d'abord résoudre le **conflit de fusion**. Il y a plusieurs moyens de le faire via :
- les outils graphiques Git tels que **Sourcetree** ou **Sublime Merge**
- les commandes Git et un éditeur de code tel que **vscode**.
- l'outil graphique intégré de résolution des conflits de fusion de GitLab

### Synchronisation des copies locales et distantes des référentiels

- Affichons des informations détaillées sur les référentiels distants associés à notre référentiel Git local. 

```
git remote --verbose
```

--- La première ligne montre l'URL que le référentiel utilise pour récupérer les modifications (**fetch**) depuis le référentiel distant. <br>
--- La deuxième ligne montre l'URL que le référentiel utilise pour pousser (**push**) les modifications vers le référentiel distant.

- Clonons notre référentiel distant

Nous supposerons que nous avons notre référentiel distant **miam-miam-food** à l'adresse **https://gitlab.local/willbrid/miam-miam-food**

```
mkdir code && cd code
```

```
git clone https://gitlab.local/willbrid/miam-miam-food
```

- Poussons une branche locale **login-feature** vers le référentiel distant

```
git push --set-upstream origin login-feature
```

- Récupérons les informations de changement effectué sur une branche

```
git fetch
```

- Récupérons les nouvelles modifications effectué sur la branche **login-feature** sur le référentiel distant

```
git switch login-feature
```

```
git pull
```

- Vérifions si notre branche locale **login-feature** est derrière la copie de la branche **login-feature** du référentiel distant

```
git status
```
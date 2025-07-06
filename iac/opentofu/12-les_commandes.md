# Quelques commandes opentofu

### Commande : tofu validate

```
tofu validate
```

Elle permet de vérifier la validité de la configuration :
- si tout est correct, un message de validation réussi s’affiche.
- en cas d’erreur, la commande indique la ligne fautive et donne des conseils de correction.

### Commande : tofu fmt

```
tofu fmt
```

Elle sert à formater automatiquement les fichiers de configuration dans le répertoire courant, selon un style canonique. Elle est utile pour améliorer la lisibilité du fichier de configuration OpenTofu.

### Commande : tofu show

```
tofu show
```

Elle permet d'afficher l'état actuel de l'infrastructure tel qu'il est visualisé par OpenTofu. Nous pouvons également utiliser l'option **-json** pour afficher le contenu au format JSON.

### Commande : tofu providers

```
tofu providers
```

Elle permet d'afficher tous les fournisseurs utilisés par la configuration.

### Commande : tofu output

```
tofu output
```

Elle permet d'afficher toutes les variables de sortie du répertoire de configuration.

```
tofu output var_name
```

Elle permet aussi d'afficher la valeur d'une variable de sortie spécifique en ajoutant son nom.

### Commande : tofu refresh

```
tofu refresh
```

Elle permet de synchroniser l'**état OpenTofu** avec l'infrastructure réelle. Par exemple, si des modifications sont apportées à une ressource créée par **OpenTofu** en dehors de son contrôle, comme une mise à jour manuelle, cette commande les récupère et met à jour le fichier d'état. Il est important de noter que cette commande ne modifie aucune ressource d'infrastructure.

### Commande : tofu graph

```
tofu graph
```

Elle permet de créer une représentation visuelle des dépendances d'une configuration OpenTofu ou d'un plan d'exécution. Cette commande peut être exécutée dès qu'un fichier de configuration est prêt, avant même d'avoir initialisé le répertoire de configuration avec **tofu init**.
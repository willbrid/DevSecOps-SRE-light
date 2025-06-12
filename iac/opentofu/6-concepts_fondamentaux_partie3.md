# Concepts fondamentaux [partie3]

- **Définir les variables d'entrée**

Pour définir des variables, nous devons utiliser un bloc de **variable**. 

```
variable "filename" {
  default = "/root/pets.txt"
}
```

Il est courant de définir des variables dans un nouveau fichier appelé **variables.tf**. <br>
Cependant nous pouvons aussi très bien définir les blocs de variables avec la ressource dans le fichier **main.tf**.

Pour créer une variable, nous utilisons le mot-clé **variable** suivi du nom de la variable. Ce nom peut être quelconque, mais en règle générale, il faut utiliser un nom approprié.
Dans ce bloc, nous pouvons fournir une valeur par défaut pour la variable avec le mot clé **default**. Il s'agit d'un argument facultatif, mais c'est un moyen simple et rapide d'attribuer des valeurs aux variables.

```
# main.tf
resource "local_file" "pet" {
  filename = var.filename
  content = var.content
  file_permission = "0700"
}
resource "random_pet" "my-pet" {
  prefix = var.prefix
  separator = var.separator
  length = var.length
}
```

```
# variables.tf
variable "filename" {
  default = "/root/pets.txt"
}
variable "content" {
  default = "We have some pets"
}
variable "prefix" {
  default = "Mrs"
}
variable "separator" {
  default = "."
}
variable "length" {
  default = "1"
}
```

Pour utiliser ces variables dans notre fichier de configuration, nous pouvons remplacer les valeurs des arguments par les noms de variables préfixés par **"var."**. Il est important de noter que lorsque nous utilisons des variables dans la configuration, il n'est pas nécessaire d'entourer les valeurs de guillemets doubles, contrairement aux valeurs réelles. <br>
Pour mettre à jour la ressource, il suffit de modifier la valeur de la variable dans le bloc de variables.

Nous pouvons également définir un bloc de variables de cette manière, sans l'argument par défaut.

```
# variables.tf
variable "filename" {

}
variable "content" {

}
variable "prefix" {

}
variable "separator" {

}
variable "length" {

}
```

La valeur par défaut est ici facultative. Même si elle est spécifiée, nous pouvons la remplacer lors de l'exécution des opérations OpenTofu.

--- Lorsque nous exécutons **tofu apply**, sans renseigner les variables, nous serons invités à saisir les valeurs des variables que nous avons déclarées dans notre configuration.

--- Une façon de transmettre des valeurs à ces variables lors de l'exécution est d'utiliser l'option « **dash var** » avec le format « nom de variable égal à valeur ».

```
tofu apply -var "filename=/root/pets.txt" -var "content=We have some pets" -var "prefix=Mrs" -var "separator='.'" -var "length='1'"
```

--- Au lieu d'utiliser des options de ligne de commande, nous pouvons également utiliser des variables d'environnement pour déclarer les variables. Pour ce faire, nous définissons chaque variable d'environnement avec un préfixe **TF_VAR_** en majuscules suivi du nom de la variable.

```
export TF_VAR_filename="/root/pets.txt"
export TF_VAR_content="We have some pets"
tofu apply
```
# Concepts fondamentaux [partie4]

- **Comprendre le bloc variable**

```
# variables.tf
variable "ami" {

}

variable "instance_type" {

}
```

Un bloc variable est parfaitement valide même s'il n'a aucun argument défini à l'intérieur. <br>
--- Une variable peut avoir une valeur par défaut via l’argument **default**. <br>
--- Il est aussi possible d’ajouter une description (recommandée), via l'argument **description** pour expliquer son usage. <br>
--- L’argument **type** permet de définir le type de données accepté. <br>
--- L’argument **sensitive**, optionnel, protège la valeur de la variable en la masquant dans les sorties (**tofu plan**, **tofu apply**) si défini sur **true**. Cependant, la valeur reste stockée dans l’état **OpenTofu**, qu’elle soit marquée comme **sensible** ou non.

```
# variables.tf
variable "ami" {
  default = "ami-0c2f25c1f66a1ff4d"
  desription = "type of AMI to use"
  type = string
  sensitive = true
}

variable "instance_type" {
  default = "t2.micro"
  desription = "size of EC2"
  type = string
  sensitive = false
}
```

Pour faire respecter une condition sur les valeurs des variables, on peut ajouter un bloc de validation dans leur définition, qui contient : <br>
--- une condition <br>
--- un message d'erreur personnalisé affiché si la condition n’est pas respectée.

```
# variables.tf
variable "ami" {
  default = "ami-0c2f25c1f66a1ff4d"
  desription = "type of AMI to use"
  type = string
  sensitive = true
  validation {
    condition = substr(var.ami, 0, 4) == "ami-"
    error_message = "the AMI should start with \"ami-\"."
  }
}
...
```

Donc ce bloc contient une condition, ici utilisant la fonction **substring**, pour vérifier que la valeur commence par **ami-** et Un message d'erreur personnalisé en cas d'échec de la condition. <br>
Lors d’un **tofu plan** ou **tofu apply** avec **-var**, **OpenTofu** affiche ce message si la valeur de la variable est invalide.

```
# Exemple d'échec de condition
tofu apply -var "ami=abc-1234567"
```

Le paramètre **type** est facultatif. S'il n'est pas spécifié dans le bloc variable, il est défini par défaut sur le type **any**.

- Les différents types de variables

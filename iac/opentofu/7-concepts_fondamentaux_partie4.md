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

- **Les différents types de variables**

--- Type **string**, **number** et **bool**

|Type|Description|Exemple|
|----|-----------|-------|
`string`|type chaine de caractères|`"hello world"`
`number`|type nombre : nombre entier, nombre décimal|`1`
`bool`|type booléen ayant deux valeurs possibles : `true` ou `false`|`true`

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

variable "count" {
  default = 2
  type = number
  description = "Count of VM's"
}

variable "monitoring" {
  default = true
  type = bool
  description = "Enable detailed monitoring"
}
```

Si l'argument **type** n'est pas configuré, alors sa valeur par défaut est : **any**.

En cas de non-concordance, OpenTofu essaiera de convertir la valeur par défaut en type défini. <br>
Si une conversion de type n'est pas possible, par exemple où le type est booléen mais la valeur par défaut est un nombre, OpenTofu produira une erreur.

--- Type **list**, **list of a type**, **map** et **map of a type**

|Type|Description|Exemple|
|----|-----------|-------|
`list`|type tableau|`["web1", "web2"]`
`map`|type tableau associatif|`{ "production" = "m5.large" }`

```
# variables.tf
...
...
variable "servers" {
  default = ["web1", "web2", "web3"]
  desription = "list of web servers"
  type = list
}

variable "instance_type" {
  type = map
  default = {
    "production" = "m5.large"
    "development" = "t2.micro"
  }
}
```

```
# main.tf
resource "aws_instance" "web" {
  ami = var.ami
  instance_type = var.instance_type["development"]
  tags = {
    name = var.servers[0]
  }
}
```

Dans notre exemple, nous avons une variable servers contenant **[web1, web2, web3]** : "web1" à l’index 0, "web2" à l’index 1, "web3" à l’index 2. <br>
Pour accéder à un élément, on utilise la syntaxe **var.nom_variable[index]**, comme **var.servers[0]** pour obtenir **"web1"**.

Dans notre exemple, une variable **instance_type** de type **map** peut contenir des clés comme **production** et **development** avec leurs valeurs associées. Pour accéder à une valeur spécifique, on utilise la clé entre crochets, comme dans **var.instance_type["development"]**, ce qui permet d’obtenir la valeur associée à la clé **development**.

```
# variables.tf
...
...
variable "servers" {
  default = ["web1", "web2", "web3"]
  desription = "list of web servers"
  type = list(string)
}

variable "prefix" {
  default = [1, 2, 3]
  type = list(number)
}

variable "instance_type" {
  type = map(string)
  default = {
    "production" = "m5.large"
    "development" = "t2.micro"
  }
}

variable "server_count" {
  default = {
    "web" = 3
    "db" = 1
    "agent" = 2
  }
  type = map(number)
}
```

Nous pouvons utiliser des contraintes de type pour garantir que les valeurs de chaque élément d'une variable de type map sont d'un type spécifique.

--- Type **set**, **objects** et **tuples**

|Type|Description|Exemple|
|----|-----------|-------|
`set`|type tableau dont chaque élément est unique|`[10, 12, 15]`
`object`|type objet composé d'attributs dont chacun est d'un type précis|`{ name = "fisher" color = "brown" age = 7 }`
`tuple`|type tableau dont les éléments peuvent être de tout type|`["db1", 1, true, "db2"]`

Un ensemble (**set**) est similaire à une liste (**list**) mais la différence est qu'un ensemble (**set**) ne peut pas contenir d'éléments en double.

La différence entre un tuple (**tuple**) et une liste (**list**) réside dans le fait qu'une liste (**list**) utilise des éléments du même type de variable, tandis qu'un tuple peut utiliser des types différents. Le type de variable à utiliser dans un tuple (**tuple**) est défini entre crochets.

```
# variables.tf
...
...
variable "db" {
  default = ["db1", "db2"]
  type = set(string)
}

variable "count" {
  default = [10, 12, 15]
  type = set(number)
}

variable "animal" {
  type = object({
    name = string
    color = string
    age = number
    food = list(string)
    favorite_pet = bool
  })

  default = {
    name = "fisher"
    color = "brown"
    age = 7
    food = ["fish", "children", "turkey"]
    favorite_pet = true
  }
}

variable "web" {
  type = tuple([string, number, bool])
  default = ["web1", 7, true]
}
```

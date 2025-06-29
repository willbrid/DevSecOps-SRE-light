# Variables de sortie

En plus des variables d'entrée, OpenTofu permet d’utiliser des variables de sortie pour exposer des valeurs issues des ressources.

Par exemple, on peut créer une variable de sortie pour afficher l’adresse IP publique d’une instance EC2. <br>
La syntaxe commence par le mot-clé **output** suivi d’un nom, et inclut un argument **value** avec une expression de référence. Une description (argument **description**) peut aussi être ajoutée.

Ces variables s’affichent automatiquement après l’exécution de **tofu apply**, même en l'absence de modifications.

**Syntaxe :**

```
output "<variable_name>" {
    value = "<variable_value>"
    <arguments>
}
```

**Exemple :**

```
# main.tf

resource "aws_instance" "server" {
  ami = var.ami
  instance_type = var.instance_type
}

output "pub_ip" {
    value = aws_instance.server.public_ip
    description = "print the public IPv4 address"
}
```

```
# variables.tf

variable "ami" {
    default = ""
}

variable "instance_type" {
    default = "m5.large"
}

variable "region" {
    default = "eu-west-2
}
```

Nous pouvons afficher toutes les variables de sortie de la configuration en utilisant la commande :

```
tofu output
```

Si nous souhaitons récupérer la valeur d'une seule variable de sortie, nous pouvons également passer la variable de sortie en argument :

```
tofu output pub_ip
```

Les variables de sortie OpenTofu sont utiles pour afficher rapidement des informations sur les ressources créées. <br>
Elles peuvent aussi être utilisées pour alimenter d'autres outils d’IaC, comme des scripts ou playbooks Ansible, facilitant ainsi la gestion de configuration et les tests.

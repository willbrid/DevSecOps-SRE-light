# Variables et sorties Terraform

### Variables terraform

```
variable "my-var" {
    description = "My Test Variable"
    type        = string
    default     = "hello"
}
```

Nous avons d’abord le mot-clé réservée **variable**. Ensuite, nous avons le nom arbitraire **"my-var"** fourni par l'utilisateur pour la variable et, entre les accolades, nous avons les paramètres de configuration de la variable, tels que la description, le type de variable et sa valeur par défaut au cas où l'utilisateur ne le ferait pas. Tous les paramètres de configuration entre accolades sont facultatifs.

```
variable "my-var" {}
```

Donc, en substance, nous pouvons également déclarer une variable avec quelque chose comme ci-dessus, nous devrons transmettre une valeur à la variable, soit via une variable d'environnement du système d'exploitation, soit via une entrée de ligne de commande. Sinon, nous obtiendrons une erreur lors de l'exécution. 
<br>
Les variables peuvent nous aider à rendre notre code plus polyvalent et réutilisable.
<br>
Pour référencer une variable dans notre code, nous utiliserons la notation suivante.

```
var.my-var
```

Bien que les variables puissent se trouver dans des fichiers de code Terraform pertinents, la meilleure pratique consiste à les rassembler dans un fichier séparé que nous venons de récupérer par défaut. Ce fichier s'appelle **terraform.tfvars**.

```
variable "my-var" {
    description = "My Test Variable"
    type        = string
    default     = "hello"
    validation {
        condition = length(var.my-war) > 4
        error_message = "The string must be more than 4 characters"
    }
}
```

La validation de variable nous permet de définir un critère pour les valeurs autorisées pour une variable. Par exemple, dans cet extrait de code ci-dessus, le bloc de validation vérifie que cette variable ne stockera les valeurs de type chaîne que si le nombre de caractères dans la chaîne est supérieur à 4. Sinon, un message d'erreur sera affiché : **error_message**. Ceci est extrêmement utile car nous ne voulons pas découvrir à mi-chemin que la valeur transmise était illégale et devoir attendre que tout soit annulé. Au lieu de cela, Terraform s'arrêtera avant de déployer quoi que ce soit si la valeur de la variable ne répond pas aux critères de validation.

<br>

Il existe trois types de variables de base pour les variables Terraform : **string**, **number**, **bool**.
<br>
Les types de variables les plus complexes que nous pouvons utiliser avec les variables de type de base sont : **list**, **set**, **map**, **object** et **tuple**.

```
variable "image_id" {
    type        = string
    default     = "hello"
}

variable "availability_zone_names" {
    type        = list(string)
    default     = ["us-west-1a"]
}

variable "docker_ports" {
    type        = list(object({
        internal = number
        external = number
        protocol = string
    }))
    default     = [
        {
            internal = 8300
            external = 8300
            protocol = "tcp"
        }
    ]
}
```

### Sortie terraform

```
output "instance_ip" {
    description = "VM's Private IP"
    value = aws_instance.my-vm.private_ip
}
```

Nous avons donc le mot-clé réservé **output**. Ensuite, l'utilisateur fournit un nom arbitraire **"instance_ip"** pour la sortie, et entre les accolades, nous avons la description de la sortie et une valeur. Le seul champ obligatoire ici est **value**, à laquelle peut être attribuée n'importe quelle valeur ou même des valeurs de référence d'autres ressources et variables Terraform. Les sorties sont affichées sur le shell ou la CLI après une application ou une exécution réussie de la commande **"terraform apply"**. Ces valeurs de sortie peuvent être utilisées pour suivre et afficher des détails pertinents sur nos ressources déployées.
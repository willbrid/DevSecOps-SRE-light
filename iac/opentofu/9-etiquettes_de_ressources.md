# Etiquettes de ressources

Les **étiquettes** de ressources sont des paires clé-valeur utilisées pour organiser, identifier ou classifier des ressources. Elles sont définies avec le mot clé **tags**.

Prenons l'exemple d'une instance AWS, nommée **web** qui contient une balise **Name** dont la valeur inclut l’ID généré par la ressource **random_string** en tant que suffixe.

```
resource "random_string" "server-suffix" {
  length = 5
  upper = false
  special = false
}

resource "aws_instance" "web" {
  ami = "ami-06178cf087598769c"
  instance_type = "m5.large"
  tags = {
    Name = "web.${random_string.server-suffix.id}"
  }
}
```

La paire **Name** et sa valeur représente une **étiquette**.

Si l’on souhaite mettre à jour uniquement la ressource **random_string**, sans toucher à l'instance AWS, on peut utiliser l’option **-target** avec **tofu apply**, en précisant l’adresse de la ressource : **random_string.server-suffix** .

```
tofu apply -target random_string.server-suffix
```

Cela permet de cibler une modification précise, et OpenTofu prévient que seul cet élément sera mis à jour. L'instance AWS reste inchangée.

Cependant, cette pratique est à utiliser rarement et avec prudence, uniquement pour des cas spécifiques (erreur, modification urgente), car elle peut rendre l’état des ressources partiellement mis à jour.

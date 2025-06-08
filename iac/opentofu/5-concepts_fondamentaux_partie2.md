# Concepts fondamentaux [partie2]

- **Plusieurs fournisseurs**

Nous pouvons utiliser plusieurs fournisseurs au sein d'une même configuration **opentofu**. L'utilisation de plusieurs fournisseurs au sein d'un même fichier de configuration permet de provisionner des ressources, même celles appartenant à différentes plateformes au sein d'une même configuration.

Exemple1:

```
# main.tf
resource "local_file" "pet" {
  filename = "/root/pets.txt"
  content = "We have some pets"
  file_permission = "0700"
}
resource "random_pet" "my-pet" {
  prefix = "Mrs"
  separator = "."
  length = "1"
}
```

```
tofu init
```

```
tofu plan
```

```
tofu apply
```

La ressource **random_pet** appartient au fournisseur **Random**, un fournisseur logique. Elle ne crée pas réellement d'infrastructure, mais lorsqu'elle est utilisée, **opentofu** génère et stocke des valeurs aléatoires. <br>
Dans ce cas, un nom aléatoire est généré et stocké en fonction des arguments transmis au bloc de ressources, tels que le nombre de mots que doit contenir le nom, le préfixe à ajouter avant.

Exemple2:

```
# main.tf
resource "random_string" "server-suffix" {
  length = "6"
  upper = false
  special = false
}
resource "aws_instance" "web" {
  ami = "ami-0c2f25c1f66a1ff4d"
  instance_type = "t2.micro"
  tags = {
    Name = "web.${random_string.server-suffix.id}"
  }
}
```

--- La première ressource, appelée **server-suffix**, est de type **random_string** et utilise le fournisseur **Random**. Ainsi elle crée une chaîne aléatoire comportant 6 caractères et n'utilise ni majuscules ni caractères spéciaux. <br>
--- La deuxième ressource, appelée **web**, est de type **aws_instance** avec deux attributs : **ami** et **instance_type**.

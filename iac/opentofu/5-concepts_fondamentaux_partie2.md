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

- **Alias**

Supposons la définition de deux ressources de type **aws_key_pair** dans un fichier **main.tf**. Aussi pour travailler avec le fournisseur **AWS**, nous devons définir un bloc **provider** par exemple dans un fichier **provider.tf**.

```
# main.tf

resource "aws_key_pair" "alpha" {
    key_name = "alpha"
    public_key = "ssh-rsa xxxxxxx"
}
resource "aws_key_pair" "beta" {
    key_name = "beta"
    public_key = "ssh-rsa xxxxxxx"
}
```

```
# provider.tf

provider "aws" {
    region = "us-east-1"
}
```

Nous avons clairement défini la région **us-east-1** dans le bloc fournisseur pour **AWS**, ce qui signifie que si nous tentons de créer les deux ressources maintenant, elles seront toutes deux créées dans la région **us-east-1**. Comment créer la ressource **beta** dans la région **ca-central-1** ?

Nous ajoutons un autre bloc de fournisseur "AWS" dans le fichier **provider.tf** mais cette fois avec la région définie sur **ca-central-1**. Cependant pour identifier ce bloc particulier, nous ajoutons l'argument appelé **alias** et lui donnons une valeur logique telle que **central**.

```
# provider.tf

provider "aws" {
    region = "us-east-1"
}

provider "aws" {
    region = "ca-central-1"
    alias = "central"
}
```

Pour utiliser le bloc **provider** avec la région **ca-central-1** définie pour la ressource **beta**, nous ajoutons l'argument **provider** comme suit :

```
# main.tf

resource "aws_key_pair" "alpha" {
    key_name = "alpha"
    public_key = "ssh-rsa xxxxxxx"
}

resource "aws_key_pair" "beta" {
    key_name = "beta"
    public_key = "ssh-rsa xxxxxxx"
}
provider = aws.central
```

La valeur de l'argument **provider** fait référence au deuxième fournisseur créé pour la région **ca-central-1** et présente la syntaxe suivante : **nom_fournisseur.nom_alias**.

Si nous créons des ressources, la commande **tofu show** indique que la ressource alpha est créée dans la région **us-east-1** et la ressource bêta, quant à elle, est créée dans la région **ca-central-1**, car nous avons utilisé un alias indiquant qu'elle doit être créée spécifiquement dans la région **ca-central**.

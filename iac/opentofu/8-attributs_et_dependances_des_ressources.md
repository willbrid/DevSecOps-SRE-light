# Attributs et dépendances des ressources

Lorsqu’une ressource est provisionnée, OpenTofu enregistre et exporte plusieurs **attributs** liés à celle-ci. On peut consulter ces attributs en exécutant la commande **tofu show**.

```
resource "aws_key_pair" "alpha" {
  key_name = "alpha"
  public_key = "ssh-rsa xxx"
}
```

Dans la sortie de la commande **tofu show**, nous pouvons voir que la ressource **aws_key_pair** appelée **alpha** a exporté plusieurs attributs tels que **arn**, **fingerprint**, **id**, **keyname**, **public_key** et **tags_all**. Et nous pouvons consulter chaque attribut exporté par une ressource dans sa documentation.

Les attributs exportés d'une ressource peuvent être réutilisés comme entrée dans une autre ressource.

```
resource "aws_key_pair" "alpha" {
  key_name = "alpha"
  public_key = "ssh-rsa xxx"
}

resource "aws_instance" "server" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = aws_key_pair.alpha.key_name
}
```

La syntaxe utilisée est : **resource_type.resource_name.attribute**

Lors de l’exécution de **tofu apply**, OpenTofu crée la ressource **alpha** puis l’instance **server**. <br>
Bien qu’il crée les ressources en parallèle par défaut, il respecte les **dépendances implicites** : ici, l’instance **server** dépend de la ressource **alpha**, donc celle-ci est créée en premier. <br>
Lors de la suppression, l’ordre est inverse : l’instance **server** est supprimée avant la ressource **alpha**.

Il existe une autre façon de garantir qu'une ressource spécifique est créée avant une autre dans la configuration. Par exemple, supposons que nous ayons deux types d'instances EC2, l'une pour la base de données et l'autre pour le web. Il n'existe aucune dépendance implicite entre ces deux ressources, aucun attribut de l'une n'étant utilisé par l'autre. <br>
Dans ce cas, si nous souhaitons créer l'instance de base de données avant l'instance web, par exemple, nous pouvons utiliser un méta-argument appelé **depends_on** : il s'agit d'une **dépendance explicite**.

```
resource "aws_instance" "db" {
  ami = var.db_ami
  instance_type = var.db_instance_type
}

resource "aws_instance" "web" {
  ami = var.web_ami
  instance_type = var.web_instance_type
  depends_on = [
    aws_instance.db
  ]
}
```

# Comprendre le code Terraform

### Configuration du fournisseur

```
# Avec AWS
provider "aws" {
    region = "us-east-1"
}
```

```
# Avec Google
provider "google" {
    credentials = file("credentials.json")
    project = "my-gcp-project"
    region = "us-west-1"
}
```

Le mot clé **provider** permet de définir le fournisseur cloud. <br>
La chaine **aws** représente le nom du fournisseur. <br>
Entre les accolades, nous trouvons les paramètres de configuration lié au fournisseur :
- le paramètre **region** permet de préciser la région
- le paramètre **credentials** permet de préciser les paramètres d'authentification au fournisseur. La fonction intégrée de terraform **file** permet de lire le fichier **credentials.json**
- le paramètre **project** permet de préciser le projet défini chez le fournisseur

### Configuration d'une ressource

```
resource "aws_instance" "web" {
    ami = "ami-a1b2c3d4"
    instance_type = "t2.micro"
}
```

- Le mot clé **"resource"** permet de définir un bloc de ressource. 
- La chaine **"aws_instance"** permet de préciser la ressource fournie par le fournisseur aws.
- La chaine **"web"** permet de donner un nom arbitraire à la ressource.
- À l'intérieur des accolades, nous avons les arguments de configuration des ressources, qui adhèrent à la ressource **"aws_instance"**. Ces arguments changeront en fonction de la ressource que nous créeons. <br>
Dans notre cas, nous fournissons le paramètre **ami** ou **image machine Amazon ID** et le paramètre **instance_type**. Enfin, pour accéder à cette ressource dans notre code Terraform, nous utiliserons l'objet **aws_instance.web**. Il y a donc le type de ressource, qui est le **aws_instance**, puis le nom que nous avons donné à la ressource, qui est **web**.

### Source de données

```
data "aws_instance" "my_vm" {
    instance_id = "i-1234567890abcdef0"
}
```

- Le mot clé **data** permet de définir un bloc de source de données. 
- La chaine **"aws_instance"** permet de préciser la ressource fournie par le fournisseur aws.
- La chaine **"my_vm"** permet de donner un nom arbitraire à la ressource.
- Entre les accolades, nous avons l’argument de la source de données (**instance_id**).
- La façon d'accéder à la source de données dans notre code Terraform consiste à utiliser la notation point : **data.aws_instance.my_vm**. Nous pouvons ainsi accéder à tous les attributs attachés à cet objet de source de données dans notre code Terraform.

La principale différence entre un bloc de source de données (**data**) et un bloc de ressources est qu'un bloc de source de données récupère et suit les détails d'une ressource déjà existante, tandis qu'un bloc de ressources (**resource**) crée une ressource à partir de zéro.

### Comportements Terraform par défaut

- Terraform exécute le code dans des fichiers se terminant par l'extension **.tf**.
- Terraform recherche par défaut les fournisseurs dans le registre des fournisseurs Terraform, dont le lien est indiqué ci-après : **https://registry.terraform.io/browse/providers**.
- Les fournisseurs peuvent également provenir de sources locales ou internes et référencés dans notre code Terraform. 
- Nous pouvons même écrire nos propres fournisseurs personnalisés.
# Installation de terraform et des fournisseurs terraform

### Installation de terraform version 1.5 (Ubuntu ou Rocky linux)

- Téléchargement du binaire terraform archivé 64 bits

```
cd ~
```

```
wget -c https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip
```

- Décompression du binaire archivé

```
unzip terraform_1.5.5_linux_amd64.zip
```

- Déplaçons le binaire **terraform** vers le repertoire **/usr/local/bin/**

Ce repertoire doit faire partir des répertoires provenant de la sortie de la commande 

```
echo $PATH
```

```
sudo mv terraform /usr/local/bin/
```

Nous vérifions que l'installation fonctionne en saisissant la commande :

```
terraform -help
```

Lien officiel : [Installation de terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Fournisseurs terraform

- Les **fournisseurs terraform** sont un moyen pour terraform d'abstraire les intégrations avec la couche de contrôle API des fournisseurs d'infrastructure.

- terraform, par défaut, recherche les fournisseurs dans le registre des fournisseurs terraform : https://registry.terraform.io/browse/providers

- Les fournisseurs sont des plugins. Ils sont publiés à un rythme distinct de celui de terraform lui-même et chaque fournisseur possède sa propre série de numéros de version.

- Nous pouvons également écrire nos propres fournisseurs personnalisés.

- terraform recherche et installe les fournisseurs lors de l'initialisation du répertoire de travail avec la commande **terraform init**.

- En tant que bonne pratique, les fournisseurs doivent être rattachés à une version spécifique, afin que toute modification apportée à la version du fournisseur ne perturbe pas notre code terraform. Car si nous ne mentionnons pas de version spécifique, terraform utilisera la dernière version du fournisseur.

- **Exemple concrèt du fonctionnement des fournisseurs terraform** :
Ainsi, nous avons notre repertoire de travail local et à l'intérieur, nous avons écrit du code terraform, et ce code terraform fait référence par exemple au fournisseur AWS situé au niveau du registre public terraform. Ainsi, une fois que le code fait référence au fournisseur AWS, terraform le récupère du registre public pour l'installer en local et, grâce à la logique fournie par le fournisseur, il peut interagir avec le cloud AWS, qui inclut également l'authentification et le déploiement.

```
cd ~
mkdir providers
cd providers
```

```
vi main.tf
```

```
terraform {
  required_providers {
    aws-provider = {
      source  = "hashicorp/aws"
      version = "5.13.1"
    }
    azure-provider = {
      source = "hashicorp/azurerm"
      version = "3.70.0"
    }
  }
}

provider "aws-provider" {
  region = "us-east-1" 
}

provider "azure-provider" {
  feature = {}
}
```

Terraform dispose de journaux détaillés que nous pouvons activer en définissant la variable d'environnement **TF_LOG** sur n'importe quelle valeur. L'activation de ce paramètre entraîne l'affichage de journaux détaillés sur **stderr**.
<br>
Nous pouvons définir **TF_LOG** sur l'un des niveaux de journalisation (par ordre décroissant de verbosité) **TRACE**, **DEBUG**, **INFO**, **WARN** ou **ERROR** pour modifier la verbosité des journaux.

```
export TF_LOG=TRACE
```

```
terraform init
```

Cette commande permettra de télécharger les fournisseurs **aws** et **azure** dans un répertoire **.terraform**.
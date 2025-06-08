# Concepts fondamentaux [partie1]

- **Fournisseurs** (**provider**)

**OpenTofu** utilise des fournisseurs, qui sont des plugins permettant de gérer différentes plateformes comme des services cloud, des API ou des applications SaaS. Pour utiliser **OpenTofu**, il faut spécifier les fournisseurs nécessaires à l'infrastructure, qui sont ensuite téléchargés et configurés automatiquement.

Les fournisseurs permettent à **OpenTofu** de gérer des ressources spécifiques. Chaque fournisseur est indépendant et suit son propre cycle de publication. Le registre public **OpenTofu** centralise ces fournisseurs pour les principales plateformes. Lorsqu'une configuration est modifiée, il peut être nécessaire de réinitialiser le projet pour mettre à jour les fournisseurs installés.

Il existe trois types de fournisseurs : <br>
--- les fournisseurs officiels, détenus et gérés par Hashicorp, incluent les principaux fournisseurs de cloud tels qu'AWS, GCP et Azure. <br>
--- les fournisseurs vérifiés détenus et gérés par une entreprise technologique tierce, mais a été examiné et testé par Hashicorp. <br>
--- les fournisseurs communautaires, publiés et gérés par des contributeurs individuels.

- **Ressources** (**Resources**)

OpenTofu utilise des fichiers de configuration écrits en **HCL**, qui est une abréviation de **Hashicorp configuration language**.

Les ressources sont les composants fondamentaux d'OpenTofu, représentant les éléments d'infrastructure tels que les machines virtuelles, bases de données, stockage ou réseaux. Définies dans des fichiers de configuration (**.tf**), elles permettent d'interagir avec divers services cloud ou API via des fournisseurs. Chaque ressource est déclarée avec un **type**, un **nom unique** et des **paramètres spécifiques**.

Syntaxe
```
resource "<PROVIDER>_<TYPE>" "<NAME>" {
  # Configuration arguments
}
```

Example : local.tf
```
resource "local_file" "pet" {
  filename = "/root/pets.txt"
  content = "We have some pets"
}
```

Le fichier décrit un bloc de ressource défini entre des accolades, identifié par le mot-clé **resource**.
Ce bloc spécifie le type de ressource à créer, ici **local_file**, ce qui indique l’usage du fournisseur **local** et du type **file**.
La ressource est nommée **pet**, un nom logique librement choisi.
À l’intérieur du bloc, on déclare des arguments spécifiques à la ressource, sous forme de paires clé-valeur, comme le nom du fichier et son contenu. Ces arguments varient selon le type de ressource utilisé.

```
resource "aws_instance" "web" {
  ami = "ami-0c2f25c1f66a1ff4d"
  instance_type = "t2.micro"
}
```

```
resource "aws_s3_bucket" "data" {
  bucket = "webserver"
  acl = "private"
}
```

- **Etat** (**state**)

L’état dans **OpenTofu** est un mécanisme permettant de suivre l’infrastructure et ses ressources réelles. Il permet à OpenTofu de savoir quelles ressources existent déjà et d’identifier les modifications à appliquer.

Par défaut, l’état est stocké dans un fichier local (**terraform.tfstate**), mais pour une collaboration plus efficace, il est recommandé d’utiliser un stockage distant (S3, Azure Blob, GCS, etc.) via des backends ou des outils comme TACOS. Cela permet de versionner, sécuriser et partager l’état entre équipes, évitant ainsi les conflits et garantissant une gestion plus fiable de l’infrastructure.

- **Workflow**

Un workflow OpenTofu simple se compose de quatre étapes :

--- Écrire le fichier de configuration

```
mkdir -p $HOME/opentofu/example1 && vim $HOME/opentofu/example1/local.tf
```

```
resource "local_file" "pet" {
  filename = "$HOME/opentofu/example1/pets.txt"
  content = "We have some pets"
}
```

--- La première commande à exécuter est **tofu init**. Elle vérifie tous les fichiers de configuration du répertoire de travail actuel.

```
tofu init
```

Cette commande comprend que nous utilisons le fournisseur **local** et téléchargera le plugin. Si plusieurs ressources appartenant à d'autres fournisseurs sont définies dans les fichiers de configuration, la commande init téléchargera également tous ces plugins.

--- La deuxième commande à exécuter est **tofu plan**. Elle permet de voir un plan de toutes les actions qu'OpenTofu effectuera pour provisionner la ressource.

```
tofu plan
```

Le symbole **Plus** dans la sortie de cette commande indique une action de création ; dans ce cas, la ressource appelée **pet** de type **local_file** sera créée. <br>
Dans la sortie de cette commande, nous pouvons voir également certains arguments par défaut ou facultatifs tels que **file_permission** que nous n'avons pas spécifiquement déclarés dans le fichier de configuration.

Cette étape ne crée pas encore la ressource d'infrastructure. Ces informations sont fournies à l'utilisateur pour qu'il puisse les consulter et s'assurer que toutes les actions à effectuer dans le plan d'exécution sont souhaitées.

- La troisième commande à exécuter est **tofu apply**. Cette commande affichera à nouveau le plan d'exécution, puis demandera à l'utilisateur de confirmer en tapant **yes** pour continuer.

```
tofu apply
```

OpenTofu prend en charge plsuieurs centaines de fournisseurs. Chacun de ces fournisseurs dispose d'une liste unique de ressources pouvant être créées sur cette plateforme spécifique. Chaque ressource peut avoir un certain nombre d'arguments obligatoires et facultatifs nécessaires à sa création.

Nous pouvons utiliser l'option **--auto-approve** pour approuver automatiquement l'exécution de la commande.

```
tofu apply --auto-approve
```

- **Mettre à jour et détruire les infrastructures**

Pour mettre à jour une ressource, il suffit de mettre à jour le fichier de configuration relatif. Puis nous exécutons la commande **tofu plan** suivit de la commande **tofu apply**.

```
vim $HOME/opentofu/example1/local.tf
```

```
resource "local_file" "pet" {
  filename = "$HOME/opentofu/example1/pets.txt"
  content = "We have some pets"
  file_permission = "0700"
}
```

```
tofu plan
```

```
tofu apply
```

Dans la sortie de la commande **tofu plan**, un symbole -/+ devant une ressource indique qu'elle sera supprimée puis recréée. La mention **forces replacement** précise la raison, ici l’ajout de l’argument **file_permission**. **OpenTofu** applique le **principe d’immuabilité**, donc **tofu apply** supprime puis recrée la ressource pour appliquer les changements, en l'occurrence les nouvelles permissions.

Pour supprimer complètement la ressource, nous utilisons la commande **tofu destroy**.

```
tofu destroy
```

Cette commande affiche également le plan d'exécution et nous pouvons constater que la ressource et tous ses arguments sont accompagnés d'un signe **moins**. Cela indique que la ressource sera détruite. <br>
Pour poursuivre la destruction, nous confirmons « **oui** » à l'invite. Une fois la ressource détruite par OpenTofu, nous obtiendrons un message indiquant que la commande a réussi. <br>
Tout comme pour **tofu apply**, nous pouvons également utiliser l'option **--auto-approve** avec la commande **tofu destroy**.

```
tofu destroy --auto-approve
```

- **Déclaration des fichiers de configuration**

Une bonne pratique courante consiste à utiliser un seul fichier de configuration contenant tous les blocs de ressources nécessaires au provisionnement de l'infrastructure. Un seul fichier de configuration peut contenir autant de blocs de configuration que nécessaire. Une convention de nommage courante pour ce type de fichier est de l'appeler **main.tf**. D'autres fichiers de configuration peuvent être créés dans ce répertoire, tels que **variables.tf** et **outputs.tf**.

```
main.tf       :   fichier de configuration principal contenant la définition des ressources
variables.tf  :   fichier de configuration contenant les déclarations des variables
outputs.tf    :   fichier de configuration contenant les sorties des ressources
provider.tf   :   fichier de configuration contenant la définition du fournisseur
opentofu.tf   :   fichier de configuration pour le comportement d'opentofu
```
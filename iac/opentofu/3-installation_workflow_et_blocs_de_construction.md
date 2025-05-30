# Installation, workflow et blocs de construction

### Installation sous Ubuntu 24.04

La méthode la plus simple d'installer **opentofu** est d'utiliser le script d'installation mis à disposition dans la documentation officielle.

- Téléchargement du script

```
curl -fsSL https://get.opentofu.org/install-opentofu.sh -o $HOME/install-opentofu.sh
```

- Accorder des autorisations d'exécution

```
chmod +x $HOME/install-opentofu.sh
```

- Installation en utilisant le script

```
cd $HOME && ./install-opentofu.sh --install-method standalone
```

### Comment fonctionne OpenTofu ?

**OpenTofu** exploite les API pour créer et gérer des ressources sur des plateformes cloud et d'autres services. Grâce aux fournisseurs, **OpenTofu** peut interagir avec pratiquement n'importe quelle plateforme ou service disposant d'une API accessible.

La communauté **OpenTofu** a déjà développé des milliers de fournisseurs pour diverses ressources et services. Tous les fournisseurs accessibles au public, y compris ceux d'Amazon Web Services (AWS), Azure, Google Cloud Platform (GCP), Kubernetes, Helm, GitHub et bien d'autres, sont répertoriés dans le [registre public **OpenTofu**](https://opentofu.org/registry/).

### Workflow OpenTofu

Le workflow principal d'OpenTofu se compose de trois étapes :

- **write** : vous définissez des ressources qui peuvent s'étendre sur plusieurs fournisseurs et services cloud. Par exemple, vous pouvez créer une configuration pour déployer une application sur des machines virtuelles au sein d'un réseau de cloud privé virtuel (VPC), avec des groupes de sécurité et un équilibreur de charge.

- **plan** : Lors de la phase de planification, OpenTofu génère un plan d'exécution détaillant les actions spécifiques d'infrastructure, comme la création, la mise à jour ou la suppression de ressources. Ce plan compare l'état actuel de l'infrastructure à l'état souhaité dans les fichiers de configuration. Cela permet à l'utilisateur de vérifier et de comprendre les modifications avant leur mise en œuvre, réduisant ainsi les risques d'erreurs ou de conséquences imprévues.

- **apply** : Après approbation du plan d'exécution, OpenTofu applique les modifications en suivant un ordre spécifique pour garantir que chaque ressource est prête avant que d'autres ne dépendent d'elle. Il respecte les dépendances entre les ressources, assurant ainsi que les opérations de création, mise à jour ou suppression sont effectuées correctement et dans la séquence appropriée.

De plus, le processus d'application d'**OpenTofu** comprend la surveillance et la gestion de tous les problèmes qui surviennent pendant l'exécution. Si une opération échoue, il peut arrêter le processus pour éviter les échecs en cascade, ce qui vous permet de résoudre le problème avant de continuer. Cette gestion minutieuse des dépendances des ressources et de l'ordre d'exécution permet de maintenir la stabilité et la fiabilité du système tout au long du cycle de vie de l'infrastructure.

### La CLI et le langage OpenTofu

**tofu** est l'outil d'interface de ligne de commande (CLI) officiel conçu pour interagir avec **OpenTofu**. **tofu** permet aux utilisateurs de définir, de provisionner et de gérer les ressources de l'infrastructure cloud de manière cohérente et automatisée.

- **tofu init** : initialiser le répertoire de travail avec les fichiers de configuration
- **tofu plan** : générer et afficher un plan d'exécution des modifications
- **tofu apply** : appliquer les modifications requises pour atteindre l'état souhaité
- **tofu destroy** : détruire toutes les ressources gérées par la configuration
- **tofu fmt** : formater les fichiers de configuration pour la cohérence
- **tofu validate** : valider la syntaxe et l'intégrité des fichiers de configuration
- **tofu state list** : lister toutes les ressources dans l'état actuel
- **tofu state show <ressources>** : afficher des informations détaillées sur une ressource spécifique
- **tofu workspace new <name>** : créer un nouvel espace de travail pour gérer des environnements distincts
- **tofu workspace select <name>** : basculer vers un autre espace de travail
- **tofu import <resource><id>** : importer une ressource existante dans la gestion d'état de **Tofu**

Le **langage OpenTofu** est utilisé pour écrire des fichiers de configuration qui définissent les ressources d'infrastructure et leurs relations. Il permet d'installer des plugins, de créer des ressources comme des serveurs et des réseaux, et d'automatiser leur gestion. Grâce à sa syntaxe déclarative, il simplifie la définition des dépendances entre ressources et permet la création de plusieurs instances similaires avec un seul bloc de code. Ainsi, OpenTofu exécute les configurations comme un manuel d'instructions, garantissant un déploiement cohérent et efficace.

La syntaxe du **langage OpenTofu** se compose de quelques éléments de base :

```
<BLOCK TYPE> "<BLOCK TYPE NAME>" "<BLOCK LABEL>" {
  # Block body
  <IDENTIFIER> = <EXPRESSION> # Argument
}
```

Dans OpenTofu, les blocs sont utilisés pour structurer les fichiers de configuration en regroupant des paramètres liés à une ressource ou une fonctionnalité. Chaque bloc possède un type spécifique, peut inclure des étiquettes pour l'identification et contient des arguments ainsi que des sous-blocs imbriqués.

Les arguments servent à attribuer des valeurs aux paramètres d'une ressource, tandis que les expressions permettent de référencer ou de combiner des valeurs, que ce soit pour les arguments ou pour d'autres expressions.
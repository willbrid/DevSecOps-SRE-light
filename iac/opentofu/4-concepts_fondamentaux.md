# Concepts fondamentaux

- **Fournisseurs** (**provider**)

**OpenTofu** utilise des fournisseurs, qui sont des plugins permettant de gérer différentes plateformes comme des services cloud, des API ou des applications SaaS. Pour utiliser **OpenTofu**, il faut spécifier les fournisseurs nécessaires à l'infrastructure, qui sont ensuite téléchargés et configurés automatiquement.

Les fournisseurs permettent à **OpenTofu** de gérer des ressources spécifiques. Chaque fournisseur est indépendant et suit son propre cycle de publication. Le registre public **OpenTofu** centralise ces fournisseurs pour les principales plateformes. Lorsqu'une configuration est modifiée, il peut être nécessaire de réinitialiser le projet pour mettre à jour les fournisseurs installés.

- **Ressources** (**Resources**)

Les ressources sont les composants fondamentaux d'OpenTofu, représentant les éléments d'infrastructure tels que les machines virtuelles, bases de données, stockage ou réseaux. Définies dans des fichiers de configuration (.tf), elles permettent d'interagir avec divers services cloud ou API via des fournisseurs. Chaque ressource est déclarée avec un type, un nom unique et des paramètres spécifiques.

Syntaxe
```
resource "<PROVIDER>_<TYPE>" "<NAME>" {
  # Configuration arguments
}
```

- **Etat** (**state**)

L’état dans **OpenTofu** est un mécanisme permettant de suivre l’infrastructure et ses ressources réelles. Il permet à OpenTofu de savoir quelles ressources existent déjà et d’identifier les modifications à appliquer.

Par défaut, l’état est stocké dans un fichier local (**terraform.tfstate**), mais pour une collaboration plus efficace, il est recommandé d’utiliser un stockage distant (S3, Azure Blob, GCS, etc.) via des backends ou des outils comme TACOS. Cela permet de versionner, sécuriser et partager l’état entre équipes, évitant ainsi les conflits et garantissant une gestion plus fiable de l’infrastructure.
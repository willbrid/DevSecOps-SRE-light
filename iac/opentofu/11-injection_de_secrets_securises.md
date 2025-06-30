# Injection de secrets sécurisés

- Introduction à l'état Opentofu

Lors de l'exécution de tofu apply, OpenTofu crée un fichier d’état appelé **terraform.tfstate**, situé par défaut dans le répertoire des fichiers de configuration. Une sauvegarde de ce fichier est également créée sous le nom **terraform.tfstate.backup**. <br>

Ce fichier (**terraform.tfstate**) est un document JSON qui contient une représentation complète de l’infrastructure créée. Il inclut des détails comme :

- les identifiants de ressources,
- le fournisseur utilisé,
- les attributs des ressources...

OpenTofu utilise ce fichier comme source de vérité pour comparer l’état réel et le code, notamment lors de l'exécution des commandes : **tofu plan** et **tofu apply**.

Lors de l’exécution de la commande **tofu plan** :

- OpenTofu vérifie l’existence du fichier d’état,
- il actualise son contenu en interrogeant l’état réel des ressources,
- il génère ensuite le plan d’exécution, montrant les différences éventuelles avec le code.

L'exécution de la commande **tofu apply** suit le même principe :

- OpenTofu vérifie l’existence du fichier d’état,
- il actualise d’abord le fichier d’état.
- si aucune différence avec le code n’est détectée, aucune mise à jour n’est appliquée.

Il est possible d’empêcher l’actualisation de l’état en utilisant **--refresh=false**.
Cela évite qu’OpenTofu vérifie l’état réel des ressources, ce qui peut être utile dans de grands environnements pour accélérer certaines actions.

```
tofu plan --refresh=false

tofu apply --refresh=false
```

Cependant, cette option est risquée, car elle peut entraîner des incohérences si les ressources ont été modifiées en dehors d’OpenTofu (ex. : changement manuel). À noter que le fichier d’état reste obligatoire, même si son actualisation peut être temporairement désactivée.

OpenTofu utilise un fichier d’état comme modèle de l’infrastructure réelle. Quel que soit le fournisseur ou la taille de l’infra, ce fichier est toujours généré pour enregistrer l’état des ressources.

Le fichier d’état conserve aussi les dépendances entre ressources. <br>
Par exemple, si une instance web dépend d’une base de données, cette relation est enregistrée, permettant à OpenTofu de :

- créer les ressources dans le bon ordre (DB → Web),
- les supprimer dans l’ordre inverse (Web → DB).

Le fichier d’état contient souvent des données sensibles : mots de passe, clés SSH, variables, etc. Comme il est stocké en texte brut localement, il est accessible à toute personne ayant accès au système de fichiers. Il est donc recommandé de le protéger via un backend distant sécurisé.

Il est interdit de versionner les fichiers d’état (**.tfstate**) dans des outils comme GitHub, GitLab ou Bitbucket.
À la place, on recommande d’utiliser des backends d’état distants (ex. : Amazon S3), tandis que les fichiers de configuration seuls peuvent être stockés dans un dépôt Git.

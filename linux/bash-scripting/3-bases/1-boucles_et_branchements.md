# Boucles et branchements

Dans l'interpréteur de commandes, il existe trois types de boucles (`while`, `until` et `for`) et trois types d'exécution conditionnelle (`if`, `case`, et les opérateurs conditionnels `&&` et `||`, qui signifient respectivement **ET** et **OU**). À l'exception de `for` et `case`, le comportement est déterminé par le statut d'une commande.

### Statut final

On peut tester directement le statut d'une commande à l'aide des mots-clés shell `while`, `until` et `if`, ou des opérateurs de contrôle `&&` et `||`. Le code de sortie est stocké dans le paramètre spécial `$?`.

Si la commande s'est exécutée avec succès (ou si la valeur est `true`), `$?` vaut **zéro**. En cas d'échec, `$?` contient un entier positif compris entre **1** et **255** inclus. Une commande ayant échoué renvoie généralement **1**. Les codes de sortie **0** et non nuls sont respectivement appelés `true` et `false`.

### Tests dans l'expression

Les expressions sont jugées vraies ou fausses par la commande `test` ou par l'un des deux mots réservés non standard du shell : `[[` et `((`. La commande `test` compare les **chaînes de caractères**, les **entiers** et **divers attributs de fichiers** ; `((` teste les **expressions arithmétiques**, et `[[...]]` fait la même chose que `test` avec la possibilité **supplémentaire** de comparer des **expressions régulières**.
# Mots-clés intégrés

Ce contenu explique la différence entre les **commandes intégrées** (built-ins) de Bash et les **mots-clés** (keywords) du shell :
- les **built-ins** s'exécutent dans le shell sans créer de processus ;
- les **mots-clés** sont des éléments reconnus par le **parseur** du shell, qui servent à construire les structures de contrôle et la logique du script.

### 1. Built-ins vs mots-clés

| Aspect | Built-ins | Mots-clés |
||||
| Exécution | Exécutés dans le shell | Interprétés (parsés) par le shell |
| Création de processus | Aucune | Aucune |
| Documentation | `help` ou `man` | Pas de page de manuel dédiée |
| Rôle | Opérations utilitaires | Structures de contrôle et syntaxe |

- **Built-ins** (`echo`, `cd`, `[ ]`) : implémentés dans Bash, avec options et documentation.
- **Mots-clés** (`if`, `for`, `[[ ]]`) : mots spéciaux que l'interpréteur analyse pour diriger l'ordre d'exécution et la logique.

Les deux évitent l'appel à des binaires externes : les built-ins réduisent le coût d'exécution, les mots-clés définissent le flux du script.

> `help if` ou `help [[` fonctionnent aussi : Bash documente ses mots-clés via `help`, même s'ils n'ont pas de page `man` propre.

### 2. Crochets simples vs crochets doubles

- `[ ]` = **built-in**, alias de la commande `test`.
- `[[ ]]` = **mot-clé**, avec des fonctionnalités étendues, analysé directement par Bash.

#### builtin-sample.sh

```bash
#!/bin/bash
if [ 2 -eq 2 ]; then
    echo "two equals two"
fi
```

```bash
$ ./builtin-sample.sh
two equals two
```

#### keyword-sample.sh

```bash
#!/bin/bash
if [[ 2 -eq 2 ]]; then
    echo "two equals two"
fi
```

```bash
$ ./keyword-sample.sh
two equals two
```

Même résultat ici, mais le mécanisme interne est différent.



### 3. `[` vs `test`

`[ ]` n'est rien d'autre que le built-in `test` : les deux noms sont interchangeables (avec `[`, le `]` final est simplement le dernier argument obligatoire).

```bash
$ test 2 -eq 2 && echo "two equals two"
two equals two
```

Documentation :

```bash
$ man test
```

`[[ ]]` n'a **aucun binaire externe** : Bash le traite entièrement comme un mot-clé.

> Il existe aussi des binaires `/usr/bin/test` et `/usr/bin/[` (vérifiable avec `type -a [`), mais Bash utilise le built-in en priorité.

### 4. Évaluation : built-in vs mot-clé

Avec `[ ]`, le shell lit la ligne **avant** de passer les arguments à `test` : `<` est donc pris pour une **redirection**.

```bash
$ [ 1 < 2 ] && echo "1 is less than 2"
-bash: 2: No such file or directory
```

(Bash essaie de lire un fichier nommé `2`.)

Avec `[[ ]]`, Bash analyse lui-même l'expression : `<` devient un **opérateur de comparaison**.

```bash
$ [[ 5 < 7 ]] && echo "5 is less than 7"
5 is less than 7
```

> ⚠️ Attention : dans `[[ ]]`, `<` et `>` comparent des **chaînes** (ordre alphabétique), pas des nombres. Exemple piège : `[[ 10 < 9 ]]` est **vrai** car « 1 » vient avant « 9 ».
> Pour comparer des nombres : `-lt`, `-gt`… ou l'arithmétique `(( 10 < 9 ))`.
> Avec `[ ]`, on peut échapper : `[ "a" \< "b" ]`.



### 5. Fonctionnalités avancées de `[[ ]]`

**Regroupement logique** avec parenthèses et `&&` / `||` :

```bash
$ [[ 3 -eq 3 && (2 -eq 2 && 1 -eq 1) ]] && echo "Parentheses can be used"
Parentheses can be used
```

**Motifs glob** (*pattern matching*) avec `=` ou `==` :

```bash
$ name="Bob Doe"
$ [[ $name = *o* ]] && echo "Patterns can be used"
Patterns can be used
```

**Expressions régulières** avec `=~` :

```bash
$ name="Bob Doe"
$ [[ $name =~ B.*Doe ]] && echo "Regular expressions can be used"
Regular expressions can be used
```

> Le motif à droite **ne doit pas être entre guillemets**, sinon il est comparé comme une chaîne littérale. Les groupes capturés par `=~` sont disponibles dans `${BASH_REMATCH[@]}`.

> ⚠️ `[[ ]]` **n'est pas POSIX** : il n'existe pas dans tous les shells (ex. `sh`/`dash`). À utiliser seulement si le script est destiné à Bash (shebang `#!/bin/bash`).



### 6. Avantages et inconvénients

#### Crochets simples `[ ]`

**Avantages :**
- Portables sur tous les shells POSIX
- Syntaxe conditionnelle standard

**Inconvénients :**
- Limités aux comparaisons de base
- Pas de motifs, pas de regex, pas de regroupement

#### Crochets doubles `[[ ]]`

**Avantages :**
- Conditions étendues (regex, globs, regroupement)
- Comparaisons de chaînes plus sûres (pas de découpage des mots ni d'expansion glob sur les variables)

**Inconvénients :**
- Non conforme POSIX
- Spécifique à Bash (et quelques shells comme zsh/ksh)

> Exemple de « comparaison plus sûre » : si `$var` est vide, `[ $var = "x" ]` provoque une erreur de syntaxe, alors que `[[ $var = "x" ]]` fonctionne. Avec `[ ]`, il faut **toujours** mettre les variables entre guillemets.



### 7. Synthèse

- Les **built-ins** s'exécutent dans Bash sans fork.
- Les **mots-clés** sont des éléments de syntaxe qui contrôlent le flux ou le comportement.
- **Ni l'un ni l'autre** ne lance de processus externe.

Certains mots-clés comme `time` agissent plutôt comme des **directives** que comme des structures de contrôle.



### À retenir

- `[ ]` = built-in = `test` ; `[[ ]]` = mot-clé propre à Bash.
- `type [` → *shell builtin* ; `type [[` → *shell keyword* ; `compgen -k` liste les mots-clés.
- Avec `[ ]`, `<` et `>` sont des **redirections** : utiliser `-lt`, `-gt` ou les échapper (`\<`).
- Avec `[[ ]]`, `<` et `>` comparent des **chaînes** (alphabétique) ; pour les nombres → `-lt`/`-gt` ou `(( ))`.
- `[[ ]]` permet : `&&`, `||`, parenthèses, globs (`= *o*`), regex (`=~`, sans guillemets autour du motif).
- `[[ ]]` est plus sûr avec les variables vides ou contenant des espaces ; avec `[ ]`, toujours `"$var"`.
- Script **portable POSIX** (`#!/bin/sh`) → `[ ]` ; script **Bash** → `[[ ]]` recommandé.
- `help if`, `help [[`, `help test` pour la documentation intégrée.

### Liens utiles

- [Bash Reference Manual (GNU)](https://www.gnu.org/software/bash/manual/)
- [Bash – Conditional Constructs (`[[ ]]`, `if`, `case`…)](https://www.gnu.org/software/bash/manual/html_node/Conditional-Constructs.html)
- [POSIX – Shell Command Language](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)

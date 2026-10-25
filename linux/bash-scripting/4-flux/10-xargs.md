# Xargs

`xargs` est un utilitaire GNU qui **transforme des données reçues sur stdin en arguments** pour une autre commande. Au lieu du schéma classique « lire stdin → écrire stdout », `xargs` **collecte les éléments** et les **ajoute comme paramètres** à une commande, ce qui rend les scripts beaucoup plus flexibles.

### 1. Bases des pipes

La plupart des utilitaires peuvent lire sur **stdin** ou depuis des **fichiers**. Exemple, compter les mots :

```bash
echo "How many words are in this text?" | wc -w
# 7
```

Redirection et pipe sont souvent interchangeables :

```bash
sort file.txt
sort < file.txt

cat file.txt
cat < file.txt
```

Mais certaines commandes (`rm`, `mkdir`, `ls`, `echo`…) **ne lisent pas stdin** : elles attendent des **arguments**. `xargs` sert alors de **« seau »** : il récupère la sortie de la commande précédente, puis lance une autre commande en lui passant ces éléments comme arguments.

> Exemple du problème :
> ```bash
> echo "dir1" | mkdir        # mkdir: missing operand → mkdir ignore stdin
> echo "dir1" | xargs mkdir  # OK → exécute "mkdir dir1"
> ```

### 2. Fonctionnement de xargs

`file.txt` contient :

```text
file
content
to demonstrate
xargs functionality
```

Passé à `echo` via `xargs`, tout se retrouve **sur une seule ligne** :

```bash
cat file.txt | xargs echo
# file content to demonstrate xargs functionality
```

En coulisses, `xargs` :
1. découpe l'entrée sur les **espaces blancs** par défaut (espaces, tabulations, retours à la ligne) ;
2. construit **une seule ligne de commande** en concaténant tous les éléments ;
3. exécute cette commande :

```bash
echo file content to demonstrate xargs functionality
```

> Sans commande précisée, `xargs` utilise **`echo` par défaut** : `cat file.txt | xargs` donne le même résultat.
> Pour voir la commande exécutée avant le résultat : option **`-t`** (*trace*).
> Si la liste est trop longue (limite `ARG_MAX`), `xargs` découpe automatiquement en **plusieurs exécutions**.

### 3. Cas d'usage courants

#### Fournir des arguments à une commande

`rm`, `ls`, `mkdir`, `echo` ou des scripts personnalisés attendent des **arguments positionnels**. `xargs` évite d'écrire une boucle.

Structure : **commande** (rm, ls, echo, mkdir…) + **valeurs** (fournies par xargs).

Ajouter un message avant le contenu de `file.txt` :

```bash
cat file.txt \
  | xargs echo "The contents of file.txt passed by xargs are:"
# The contents of file.txt passed by xargs are: file content to demonstrate xargs functionality
```

Les éléments lus sont ajoutés **à la fin** des arguments déjà présents.

#### Créer plusieurs répertoires

```bash
echo "dir1 dir2 dir3" \
  | xargs mkdir
ls
# dir1  dir2  dir3
```

Commande exécutée : `mkdir dir1 dir2 dir3`.

#### Exemples pratiques

| Usage | Commande |
|||
| Supprimer des fichiers `.log` | `find . -name '*.log' \| xargs rm -f` |
| Créer des répertoires | `echo "a b c" \| xargs mkdir` |
| SSH en parallèle | `cat hosts.txt \| xargs -P4 -I{} ssh {} hostname` |

Explication de la ligne SSH :
- `-I{}` : remplace `{}` par **chaque ligne** lue (une exécution par élément) ;
- `-P4` : lance jusqu'à **4 processus en parallèle**.

> Options utiles (non détaillées dans la leçon) :
> ```bash
> # -n N : N arguments maximum par exécution
> echo "a b c d" | xargs -n 2 echo
> # a b
> # c d
>
> # -I{} : placer l'élément où on veut dans la commande
> ls *.txt | xargs -I{} cp {} /tmp/backup/{}.bak
>
> # -r : ne rien exécuter si l'entrée est vide (GNU)
> find . -name '*.tmp' | xargs -r rm
>
> # -p : demander confirmation avant chaque exécution
> echo "a b" | xargs -p rm
> ```
> Exemple Kubernetes :
> ```bash
> # Supprimer tous les pods en erreur d'un namespace
> kubectl get pods --field-selector=status.phase=Failed -o name | xargs -r kubectl delete
> ```
> Avec SSH dans `xargs`, ajouter `ssh -n` pour éviter que ssh « avale » le reste du stdin destiné à xargs.

### 4. Gestion des caractères spéciaux

Par défaut, `xargs` découpe sur **tous les espaces blancs** : un nom de fichier contenant un espace (`mon fichier.log`) devient **deux arguments** (`mon` et `fichier.log`), ce qui peut provoquer des erreurs… ou supprimer le mauvais fichier.

Solution : des données séparées par le caractère **NUL** avec `-0` :

```bash
find . -name '*.log' -print0 | xargs -0 rm -f
```

- `-print0` (find) : sépare les noms par `\0` au lieu d'un retour à la ligne ;
- `-0` (xargs) : découpe uniquement sur `\0`.

Le caractère NUL ne pouvant **jamais** apparaître dans un nom de fichier, la méthode est sûre pour **tous** les noms.

> Alternatives :
> - `xargs -d '\n'` (GNU) : découper seulement sur les retours à la ligne ;
> - `find . -name '*.log' -delete` ou `find … -exec rm {} +` : sans xargs du tout.

Résumé de la diapositive : `xargs` fonctionne comme un **echo simple**, il **reçoit l'entrée** et la **positionne en arguments**, au service d'**autres commandes**.

### À retenir

- `xargs` convertit **stdin → arguments** pour les commandes qui ne lisent pas stdin (`rm`, `mkdir`, `kubectl delete`…).
- Par défaut : découpe sur les **espaces/retours à la ligne**, ajoute tout **à la fin** de la commande, commande par défaut = `echo`.
- `-n N` = N arguments par exécution ; `-I{}` = une exécution par élément avec `{}` remplacé ; `-P N` = N exécutions en parallèle.
- `-t` affiche la commande exécutée ; `-r` n'exécute rien si l'entrée est vide ; `-p` demande confirmation.
- Noms avec espaces : **`find … -print0 | xargs -0 …`** (ou `-d '\n'`).
- `xargs` gère automatiquement la limite **`ARG_MAX`** en découpant en plusieurs appels.
- Alternatives sans xargs : `find -exec … {} +`, `find -delete`, boucle `while read`.

### Liens utiles

- [GNU findutils – xargs invocation](https://www.gnu.org/software/findutils/manual/html_mono/findutils.html#xargs-invocation)
- [man xargs](https://man7.org/linux/man-pages/man1/xargs.1.html)
- [BashFAQ 082 (Wooledge)](https://mywiki.wooledge.org/BashFAQ/082)
- [Tecmint – exemples pratiques de find](https://www.tecmint.com/15-practical-examples-of-linux-find-command/)

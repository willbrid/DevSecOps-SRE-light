# Variable $-

La variable **`$-`** affiche les **options (flags) actives** du shell courant. Ces options **diffèrent** selon que les commandes sont lancées en **interactif** ou **dans un script**. Par exemple :
- inspecter `$-` en interactif ;
- comparer avec un script (non interactif) ;
- voir l'effet de `set -e` ;
- récapituler les flags courants.

### 1. Afficher `$-` en interactif

Dans un terminal :

```bash
echo $-
```

Exemple de sortie :

```bash
himBHs
```

Chaque lettre (`h`, `i`, `m`, `B`, `H`, `s`) représente une **option du shell**. Elles peuvent varier selon le système et la configuration de l'utilisateur.

> L'ensemble exact dépend de la **version de Bash** et de la configuration (`.bashrc`, `.bash_profile`…).

> Signification de `himBHs` :
>
> | Lettre | Option | Signification |
> |---|---|---|
> | `h` | hashall | Mémorise l'emplacement des commandes déjà trouvées dans le `PATH` |
> | `i` | interactive | Shell **interactif** |
> | `m` | monitor | **Contrôle des jobs** activé (`fg`, `bg`, `jobs`, Ctrl+Z) |
> | `B` | braceexpand | **Expansion d'accolades** activée (`{1..5}`) |
> | `H` | histexpand | Expansion d'**historique** avec `!` (`!!`, `!$`) |
> | `s` | — | Les commandes sont lues depuis **stdin** |

### 2. Comparaison avec un script (non interactif)

`special-dash.sh` :

```bash
#!/usr/bin/env bash
echo $-
```

```bash
chmod +x special-dash.sh
./special-dash.sh
```

Sortie typique :

```bash
hB
```

Le flag **`i`** a disparu : un script s'exécute en mode **non interactif** par défaut. `m` (contrôle des jobs), `H` (historique) et `s` sont aussi absents.

> Application pratique : adapter le comportement selon le mode, par exemple dans `.bashrc` :
> ```bash
> case $- in
>     *i*) echo "Shell interactif" ;;
>       *) echo "Shell non interactif" ;;
> esac
>
> # ou
> [[ $- == *i* ]] || return     # dans .bashrc : ne rien faire si non interactif
> ```

### 3. Activer « exit on error » avec `set -e`

`set -e` fait **quitter Bash immédiatement** dès qu'une commande renvoie un code **non nul** :

```bash
#!/usr/bin/env bash
set -e
echo $-
```

```bash
./special-dash.sh
```

Sortie :

```bash
ehB
```

Le **`e`** indique que l'option **« exit on error »** est active.

> `set -e` peut **compliquer le débogage** si on n'y prend pas garde. Tester soigneusement les scripts, et le combiner avec `set -u` et `set -o pipefail` pour une vérification plus stricte des erreurs.

> Exemple de la forme stricte courante :
> ```bash
> #!/usr/bin/env bash
> set -euo pipefail
> echo $-        # ehuB
> ```
> `pipefail` n'apparaît **pas** dans `$-` (il n'a pas de lettre). Pour le vérifier : `set -o | grep pipefail` ou `echo "$SHELLOPTS"`.

> Tester une option précise dans un script :
> ```bash
> [[ $- == *x* ]] && echo "Mode trace activé"
> ```

### 4. Flags courants de `$-`

| Flag | Description |
|---|---|
| `i` | Shell en mode **interactif** |
| `e` | **Quitter immédiatement** si une commande échoue (`set -e`) |
| `u` | Traiter les variables **non définies** comme une erreur (`set -u`) |
| `x` | **Afficher chaque commande** et ses arguments avant exécution (`set -x`, débogage) |

> Autres flags utiles :
> | Flag | Commande | Description |
> |---|---|---|
> | `C` | `set -C` | **noclobber** : interdit d'écraser un fichier avec `>` |
> | `f` | `set -f` | Désactive le **globbing** (`*` n'est plus développé) |
> | `n` | `set -n` | Lit les commandes **sans les exécuter** (vérification de syntaxe) |
> | `v` | `set -v` | Affiche chaque ligne **telle qu'elle est lue** |
>
> Activer avec `set -X`, désactiver avec `set +X`. Exemple de débogage ciblé :
> ```bash
> set -x      # début de la zone tracée
> cp "$src" "$dst"
> set +x      # fin de la trace
> ```
> Vérifier la syntaxe d'un script sans l'exécuter : `bash -n script.sh`.

### 5. Conclusion

Comprendre et inspecter `$-` permet de mieux **contrôler le comportement du shell**, aussi bien en session interactive que dans les scripts automatisés.

### À retenir

- `$-` = liste des **options actives** du shell, une lettre par option.
- Interactif typique : `himBHs` ; script typique : `hB` → pas de `i`, `m`, `H`.
- Détecter un shell interactif : `[[ $- == *i* ]]` ou `case $- in *i*)`.
- `set -e` ajoute `e`, `set -u` ajoute `u`, `set -x` ajoute `x` ; `set +X` retire l'option.
- `pipefail` n'a pas de lettre → `set -o` ou `$SHELLOPTS`.
- Combinaison stricte recommandée : `set -euo pipefail` (à tester soigneusement).
- Débogage : `set -x` / `set +x` autour d'une zone ; `bash -n` pour la syntaxe.

### Liens utiles

- [GNU Bash – Special Parameters (`$-`)](https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html)
- [GNU Bash – The Set Builtin (liste complète des options)](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
- [GNU Bash – Interactive Shells](https://www.gnu.org/software/bash/manual/html_node/Interactive-Shells.html)
- [GNU Bash – Invoking Bash](https://www.gnu.org/software/bash/manual/html_node/Invoking-Bash.html)
- [Bash Beginners Guide (TLDP)](https://tldp.org/LDP/Bash-Beginners-Guide/html/)

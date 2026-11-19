# Variable $_

La variable spéciale **`$_`** contient le **dernier argument de la commande précédente**. Très pratique en session interactive comme dans les scripts pour éviter de **retaper** des arguments longs ou dynamiques.

### 1. Pourquoi utiliser `$_` ?

- **Gagner du temps** en évitant les saisies répétitives ;
- **Réutiliser** facilement un nom de fichier, un chemin de répertoire ou tout dernier argument ;
- Fonctionne en **shell interactif** **et** dans les **scripts**.

`$_` correspond strictement au **dernier argument** de la commande **précédente**.

> Sans argument, `$_` contient en réalité le **nom de la commande** elle-même (c'est le **dernier mot** de la ligne, après expansion) :
> ```bash
> $ pwd
> /home/user
> $ echo $_
> pwd
> ```

> `$_` contient la valeur **après expansion** : après `ls *.txt`, `$_` vaut le **dernier fichier** trouvé, pas `*.txt`.

### 2. Exemples en shell interactif

#### Lister puis copier un fichier

```bash
$ ls -l file.conf
-rw-r--r-- 1 root root 896 Jun 18 2020 file.conf
$ cp $_ /tmp
```

`$_` vaut `file.conf` : inutile de le retaper.

#### Enchaîner des commandes

```bash
$ ls -l file.conf; echo "Done"
-rw-r--r-- 1 root root 896 Jan 18 2020 file.conf
Done
$ echo $_
Done
```

La dernière commande exécutée étant `echo "Done"`, `$_` contient `Done`.

> Alternatives interactives (non présentes dans la leçon) :
> - **`!$`** (expansion d'historique) : dernier argument de la commande précédente, **affiché** avant exécution ;
> - **`Alt + .`** (ou `Échap` puis `.`) : insère le dernier argument directement dans la ligne en cours ; répéter pour remonter dans l'historique.
>
> `!$` et `Alt+.` ne fonctionnent qu'en **interactif** ; `$_` fonctionne aussi dans les **scripts**.

### 3. Utiliser `$_` dans un script

```bash
#!/usr/bin/env bash

# Créer un nouveau répertoire
mkdir project_build

# Entrer dans ce répertoire grâce à $_
cd $_

# Afficher le chemin courant
pwd
```

`$_` évite de retaper `project_build`.

> Version plus robuste (idiome très courant) :
> ```bash
> mkdir -p "project build" && cd "$_"
> ```
> - **guillemets** autour de `$_` pour les noms avec espaces ;
> - `&&` : on n'entre dans le dossier que si la création a réussi ;
> - `-p` : pas d'erreur si le dossier existe déjà.

### 4. Cas d'usage courants

| Scénario | Dernière commande | Valeur de `$_` |
|---|---|---|
| Copier un fichier | `cp large_archive.tar.gz /backup` | `/backup` |
| Éditer un fichier | `vim /etc/nginx/nginx.conf` | `/etc/nginx/nginx.conf` |
| Déplacer un répertoire | `mv logs_old logs_archive` | `logs_archive` |
| Rechercher dans un fichier | `grep ERROR logfile.log` | `logfile.log` |

> Enchaînement typique : `vim /etc/nginx/nginx.conf` puis `sudo nginx -t && cat $_` … ou `cp config.yaml /etc/app/` puis `ls -l $_`.

### 5. Exemples avancés

```bash
# Supprimer un fichier, puis confirmer la suppression
rm temp_data.csv
echo "Removed" $_

# Dans un pipeline
find . -name '*.log' | xargs gzip
echo "Compressed" $_
```

- Premier cas : `$_` vaut `temp_data.csv` → `Removed temp_data.csv`.

> Dans un **pipeline**, les commandes s'exécutent dans des **sous-shells** : la valeur de `$_` qui en résulte n'est **pas fiable** (elle ne contient pas la liste des fichiers compressés). Éviter `$_` après un pipeline et stocker explicitement les valeurs dont on a besoin.

> Attention aussi : `$_` est modifié par **chaque** commande, y compris un `echo` de débogage ajouté entre deux lignes. Dans un script, dès que la valeur doit servir plusieurs fois, préférer une **variable nommée** :
> ```bash
> build_dir="project_build"
> mkdir -p "$build_dir" && cd "$build_dir"
> ```

### 6. Remarque finale

Avec plusieurs commandes enchaînées par `;` ou `&&`, `$_` reflète toujours le **tout dernier argument** de la **dernière commande exécutée**.

> Avec `&&`, si une commande échoue, les suivantes ne s'exécutent pas : `$_` correspond alors au dernier argument de la commande **qui a réellement été exécutée**.

### À retenir

- `$_` = **dernier argument** (après expansion) de la **commande précédente**.
- Sans argument → `$_` = **nom de la commande** (ex. `pwd`), pas une chaîne vide.
- Idiome classique : `mkdir -p "dossier" && cd "$_"`.
- Autres usages : `ls -l fichier` → `cp $_ /tmp` ; `vim fichier` → `cat $_`.
- Avec `;` / `&&`, `$_` vient de la **dernière commande exécutée**.
- Non fiable après un **pipeline** ; écrasé par **chaque** commande (même un `echo`).
- Toujours **quoter** : `"$_"`.
- En interactif : `!$` ou **`Alt + .`** ; dans un script complexe : préférer une **variable nommée**.

### Liens utiles

- [GNU Bash – Special Parameters (`$_`)](https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html)
- [GNU Bash – History Expansion (`!$`)](https://www.gnu.org/software/bash/manual/html_node/History-Interaction.html)
- [GNU Bash – Commands For History (`yank-last-arg`, Alt+.)](https://www.gnu.org/software/bash/manual/html_node/Commands-For-History.html)
- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)

# Heredocs

Un **heredoc** permet d'inclure du **texte ou des commandes sur plusieurs lignes** directement dans un script Bash, sans enchaîner les `echo` ni éditer manuellement. Très utile pour générer des fichiers de configuration, intégrer des requêtes SQL ou exécuter un lot de commandes via SSH, notamment dans des environnements **non interactifs** où Vim ou Nano ne sont pas disponibles.

Un heredoc envoie **un bloc de texte entier** comme entrée (stdin) à une commande. Le script reste propre et on évite les écrasements accidentels dus à la confusion entre `>` et `>>`.

### 1. Pourquoi préférer un heredoc à plusieurs `echo`

Avec des `echo` successifs, le risque d'erreur augmente avec la taille du script :

```bash
echo "line1" > file.txt   # crée ou écrase file.txt
echo "line2" >> file.txt  # ajoute à file.txt
echo "line3" >> file.txt  # ajoute à file.txt
```

Un `>` à la place d'un `>>` et le fichier est **écrasé**. Le heredoc traite le bloc comme **une seule entrée**, ce qui élimine ce risque.

### 2. Syntaxe de base

On envoie un bloc de texte à une commande (ici `cat`) avec l'opérateur `<<DÉLIMITEUR` :

```bash
cat <<EOF
line1
line2
line3
EOF
```

Sortie :

```text
line1
line2
line3
```

Pour **écrire dans un fichier**, on redirige la sortie de la commande :

```bash
cat > file.txt <<EOF
line1
line2
line3
EOF
```

Conseils :
- Le **délimiteur de fin** doit être **identique** (sensible à la casse), **seul sur sa ligne**, **sans espace avant** (ni après).
- Délimiteurs courants : `EOF`, `EOM`, ou n'importe quel mot personnalisé.

```bash
cat <<CUSTOM
alpha
beta
gamma
CUSTOM
```

> Si le délimiteur de fin est mal tapé, le shell continue d'attendre la suite (invite `>`) jusqu'au bon délimiteur ou un `Ctrl+C`. Dans un script, Bash affiche un avertissement *here-document delimited by end-of-file*.

> **Variantes importantes** :
> ```bash
> name="Bob"
>
> # Délimiteur NON quoté → les variables et $(...) sont interprétées
> cat <<EOF
> Bonjour $name, nous sommes le $(date +%F)
> EOF
> # Bonjour Bob, nous sommes le 2026-10-25
>
> # Délimiteur QUOTÉ → texte pris tel quel (aucune expansion)
> cat <<'EOF'
> Bonjour $name, nous sommes le $(date +%F)
> EOF
> # Bonjour $name, nous sommes le $(date +%F)
>
> # <<- → supprime les TABULATIONS en début de ligne (pas les espaces)
> if true; then
> 	cat <<-EOF
> 	texte indenté avec des tabulations
> 	EOF
> fi
> ```

### 3. Cas d'usage courants

| Usage | Exemple |
|||
| Générer un fichier de configuration | `cat > app.conf <<EOF ... EOF` |
| Intégrer un script SQL | `psql <<SQL ... SQL` |
| Lancer un lot de commandes SSH | `ssh user@host <<EOF ... EOF` |
| Créer un Dockerfile à la volée | `docker build - <<EOF ... EOF` |

> Exemple utile pour Kubernetes (non présent dans la leçon) : appliquer un manifeste sans créer de fichier.
> ```bash
> cat <<EOF | kubectl apply -f -
> apiVersion: v1
> kind: Pod
> metadata:
>   name: nginx
> spec:
>   containers:
>   - name: nginx
>     image: nginx
> EOF
> ```
> (`-f -` = lire le manifeste sur stdin.)

### 4. Avantages des heredocs

- ✅ Une seule instruction pour les opérations simples (*one-liner*)
- ✅ Intégrer de **gros blocs de texte** sans guillemets
- ✅ Gérer des **scripts complexes**

### 5. Exécution de commandes à distance via SSH

On peut exécuter **plusieurs commandes sur un hôte distant** en une fois. D'abord, vérifier le contenu du répertoire distant :

```bash
ssh ubuntu@54.161.198.22 ls
# Exemple de sortie :
# guard_clause  pid  shebang
```

Envoyer ensuite des commandes via un heredoc :

```bash
ssh ubuntu@54.161.198.22 <<EOF
mkdir -p ~/heredocs
echo "Sample content for Heredocs file" > ~/heredocs/heredocsfile.txt
EOF
```

Vérifier le résultat :

```bash
ssh ubuntu@54.161.198.22 <<EOF
ls ~/heredocs
cat ~/heredocs/heredocsfile.txt
EOF
```

Sortie attendue :

```text
heredocsfile.txt
Sample content for Heredocs file
```

> Piège fréquent : avec `<<EOF` (non quoté), les **variables sont développées en local** avant l'envoi. `echo $HOME` afficherait le `$HOME` de **ta** machine, pas celui du serveur. Pour que l'interprétation se fasse **sur l'hôte distant**, utiliser `<<'EOF'` (ou échapper : `\$HOME`).

### 6. Here strings : entrée sur une seule ligne

Pour passer **une seule ligne** de texte à une commande, la **here string** (`<<<`) est plus concise :

```bash
export MESSAGE="Hello from Here String"
cat <<<"$MESSAGE"

# Ou directement :
cat <<<"Hello World"
```

Les **here strings** évitent les problèmes de guillemets et les redirections supplémentaires pour de petites données.

> Exemples pratiques :
> ```bash
> # Remplace "echo ... | cmd" sans créer de pipe (ni de sous-shell)
> wc -w <<< "un deux trois"        # 3
>
> # Découper une chaîne dans des variables
> read -r prenom nom <<< "Will Brid"
> echo "$nom"                       # Brid
> ```
> Avantage par rapport à `echo "…" | read …` : avec le pipe, `read` s'exécute dans un **sous-shell** et les variables sont perdues ; avec `<<<`, elles restent disponibles.

### À retenir

- Heredoc : `commande <<DELIM` … `DELIM` → envoie un bloc multiligne sur le **stdin** de la commande.
- Écrire dans un fichier : `cat > fichier <<EOF` (écrase) ou `cat >> fichier <<EOF` (ajoute).
- Délimiteur de fin : **identique**, **seul sur la ligne**, **sans espace** autour.
- `<<EOF` → variables et `$(…)` **interprétées** ; `<<'EOF'` → texte **brut** ; `<<-EOF` → supprime les **tabulations** de début de ligne.
- Avec SSH, `<<EOF` développe les variables **en local** ; `<<'EOF'` les laisse au serveur distant.
- Cas typiques : fichiers de config, SQL, SSH, Dockerfile, manifestes Kubernetes (`cat <<EOF | kubectl apply -f -`).
- Here string `<<< "texte"` : entrée sur une ligne, sans pipe ni sous-shell (pratique avec `read`).

### Liens utiles

- [GNU Bash – Redirections (Here Documents / Here Strings)](https://www.gnu.org/software/bash/manual/html_node/Redirections.html)
- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [OpenSSH – site officiel](https://www.openssh.com/)
- [Docker – documentation](https://docs.docker.com/)
- [Kubernetes – documentation officielle](https://kubernetes.io/docs/)

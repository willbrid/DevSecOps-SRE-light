# Commande no-op

Ce contenu présente la notion de **dry run** (exécution « à blanc ») et la commande intégrée **no-op `:`** (*no operation*). Un dry run permet de vérifier la **logique** et le **déroulement** d'un script **sans modifier** de fichiers ni de données, idéal pour tester des workflows complexes avant la production.

### 1. Qu'est-ce qu'un dry run ?

Le terme vient des **pompiers** : ils s'entraînent à déployer les lances **sans eau**, d'où « *dry* » (à sec). L'opposé est le *wet run* (intervention réelle).

En informatique, de nombreux outils proposent un mode **dry-run** ou **no-op** pour **prévisualiser** les changements sans risque.

### 2. Options de dry run dans les outils DevOps

| Outil | Exemple | Option |
|---|---|---|
| Ansible | `ansible-playbook -i inventory playbook.yml --check` | `--check` |
| Kubernetes | `kubectl apply -f deployment.yaml --dry-run=client -o yaml` | `--dry-run=client` |
| Puppet | `puppet apply --noop my_manifest.pp` | `--noop` |

> Certains outils distinguent dry run **côté client** et **côté serveur**. Toujours vérifier la documentation officielle.

> Précisions utiles :
> - `kubectl --dry-run=client` : validation **locale** uniquement ; `--dry-run=server` : la requête est **envoyée à l'API server** (validation complète, admission controllers) sans rien persister.
> - `kubectl diff -f deployment.yaml` : montre ce qui **changerait** dans le cluster.
> - Ansible : `--check --diff` affiche aussi les différences de fichiers.
> - Terraform : `terraform plan` joue le même rôle.
>
> Usage très courant en CKA pour **générer un manifeste** sans rien créer :
> ```bash
> kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml
> kubectl run tmp --image=busybox --dry-run=client -o yaml -- sleep 3600 > pod.yaml
> ```

### 3. `:` comme bloc vide (placeholder)

Laisser une branche de `if` ou de boucle **vide** provoque une **erreur de syntaxe** :

```bash
#!/usr/bin/env bash

if [[ "$1" = "start" ]]; then
else
  echo "Invalid command."
fi
```

```console
$ ./script.sh
script.sh: line 3: syntax error near unexpected token `else'
```

Pour respecter la syntaxe de Bash **sans effet de bord**, on insère la commande no-op **`:`** :

```bash
#!/usr/bin/env bash

if [[ "$1" = "start" ]]; then
  :
else
  echo "Invalid command."
fi
```

La commande **no-op** est un **built-in** du shell, sans comportement programmé : elle ne fait **rien** et renvoie toujours **0**. Elle sert de **placeholder** dans les boucles et les `if/else`.

> Précision : en Bash, **`true` est aussi un built-in** (`type true` → *shell builtin*). `:` et `true` sont **équivalents** en pratique ; `:` est simplement la forme historique POSIX la plus courte. `echo ""`, lui, **affiche** une ligne vide : ce n'est pas un no-op.

> Autres usages classiques de `:` :
> ```bash
> # Boucle infinie
> while :; do
>     check_health || break
>     sleep 5
> done
>
> # Assigner une valeur par défaut sans rien exécuter
> : "${PORT:=8080}"
>
> # Vérifier qu'une variable obligatoire est définie
> : "${API_TOKEN:?API_TOKEN doit être défini}"
> ```
> `:` **développe quand même ses arguments** : `: $(rm fichier)` exécute le `rm`, et `: > fichier` **vide** le fichier (redirection). Ce n'est donc pas un moyen de « commenter » du code.

### 4. Erreurs d'interprétation vs erreurs d'exécution

#### Erreurs d'interprétation (parsing)

Elles surviennent **à la lecture** du script, **même si** ce chemin de code n'est jamais exécuté :

```bash
#!/usr/bin/env bash

if [[ "$1" = "start" ]]; then
  # bloc vide → erreur d'interprétation
else
  echo "Invalid command."
fi
```

(Un **commentaire** ne compte pas comme une commande : le bloc reste vide → erreur de syntaxe, quel que soit l'argument.)

#### Erreurs d'exécution (runtime)

Elles n'apparaissent que **lorsque l'exécution atteint** le code fautif. Exemple avec une commande inexistante `x` :

```bash
#!/usr/bin/env bash

if [[ "$1" = "start" ]]; then
  x
else
  echo "Invalid command."
fi
```

Sans argument :

```console
$ ./script2.sh
Invalid command.
```

Avec `start` :

```console
$ ./script2.sh start
./script2.sh: line 4: x: command not found
```

En remplaçant `x` par `:`, plus d'erreur ni de sortie, et le script se termine proprement :

```bash
#!/usr/bin/env bash

if [[ "$1" = "start" ]]; then
  :
else
  echo "Invalid command."
fi
```

```console
$ ./script2.sh start
# aucune sortie, code de sortie 0
```

> Détecter les erreurs de **syntaxe** sans exécuter le script :
> ```bash
> bash -n script.sh      # parse uniquement
> shellcheck script.sh   # analyse statique plus poussée
> ```

---

## 5. Mettre en place un dry run dans ses propres scripts

> Modèle courant :
> ```bash
> #!/usr/bin/env bash
> set -euo pipefail
>
> DRY_RUN="${DRY_RUN:-false}"
>
> run() {
>     if [[ "$DRY_RUN" == "true" ]]; then
>         echo "[DRY-RUN] $*"
>     else
>         "$@"
>     fi
> }
>
> run mkdir -p /opt/app/releases
> run cp app.tar.gz /opt/app/releases/
> run systemctl restart app
> ```
> ```console
> $ DRY_RUN=true ./deploy.sh
> [DRY-RUN] mkdir -p /opt/app/releases
> [DRY-RUN] cp app.tar.gz /opt/app/releases/
> [DRY-RUN] systemctl restart app
> ```
> `"$@"` exécute la commande avec ses arguments intacts ; `$*` sert juste à l'affichage.

### À retenir

- **Dry run** = exécuter « à blanc » pour vérifier la logique sans rien modifier (origine : pompiers sans eau).
- Outils : Ansible `--check`, kubectl `--dry-run=client|server` (+ `-o yaml` pour générer un manifeste), Puppet `--noop`, Terraform `plan`.
- `:` = built-in **no-op** : ne fait rien, renvoie **0** ; sert de **placeholder** dans un bloc vide (`then :`).
- Un bloc vide (ou contenant seulement un commentaire) = **erreur de syntaxe**, détectée au parsing.
- Erreurs d'**interprétation** (toujours, dès la lecture) vs d'**exécution** (seulement si le code est atteint).
- `:` ≈ `true` (les deux sont des built-ins en Bash) ; `echo ""` n'est pas un no-op.
- `:` développe ses arguments : `: "${VAR:=défaut}"`, `: "${VAR:?message}"` ; attention à `: > fichier`.
- `bash -n` / `shellcheck` pour vérifier la syntaxe sans exécuter ; fonction `run()` + `DRY_RUN` pour un dry run maison.

### Liens utiles

- [GNU Bash – Bourne Shell Builtins (`:`, `true`)](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html)
- [Ansible – ansible-playbook `--check`](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html#cmdoption-ansible-playbook-check)
- [Kubernetes – kubectl apply (`--dry-run`)](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply)
- [Puppet – mode noop](https://puppet.com/docs/puppet/latest/applying_catalogs.html#noop)
- [ShellCheck](https://www.shellcheck.net/)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)

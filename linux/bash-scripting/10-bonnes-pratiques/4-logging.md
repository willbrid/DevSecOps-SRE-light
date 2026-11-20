# Logging

Tracer les événements avec des **horodatages ISO 8601** en encapsulant les appels à `date` dans des **fonctions**, pour des logs **cohérents** et **exploitables par des machines**, quel que soit l'environnement.

### 1. Pourquoi horodater les logs ?

Des entrées horodatées permettent de :
- **déboguer** l'enchaînement des événements en temps réel ;
- **auditer** les événements dans des workflows conteneurisés ;
- **reconstituer** une panne à travers des systèmes distribués.

Elles permettent de suivre le **flux** et la **séquence** des événements.

### 2. Démo rapide : horodatage en ligne

`echo` + substitution de commande pour ajouter l'heure **UTC** :

```bash
echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") : Script event happening"
```

Sortie :

```text
2023-05-20T03:51:03Z : Script event happening
```

### 3. Fonction `log` réutilisable

Plutôt que de répéter la logique d'horodatage, on l'**encapsule** :

```bash
#!/usr/bin/env bash
log() {
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") ${*}" >&2
}

log "Hello World!"
```

`./log.sh` :

```text
2023-06-01T05:42:45Z Hello World!
```

- `${*}` regroupe tous les arguments en un seul message ;
- `>&2` envoie le log sur **stderr**.

> Envoyer les logs sur **stderr** les sépare de la **sortie normale** (stdout) et facilite les redirections : `./script.sh > resultat.txt 2> script.log`.
> Dans un conteneur (Docker, Kubernetes), stdout et stderr sont collectés automatiquement (`docker logs`, `kubectl logs`).

> Version enrichie (non présente dans la leçon) avec **niveaux** et nom du script :
> ```bash
> readonly SCRIPT_NAME=${0##*/}
>
> log() {
>     local level="$1"; shift
>     printf '%s [%s] %s: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$level" "$SCRIPT_NAME" "$*" >&2
> }
>
> log INFO  "Démarrage de la sauvegarde"
> log WARN  "Espace disque < 10 %"
> log ERROR "Échec de la copie"
> # 2026-11-20T21:25:00Z [INFO] backup.sh: Démarrage de la sauvegarde
> ```
> Écrire aussi dans un **fichier** : `… | tee -a /var/log/monscript.log >&2`.
> Envoyer au **journal système** (syslog/journald) : `logger -t monscript "message"` puis `journalctl -t monscript`.

### 4. Le format de date ISO 8601

Le format `YYYY-MM-DDThh:mm:ssZ` garantit la **cohérence** quelle que soit la **locale** (pas de « 20/11/2026 » vs « 11/20/2026 »), et se **trie** naturellement par ordre chronologique.

| Spécificateur | Signification |
|---|---|
| `%Y` | Année (4 chiffres) |
| `%m` | Mois (01–12) |
| `%d` | Jour du mois (01–31) |
| `%H` | Heure (00–23) |
| `%M` | Minute (00–59) |
| `%S` | Seconde (00–59) |
| `%Z` | Fuseau horaire (ex. UTC) |

Tester les formats :

```bash
date
date -u +"%Y-%m-%dT%H:%M:%SZ"
# 2023-05-19T15:53:19Z
```

> Précisions :
> - Dans `+"%Y-%m-%dT%H:%M:%SZ"`, le **`Z` final est un caractère littéral** (« Zulu » = UTC), pas le spécificateur `%Z`. Il n'est correct **qu'avec `-u`** : sans `-u`, on afficherait l'heure locale suivie d'un `Z` trompeur.
> - Pour l'heure **locale avec son décalage** : `date +%Y-%m-%dT%H:%M:%S%z` → `2026-11-20T22:25:00+0100`, ou `date -Iseconds` → `2026-11-20T22:25:00+01:00` (GNU).
> - Millisecondes : `date -u +%Y-%m-%dT%H:%M:%S.%3NZ` (GNU).
> - Sans lancer de processus `date` (Bash 4.2+) : `printf '%(%Y-%m-%dT%H:%M:%S)T\n' -1` (avec `TZ=UTC` pour l'UTC) → utile dans les boucles.

> Éviter de **trop journaliser** : des logs trop verbeux noient l'information importante et dégradent les performances.

### 5. Bonnes pratiques

- Écrire des logs **pour des humains** : clairs, concis, exploitables.
- N'inclure que les **données pertinentes** : horodatage, message, contexte.
- Garder un **format cohérent** pour faciliter l'**analyse automatique** (grep, outils de centralisation de logs).
- Privilégier la **qualité** et la **pertinence** plutôt que la quantité.

> Exemples :
> ```bash
> log "Erreur"                                               # ❌ inexploitable
> log ERROR "Connexion à db01:5432 échouée après 3 essais"   # ✅ quoi, où, combien
> ```
> Ne jamais journaliser de **secrets** (mots de passe, tokens) ; attention à `set -x`, qui affiche les commandes avec leurs arguments.

### À retenir

- Horodater chaque log en **ISO 8601 UTC** : `date -u +"%Y-%m-%dT%H:%M:%SZ"` (le `Z` littéral exige `-u`).
- Encapsuler dans une fonction **`log()`** pour un format uniforme et réutilisable.
- Envoyer les logs sur **stderr** (`>&2`) pour séparer logs et résultats.
- Ajouter **niveau** (INFO/WARN/ERROR) et **nom du script** facilite le tri.
- ISO 8601 = indépendant de la locale et **triable** chronologiquement.
- Heure locale avec décalage : `%z` ou `date -Iseconds` ; sans fork : `printf '%(…)T'`.
- Logs **pertinents et concis**, format cohérent, jamais de secrets.
- `tee -a` pour un fichier, `logger` pour syslog/journald.

### Liens utiles

- [GNU coreutils – date invocation](https://www.gnu.org/software/coreutils/manual/html_node/date-invocation.html)
- [ISO 8601 (Wikipédia)](https://en.wikipedia.org/wiki/ISO_8601)
- [GNU Bash – Bash Builtins (`printf %(...)T`)](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html)
- [man logger](https://man7.org/linux/man-pages/man1/logger.1.html)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)

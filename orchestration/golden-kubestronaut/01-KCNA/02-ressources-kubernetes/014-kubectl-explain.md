# Kubectl explain

La commande `kubectl explain` **décrit les champs et la structure** des différentes ressources Kubernetes. Elle est très utile pour comprendre comment construire un fichier YAML sans consulter la documentation en ligne : elle affiche directement la description de chaque champ d'une ressource.

### Principe de fonctionnement

- Les informations sur chaque champ sont récupérées **depuis le serveur au format OpenAPI**.
- Les champs sont identifiés via un **identifiant JSONPath simple** :
  
  ```
  <type>.<fieldName>[.<fieldName>]
  ```
  
  Exemple : `pods.spec.containers` cible le champ `containers`, imbriqué dans `spec`, lui-même dans `pods`.
- Pour obtenir la **liste complète des ressources supportées**, utiliser :

  ```bash
  kubectl api-resources
  ```

### Utilisation

```
kubectl explain TYPE [--recursive=FALSE|TRUE] [--api-version=api-version-group] [--output=plaintext|plaintext-openapiv2]
```

### Exemples essentiels

#### Documenter une ressource et ses champs

```bash
kubectl explain pods
```

#### Afficher TOUS les champs de la ressource (récursif)

```bash
kubectl explain pods --recursive
```

Très pratique pour voir l'**arborescence complète** des champs disponibles d'un coup.

#### Cibler un champ spécifique (notation JSONPath)

```bash
kubectl explain pods.spec.containers
```

Affiche la documentation du seul champ `containers`.

#### Préciser la version d'API

```bash
kubectl explain deployments --api-version=apps/v1
```
Utile car certaines ressources (ex. Deployment) existent sous plusieurs versions d'API.

#### Changer le format de sortie

```bash
kubectl explain deployment --output=plaintext-openapiv2
```

### Les options (flags)

| Option | Valeur par défaut | Description |
|--------|-------------------|-------------|
| `--recursive` | `false` | Si `true`, affiche **récursivement le nom de tous les champs**. Sinon, affiche les champs disponibles avec leur description. |
| `--api-version` | *(vide)* | Utilise la version d'API donnée (`group/version`) de la ressource. |
| `--output` | `plaintext` | Format de rendu du schéma. Valeurs valides : `plaintext`, `plaintext-openapiv2`. |

### À retenir

- `kubectl explain <ressource>` = **documentation intégrée** des champs d'une ressource, directement dans le terminal.
- Notation **JSONPath** (`type.field.field`) pour explorer un champ précis et imbriqué (ex. `pods.spec.containers`).
- **`--recursive`** pour afficher l'arborescence complète de tous les champs.
- **`--api-version`** pour cibler la bonne version d'une ressource (ex. `apps/v1` pour un Deployment).
- Combiner avec **`kubectl api-resources`** pour découvrir toutes les ressources disponibles.
- Outil précieux pour **rédiger et déboguer des fichiers YAML** sans quitter la ligne de commande — utile aussi bien à l'examen qu'en pratique.

# Kubectl Apply Command

Ce contenu détaille le **fonctionnement interne** de la commande `kubectl apply` et explique comment Kubernetes gère les configurations d'objets de manière **déclarative**, notamment l'interaction entre les fichiers locaux et les objets live du cluster.

### Les 3 sources comparées par `kubectl apply`

Lors de l'exécution de `kubectl apply`, Kubernetes considère **trois sources** avant d'appliquer un changement :
1. Le **fichier de configuration local** (l'état désiré que vous déclarez).
2. La **configuration de l'objet live** présent dans le cluster.
3. La **dernière configuration appliquée** (**last applied configuration)**, stockée sur l'objet live sous forme d'**annotation**.

> Si l'objet **n'existe pas**, Kubernetes le **crée** à partir du fichier local. L'objet créé ressemble au fichier fourni, mais inclut des **champs supplémentaires** ajoutés par le cluster (ex. `status`).

### La "Last Applied Configuration"

- Lors d'un `kubectl apply`, le fichier YAML est **converti en JSON** et stocké comme **« dernière configuration appliquée »** dans les métadonnées de l'objet live, sous l'annotation :

  ```
  kubectl.kubernetes.io/last-applied-configuration
  ```

- Lors des applications suivantes, Kubernetes **compare** la config locale mise à jour avec la config live, en s'appuyant sur cette annotation pour calculer les changements.

#### Exemple : mise à jour d'image

Si on modifie l'image de `1.18` à `1.19` dans le fichier local puis qu'on relance `kubectl apply`, la commande compare la nouvelle valeur avec la config live et **met à jour** l'objet en conséquence.

#### Suppression de champs

Si un champ (ex. un **label**) est **retiré** du fichier local, `kubectl apply` le **supprime aussi** de la config live — grâce à la comparaison avec la last applied configuration. C'est cette annotation qui permet de savoir qu'un champ existait auparavant et doit donc être supprimé.

### Stratégie de fusion (merge strategy)

Kubernetes fusionne les changements en analysant la **présence ou l'absence** d'un champ dans les trois sources (local, live, last applied), avec des règles distinctes pour les champs **primitifs** (valeurs simples) et les champs **map** (dictionnaires).

### Différence cruciale avec create et replace

> **Seule** la commande `kubectl apply` **stocke** "la last applied configuration".
Les commandes `kubectl create` et `kubectl replace` **ne conservent PAS** cet historique.
→ Pour un suivi précis des changements, il faut **toujours privilégier l'approche déclarative** avec `kubectl apply`.

| Commande | Approche | Stocke la last-applied-configuration ? |
|----------|----------|:--------------------------------------:|
| `kubectl create` | Impérative | ❌ Non |
| `kubectl replace` | Impérative | ❌ Non |
| `kubectl apply` | **Déclarative** | ✅ **Oui** |

### Appliquer la configuration

```bash
kubectl apply -f nginx.yaml            # un fichier
kubectl apply -f /path/to/config-files # tous les fichiers d'un dossier
```

### À retenir

- `kubectl apply` compare **3 sources** : fichier local, objet live, et annotation `last-applied-configuration`.
- Cette **annotation** est le mécanisme central : elle permet de détecter les ajouts, modifications **et suppressions** de champs.
- L'objet créé contient des champs runtime en plus (ex. `status`) ajoutés par le cluster.
- **Seul `apply`** maintient cet historique → indispensable pour un workflow **déclaratif** robuste et cohérent.
- Ne pas mélanger `apply` avec `create`/`replace` sur un même objet, sous peine d'incohérences dans le suivi.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/

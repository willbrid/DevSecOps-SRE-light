# Pods avec YAML

> Créer un Pod Kubernetes à partir d'un fichier YAML : structure du fichier, création avec kubectl, et vérification du statut.

### Les 4 champs de premier niveau

Kubernetes définit ses objets (Pods, ReplicaSets, Deployments, Services…) via des fichiers YAML qui suivent **toujours** la même structure, avec **4 propriétés obligatoires** :

```yaml
apiVersion:
kind:
metadata:
spec:
```

1. **apiVersion** — version de l'API Kubernetes utilisée. Pour un Pod : **`v1`**. D'autres objets utilisent d'autres versions (ex. `apps/v1` pour un Deployment/ReplicaSet).

2. **kind** — type d'objet créé. Ici : **`Pod`**. (Autres : `ReplicaSet`, `Deployment`, `Service`…)

3. **metadata** — informations sur l'objet (**nom**, **labels**). C'est un **dictionnaire**.
   > L'**indentation** des clés sœurs (comme `name` et `labels`) doit être **au même niveau** → crucial pour un parsing YAML correct.

4. **spec** — configuration spécifique de l'objet. Pour un Pod, on y définit les **containers**. Comme un Pod peut avoir plusieurs conteneurs, **`containers` est un tableau** : le tiret **`-`** marque un élément de liste, et chaque conteneur exige au moins **`name`** et **`image`**.

Fichier complet d'exemple :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
    type: front-end
spec:
  containers:
    - name: nginx-container
      image: nginx
```

### Créer et vérifier le Pod

Créer le Pod à partir du fichier :
```bash
kubectl create -f pod-definition.yaml
```

Lister les Pods et voir leur statut :
```bash
kubectl get pods
# NAME        READY   STATUS    RESTARTS   AGE
# myapp-pod   1/1     Running   0          20s
```

Obtenir des détails complets (métadonnées, nœud assigné, conteneurs, historique d'événements) :
```bash
kubectl describe pod myapp-pod
```

`describe` révèle notamment : le **Node** d'assignation, l'**IP** du Pod, l'état des conteneurs, les **Conditions** (`Initialized`, `Ready`, `PodScheduled`) et la section **Events** (Scheduled → Pulling → Pulled → Created → Started).

> `kubectl describe` est **précieux pour le troubleshooting** : il montre l'état interne du Pod et la chronologie des événements.

### Démonstration

> Démonstration pas à pas : créer un Pod Kubernetes à partir d'un fichier YAML (au lieu de `kubectl run`), pour un contrôle explicite des spécifications.

#### Étape 1 — Créer le fichier YAML

Ouvrir un éditeur (vim, Notepad++…) et créer `pod.yaml` :
```bash
vim pod.yaml
```

Éléments clés à définir :
- **apiVersion** : `v1` pour un Pod.
- **kind** : `Pod` (**sensible à la casse**).
- **metadata** : dictionnaire avec le **nom** et les **labels** (pour le regroupement).
- **spec** : spécifications du Pod, dont la **liste des containers**.

> Respecter l'indentation : **2 espaces par niveau**, **jamais de tabulations** — un mauvais alignement provoque des erreurs.

Exemple complet (Pod mono-conteneur, image `nginx`) :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
    tier: frontend
spec:
  containers:
    - name: nginx
      image: nginx
```

> Pour ajouter un conteneur, insérer un nouveau bloc `- name: … / image: …` dans la liste `containers`.

#### Étape 2 — Sauvegarder et vérifier

Dans vim, sauvegarder et quitter :
```bash
:wq
```

Vérifier le contenu :
```bash
cat pod.yaml
```

#### Étape 3 — Créer le Pod dans le cluster

Avec `kubectl create` **ou** `kubectl apply` :
```bash
kubectl apply -f pod.yaml
# pod/nginx created
```

Vérifier le statut (transition `ContainerCreating` → `Running`) :
```bash
kubectl get pods
# nginx   0/1   ContainerCreating   0   7s
# ... puis :
# nginx   1/1   Running             0   9s
```

#### Étape 4 — Inspecter les détails du Pod

```bash
kubectl describe pod nginx
```

Fournit : les **Conditions** (`Initialized`, `Ready`, `ContainersReady`, `PodScheduled`), les **Volumes**, la **QoS Class**, les **Tolerations** par défaut, le **nœud assigné**, et les **Events** (Scheduled → Pulling → Pulled → Created → Started).

### À retenir

- **4 champs racine obligatoires** dans tout manifeste : **`apiVersion`, `kind`, `metadata`, `spec`** (à mémoriser absolument).
- Pour un **Pod** : `apiVersion: v1` et `kind: Pod`.
- `metadata` et `spec` sont des **dictionnaires** ; `containers` est un **tableau** (chaque item commence par `-`, avec au minimum `name` + `image`).
- **L'indentation en YAML est signifiante** : une erreur d'indentation casse le fichier.
- **Deux commandes de création** à distinguer :
  - `kubectl create -f fichier.yaml` (création),
  - `kubectl apply -f fichier.yaml` (création **ou** mise à jour — approche déclarative, très utilisée).
- **Trio de vérification** : `kubectl get pods` (liste/statut) → `kubectl describe pod <nom>` (détails + Events) pour le débogage.
- Les **Events** dans `describe` racontent le cycle : *Scheduled → Pulling → Pulled → Created → Started*.
- Créer un Pod par **fichier YAML** offre plus de **contrôle et de reproductibilité** que `kubectl run` (bonne pratique).
- **Indentation stricte** : 2 espaces, **jamais de tabs** ; `kind` est **sensible à la casse** (`Pod`, pas `pod`).
- **`create` vs `apply`** : les deux créent le Pod ; **`apply`** est **déclaratif** (crée *ou* met à jour) → à privilégier pour un workflow versionné.
- Cycle de démarrage observable : statut `ContainerCreating` → `Running`, colonne `READY` passant de `0/1` à `1/1`.
- `kubectl describe pod <nom>` = l'outil de **diagnostic** : Conditions, Events et assignation de nœud.
- Détails utiles vus dans `describe` : **QoS Class `BestEffort`** (aucune requests/limits définie) et les **Tolerations par défaut** `not-ready`/`unreachable` valables **300s** (délai avant éviction si le nœud défaille).

### Liens utiles

- Documentation Kubernetes : https://kubernetes.io/docs/
- Qu'est-ce que Kubernetes (bases) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Concept des Pods : https://kubernetes.io/docs/concepts/workloads/pods/
- Comprendre les objets Kubernetes (YAML) : https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/

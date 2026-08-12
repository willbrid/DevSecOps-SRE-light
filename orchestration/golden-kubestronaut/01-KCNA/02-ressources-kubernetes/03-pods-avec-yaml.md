# Pods avec Yaml

Ce contenu explique comment créer un Pod Kubernetes à l'aide d'un **fichier de configuration YAML**. Kubernetes utilise les fichiers YAML pour créer divers objets : **Pods, ReplicaSets, Deployments et Services,...**.

### Les 4 champs obligatoires

Tout fichier de définition Kubernetes suit une structure commune avec **quatre champs de premier niveau** :

| Champ | Rôle |
|-------|------|
| **apiVersion** | Version de l'API Kubernetes utilisée pour créer l'objet. |
| **kind** | Type d'objet à créer. |
| **metadata** | Informations d'identification (nom, labels). |
| **spec** | Configuration détaillée de l'objet. |

#### 1. apiVersion

Spécifie la version de l'API. Pour un **Pod** → `v1`. Pour un **Deployment** → `apps/v1`.

#### 2. kind

Définit le type d'objet. Ici → `Pod`. Autres valeurs courantes : `ReplicaSet`, `Deployment`, `Service`.

#### 3. metadata

Contient les informations d'identification. C'est un **dictionnaire** (pas une chaîne), l'**indentation doit être correcte et cohérente** :
- `name` : identifie le Pod de manière unique.
- `labels` : paires clé-valeur pour catégoriser et gérer les Pods (ex. front-end, back-end, database).

#### 4. spec

Fournit la configuration détaillée. Pour un Pod, on y définit les conteneurs via la clé **`containers`**, qui contient une **liste** de dictionnaires (un par conteneur). Le **tiret `-`** indique un élément de liste.

### Exemple complet de définition d'un Pod

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

### Déployer le Pod (commandes essentielles)

Après avoir créé le fichier (ex. `pod-definition.yml`), déployer avec :

```bash
kubectl create -f pod-definition.yml
```

#### Vérifier le statut

```bash
kubectl get pods
```

```
NAME        READY   STATUS    RESTARTS   AGE
myapp-pod   1/1     Running   0          20s
```

#### Détails complets

```bash
kubectl describe pod myapp-pod
```

Affiche des informations détaillées : heure de création, labels, nœud, IP, état des conteneurs (`State: Running`, `Ready: True`), conditions (`Initialized`, `Ready`, `PodScheduled`) et **Events** (Scheduled → MountVolume → Pulling/Pulled → Created → Started).

### À retenir

- Tout fichier YAML Kubernetes doit inclure les **4 champs** : `apiVersion`, `kind`, `metadata`, `spec`.
- L'**indentation** est cruciale en YAML : `metadata` et `spec` sont des dictionnaires.
- La clé `containers` est une **liste** (chaque conteneur commence par un tiret `-`).
- Les mêmes principes s'appliquent aux autres objets Kubernetes (Deployments, Services, ReplicaSets).
- Utiliser `kubectl create -f <fichier>` pour déployer, puis `kubectl get pods` et `kubectl describe pod` pour vérifier.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/

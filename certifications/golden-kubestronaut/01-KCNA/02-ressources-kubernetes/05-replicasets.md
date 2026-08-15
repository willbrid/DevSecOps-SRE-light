# ReplicaSets

Les **replicas** garantissent la **haute disponibilité** et le **load balancing**. Si une application ne tourne que sur un seul pod et qu'il plante, les utilisateurs perdent l'accès. Un **replication controller** garantit qu'un **nombre désiré de pods** tourne en permanence dans le cluster.

Points clés :
- Même pour un seul pod souhaité, le contrôleur en relance automatiquement un si l'existant échoue.
- Il maintient le nombre voulu (1 ou 100), répartit la charge et peut **planifier de nouveaux pods sur d'autres nœuds** si un nœud manque de ressources.

### Replication Controller vs ReplicaSet

Les deux gèrent les replicas de pods, mais :
- Le **Replication Controller** est l'**ancienne technologie**, progressivement remplacée.
- Le **ReplicaSet** est la version **plus moderne et avancée** (à privilégier).

| Aspect | ReplicationController | ReplicaSet |
|--------|----------------------|------------|
| apiVersion | `v1` | `apps/v1` |
| kind | `ReplicationController` | `ReplicaSet` |
| selector | Non requis | **Obligatoire** (via `matchLabels`) |

### Créer un ReplicationController

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: myapp-rc
  labels:
    app: myapp
    type: front-end
spec:
  replicas: 3
  template:
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

> Dans le `template`, **ne pas inclure** l'`apiVersion` ni le `kind` du pod : seulement ses `metadata`, `labels` et `spec`, indentés comme enfants de `template`.

```bash
kubectl create -f rc-definition.yaml
kubectl get replicationcontroller
kubectl get pods   # les pods sont nommés myapp-rc-xxxx
```

### Créer un ReplicaSet

Différences majeures : `apiVersion: apps/v1` et **selector obligatoire**.

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myapp-replicaset
  labels:
    app: myapp
    type: front-end
spec:
  replicas: 3
  selector:
    matchLabels:
      type: front-end
  template:
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

```bash
kubectl create -f replicaset-definition.yml
kubectl get replicaset
kubectl get pods
```

### Labels et Selectors (concept clé)

- Le **selector** (`matchLabels`) permet au ReplicaSet d'**identifier les pods qu'il doit gérer**.
- Il peut ainsi **adopter des pods existants** portant les bons labels, même s'il ne les a pas créés.
- Le **`template` reste indispensable** pour créer de nouveaux pods en cas de défaillance.
- Les labels/selectors sont un concept **omniprésent dans Kubernetes** pour organiser et gérer les objets.

### Scaling d'un ReplicaSet

Trois méthodes pour passer, par exemple, de 3 à 6 replicas :

1. **Modifier le fichier** (mettre `replicas: 6`) puis :

   ```bash
   kubectl replace -f replicaset-definition.yml
   ```
2. **Commande scale avec fichier** :

   ```bash
   kubectl scale --replicas=6 -f replicaset-definition.yml
   ```
3. **Commande scale avec le nom** :

   ```bash
   kubectl scale --replicas=6 replicaset/myapp-replicaset
   ```

> **Attention** : avec `kubectl scale`, la modification n'est appliquée qu'à l'**état du cluster**. Le fichier de définition d'origine continuera d'afficher l'ancien nombre de replicas tant qu'il n'est pas modifié manuellement.

### Récapitulatif des commandes kubectl

| Action | Commande |
|--------|----------|
| Créer un ReplicaSet | `kubectl create -f replicaset-definition.yml` |
| Lister les ReplicaSets | `kubectl get replicaset` |
| Lister les pods | `kubectl get pods` |
| Supprimer un ReplicaSet | `kubectl delete replicaset myapp-replicaset` |
| Mettre à jour un ReplicaSet | `kubectl replace -f replicaset-definition.yml` |
| Scaler un ReplicaSet | `kubectl scale --replicas=6 -f replicaset-definition.yml` |

### À retenir

- Le ReplicaSet assure **haute disponibilité, load balancing et scalabilité**.
- Privilégier **ReplicaSet** (`apps/v1`) plutôt que ReplicationController (`v1`).
- Le **selector est obligatoire** pour un ReplicaSet ; le `template` sert à recréer les pods défaillants.
- Les **labels et selectors** sont le mécanisme central de gestion des pods.

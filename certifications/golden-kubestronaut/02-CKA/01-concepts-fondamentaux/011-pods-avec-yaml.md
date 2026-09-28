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

### Liens utiles

- Documentation Kubernetes : https://kubernetes.io/docs/
- Qu'est-ce que Kubernetes (bases) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Concept des Pods : https://kubernetes.io/docs/concepts/workloads/pods/
- Comprendre les objets Kubernetes (YAML) : https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/

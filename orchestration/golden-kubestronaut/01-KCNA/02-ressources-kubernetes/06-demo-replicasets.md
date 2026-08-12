# Démo ReplicaSets

Ce contenu montre comment **créer et gérer un ReplicaSet** à partir d'un fichier de définition de Pod existant, afin de maintenir en permanence un nombre constant de Pods identiques.

### Créer le fichier YAML du ReplicaSet

Organisation : un répertoire `pods` pour le fichier `nginx.yaml` et un répertoire `replicatesets` pour le fichier `replicaset.yaml`.

Points de structure :
- **apiVersion** : `apps/v1` — **kind** : `ReplicaSet`.
- **metadata** : nom et labels du ReplicaSet.
- Sous **spec** : le `selector` (labels des pods gérés), le nombre de `replicas` (ex. 3) et le `template` du pod.

> **Point crucial** : les labels du `selector` (`matchLabels`) et ceux du **template du pod** doivent être **exactement identiques** — ce sont les seuls qui affectent le fonctionnement. Le label du ReplicaSet lui-même (dans son `metadata`) **n'est pas utilisé pour le matching**.

### Exemple de définition

```bash
vim replicatesets/replicaset.yaml
```

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myapp-replicaset
  labels:
    app: myapp
spec:
  selector:
    matchLabels:
      env: production
  replicas: 3
  template:
    metadata:
      name: nginx-2
      labels:
        env: production
    spec:
      containers:
        - name: nginx
          image: nginx
```

> Le séparateur `---` permet de définir plusieurs objets dans un même fichier YAML.

### Créer et vérifier

```bash
kubectl create -f replicatesets/replicaset.yaml
kubectl get replicaset
```

```
NAME               DESIRED   CURRENT   READY   AGE
myapp-replicaset   3         3         3       8s
```

Colonnes clés : **DESIRED** (souhaité), **CURRENT** (actuel), **READY** (prêts).

```bash
kubectl get pods
```

Les pods sont nommés `myapp-replicaset-xxxxx`, indiquant leur association au ReplicaSet.

### Test de l'auto-réparation (self-healing) — point essentiel

Le ReplicaSet garantit en continu le nombre défini de Pods. Test :
1. Lister les pods : `kubectl get pods`
2. Supprimer un pod :

   ```bash
   kubectl delete pod myapp-replicaset-8nxxl
   ```

Après quelques secondes, le ReplicaSet **recrée automatiquement** un nouveau pod pour maintenir le nombre désiré. Vérifier les événements :

```bash
kubectl describe replicaset myapp-replicaset
```

### Empêcher les pods excédentaires — point essentiel

Le ReplicaSet garantit qu'**exactement** le nombre spécifié de pods reste actif. Si l'on crée un pod supplémentaire portant un **label correspondant au selector**, le contrôleur le **supprime automatiquement** (marqué immédiatement pour terminaison).

```bash
vim pods/nginx.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    env: production
spec:
  containers:
    - name: nginx-container
      image: nginx
```

```bash
kubectl create -f pods/nginx.yaml
kubectl get pods   # le pod excédentaire est en Terminating
```

### Mettre à jour le nombre de replicas (2 méthodes)

#### Méthode 1 : Éditer la configuration en direct

```bash
kubectl edit replicaset myapp-replicaset
```

Ouvre la config live dans l'éditeur (Vim) ; modifier `spec.replicas` (ex. 3 → 4), sauvegarder. Kubernetes applique immédiatement.

#### Méthode 2 : Commande scale

```bash
kubectl scale replicaset myapp-replicaset --replicas=2
```

Réduit à 2 pods ; les pods excédentaires passent en `Terminating`.

### À retenir

- Le ReplicaSet assure le maintien constant du nombre de pods : **auto-réparation** (recrée les pods supprimés) et **contrôle du surplus** (supprime les pods en trop).
- Le **matching se fait uniquement via les labels** du `selector` et du `template`, pas via le label du ReplicaSet.
- Deux façons de modifier les replicas : `kubectl edit` (config live) ou `kubectl scale`.
- Commandes clés : `kubectl create -f`, `kubectl get replicaset`, `kubectl get pods`, `kubectl delete pod`, `kubectl describe replicaset`, `kubectl edit`, `kubectl scale`.

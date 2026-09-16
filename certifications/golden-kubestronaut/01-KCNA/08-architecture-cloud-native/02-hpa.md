# HPA

Le **Horizontal Pod Autoscaler (HPA)** ajuste **automatiquement le nombre de pods** en cours d'exécution selon l'utilisation actuelle des ressources. Comme son nom l'indique, il scale les pods **horizontalement** : il déploie **plus d'instances** quand la demande augmente et **retire** les pods excédentaires quand elle diminue.

> Le HPA est l'un des nombreux **controllers** de Kubernetes : il fonctionne en ajustant le **replica count d'un Deployment** (scale up quand la demande croît, scale down quand la pression retombe).

### fonctionnement du HPA

Le HPA surveille la consommation de ressources de l'application via des **métriques** collectées par l'application **server-metrics**. Ce serveur suit en continu l'usage des ressources sur les **nœuds et les pods**, fournissant les données pour décider quand scaler.

La configuration du HPA implique typiquement :
- Définir un **Deployment** pour l'application ;
- Définir les **resource limits et requests** dans le Deployment ;
- Créer un **objet HPA** qui cible ce Deployment.

### Example Configuration (exemple)

**Le Deployment** avec des limites CPU définies :
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
```

**Le HPA** ciblant ce Deployment, basé sur l'utilisation CPU :
```yaml
# hpa.yaml
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

**Explication** :
- **`scaleTargetRef`** : indique que le HPA cible le **Deployment** **`myapp`** ;
- L'autoscaler maintient le nombre de replicas **entre 1 et 10** (`minReplicas`/`maxReplicas`) selon l'usage CPU ;
- Il surveille en continu l'**utilisation CPU moyenne** et vise à maintenir un **seuil de 50%** sur l'ensemble des pods.

### Gestion du HPA

Créer le HPA :
```bash
kubectl create -f hpa.yaml
# HorizontalPodAutoscaler Created
```

Voir les détails :
```bash
kubectl get hpa
```

```
NAME        REFERENCE          TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
myapp-hpa   Deployment/myapp   50%/50%    1         10        3          10m
```

**Lecture de la sortie (point utile)** :
- **TARGETS** : utilisation CPU moyenne **actuelle / désirée** (ex. `50%/50%`) ;
- **MINPODS / MAXPODS** : limites min et max de replicas ;
- **REPLICAS** : nombre actuel de pods en cours ;
- **AGE** : durée depuis laquelle le HPA est actif.

Supprimer le HPA :
```bash
kubectl delete hpa myapp-hpa
```

> **Point crucial** : l'application **metrics-server** doit être **correctement configuré et en cours d'exécution**, car le HPA s'appuie sur des **métriques précises** pour ses décisions de scaling.

> Le HPA ajuste **dynamiquement le nombre de pods** selon l'usage des ressources en temps réel, permettant à l'application de gérer des charges variables tout en optimisant l'utilisation des ressources.

### À retenir

- Le **HPA** scale **horizontalement** (nombre de **pods**) un Deployment, en ajustant son **replica count** selon des métriques (CPU/mémoire).
- Il dépend d'un **metrics server** actif pour obtenir les données de consommation.
- Configuration clé du HPA : **`scaleTargetRef`** (Deployment ciblé), **`minReplicas`/`maxReplicas`** (bornes), et **`metrics`** avec un **`averageUtilization`** cible (ex. 50% CPU).
- Le Deployment doit définir des **requests/limits** de ressources pour que le calcul d'utilisation fonctionne.
- Commandes : **`kubectl create -f hpa.yaml`**, **`kubectl get hpa`** (colonnes TARGETS, MIN/MAXPODS, REPLICAS), **`kubectl delete hpa`**.

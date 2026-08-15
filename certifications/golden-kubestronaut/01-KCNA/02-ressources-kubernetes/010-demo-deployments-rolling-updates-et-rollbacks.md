# Démo Deployments Rolling Updates et Rollbacks

Cette démonstration pratique montre comment **mettre à jour** et **effectuer des rollbacks** de déploiements Kubernetes via des fichiers YAML et diverses commandes `kubectl`. Point de départ : un déploiement `myapp-deployment` avec **6 replicas** NGINX.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    tier: frontend
spec:
  selector:
    matchLabels:
      app: myapp
  replicas: 6
  template:
    metadata:
      name: nginx-2
      labels:
        app: myapp
    spec:
      containers:
        - name: nginx
          image: nginx
```

### Créer et suivre le déploiement

```bash
kubectl create -f deployment.yaml
kubectl rollout status deployment.apps/myapp-deployment
```

En vérifiant le statut **immédiatement** après création, on observe la progression : `0 of 6 updated replicas`, `1 of 6`... Kubernetes attend que **les 6 pods** tournent avant de marquer le rollout comme réussi.

### Historique des révisions et l'option `--record`

```bash
kubectl rollout history deployment.apps/myapp-deployment
```

Sans `--record`, la colonne **CHANGE-CAUSE** est vide :

```
REVISION   CHANGE-CAUSE
1          <none>
```

Pour **enregistrer la cause** des changements, utiliser le flag `--record` :

```bash
kubectl create -f deployment.yaml --record
```

La cause est alors mémorisée :

```
REVISION  CHANGE-CAUSE
1         kubectl create --filename=deployment.yaml --record=true
```

### Mettre à jour le déploiement — 3 méthodes

#### 1. `kubectl edit` (édition interactive)

```bash
kubectl edit deployment myapp-deployment --record
```

Ouvre la config live dans l'éditeur ; changer l'image (ex. `nginx` → `nginx:1.18`), sauvegarder. Kubernetes lance un rolling update (remplacement progressif des pods). On note ici les paramètres de stratégie : `type: RollingUpdate`, `maxUnavailable: 25%`.

#### 2. `kubectl set image`

```bash
kubectl set image deployment myapp-deployment nginx=nginx:1.18-perl --record
kubectl rollout status deployment/myapp-deployment
```

Historique après plusieurs mises à jour :

```
REVISION  CHANGE-CAUSE
1         kubectl create --filename=deployment.yaml --record=true
2         kubectl edit deployment myapp-deployment --record=true
3         kubectl set image deployment myapp-deployment nginx=nginx:1.18-perl --record=true
```

### Rollback vers une révision précédente

Si une nouvelle image pose problème :

```bash
kubectl rollout undo deployment/myapp-deployment
kubectl rollout status deployment/myapp-deployment
kubectl describe deployment myapp-deployment
```

Cela revient à la révision stable précédente (ex. de la révision 3 vers la révision 2).

### Simuler un rollout en échec

Pour comprendre la gestion des échecs, éditer le déploiement avec une **image inexistante** :

```bash
kubectl edit deployment myapp-deployment --record
# changer l'image en nginx:1.18-does-not-exist (invalide)
```

Résultat observé :

```bash
kubectl get pods
```

- Les **anciens pods (5) continuent de tourner** avec la config précédente.
- Les nouveaux pods tentant l'image invalide affichent l'erreur **`ErrImagePull`**.
- **L'application reste accessible** grâce aux pods encore fonctionnels — c'est tout l'intérêt du rolling update : un échec de mise à jour n'interrompt pas le service.

### Rollback du déploiement échoué

```bash
kubectl rollout undo deployment/myapp-deployment
kubectl rollout status deployment/myapp-deployment
kubectl get pods   # tous les pods reviennent à la version stable (nginx:1.18)
```

### Récapitulatif des compétences acquises

- Créer un déploiement via YAML.
- Suivre la progression avec `kubectl rollout status`.
- Enregistrer les causes de changement avec `--record`.
- Mettre à jour via `kubectl edit` **ou** `kubectl set image`.
- Simuler un échec de rollout (image invalide → `ErrImagePull`).
- Revenir en arrière avec `kubectl rollout undo`.

### À retenir

- Le flag **`--record`** documente l'historique (colonne CHANGE-CAUSE) — précieux pour la traçabilité.
- En cas d'échec (image invalide), le **rolling update protège la disponibilité** : les anciens pods restent actifs.
- `kubectl rollout undo` permet un **retour rapide** à une révision stable.
- Chaque action de mise à jour crée une **nouvelle révision** consultable via `kubectl rollout history`.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/

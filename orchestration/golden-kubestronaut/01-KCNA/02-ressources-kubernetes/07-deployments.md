# Deployments

Les **Deployments** Kubernetes facilitent le **déploiement d'applications** en production, en assurant des **mises à jour efficaces** et une **haute disponibilité**.

### Pourquoi utiliser un Deployment ?

Lors du déploiement d'une application (ex. serveur web) avec plusieurs instances, le **Deployment** apporte :
- **Rolling updates (mises à jour progressives)** : mise à jour des instances **une par une**, plutôt que toutes simultanément, pour ne pas interrompre les utilisateurs actifs.
- **Rollback (retour arrière)** : annulation rapide des changements si une mise à jour introduit une erreur.
- **Regroupement des changements** : appliquer ensemble plusieurs modifications (version du serveur, scaling, allocation de ressources) plutôt qu'individuellement.
- **Pause/Resume** : suspendre et reprendre les changements.

### La hiérarchie des objets Kubernetes

Le **Deployment** s'appuie sur des concepts fondamentaux, formant une hiérarchie :
- **Pod** : encapsule une instance individuelle de l'application.
- **ReplicaSet** (ou ReplicationController) : gère plusieurs Pods.
- **Deployment** : construction de **niveau supérieur** qui crée un ReplicaSet **et** orchestre les rolling updates, rollbacks et opérations **pause/resume**.

> Deployment → crée un ReplicaSet → qui gère des Pods

### Deployment vs ReplicaSet

La définition d'un Deployment est **quasiment identique** à celle d'un ReplicaSet : la **seule différence majeure est le champ `kind`** (`Deployment` au lieu de `ReplicaSet`).

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
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

### Créer et vérifier un Deployment (commandes essentielles)

Créer :

```bash
kubectl create -f deployment-definition.yml
```

Vérifier :

```bash
kubectl get deployments   # liste les Deployments
kubectl get replicaset    # le ReplicaSet associé (créé automatiquement)
kubectl get pods          # les Pods créés
```

Exemple de sortie de `kubectl get deployments` :

```
NAME                DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
myapp-deployment    3         3         3            3           21s
```

Colonnes clés : **UP-TO-DATE** (instances à jour) et **AVAILABLE** (instances disponibles).

### Voir tous les objets d'un coup

```bash
kubectl get all
```

Affiche le **Deployment** (`deploy/`), son **ReplicaSet** (`rs/`) et ses **Pods** (`po/`) associés — illustrant bien la hiérarchie automatique.

### À retenir

- Le Deployment est l'objet de **plus haut niveau** pour gérer le cycle de vie applicatif.
- Il crée automatiquement un **ReplicaSet**, qui crée les **Pods**.
- Le YAML d'un Deployment est identique à celui d'un ReplicaSet, sauf le `kind: Deployment`.
- Fonctionnalités avancées à venir : **rolling updates, rollbacks, pause/resume**.
- `kubectl get all` permet de visualiser toute la hiérarchie (Deployment → ReplicaSet → Pods).

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/

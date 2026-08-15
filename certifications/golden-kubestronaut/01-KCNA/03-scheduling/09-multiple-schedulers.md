# Multiple Schedulers

Kubernetes permet de déployer **plusieurs schedulers** dans un même cluster : on peut utiliser une **logique de placement personnalisée** pour certaines applications tout en gardant le **scheduler par défaut** pour la majorité des charges.

### Principe

- Le scheduler par défaut distribue les pods uniformément en tenant compte des **taints, tolerations et node affinity**.
- Si une application nécessite un comportement **sur-mesure**, on peut déployer un **scheduler personnalisé** aux côtés du scheduler par défaut.
- **Règle clé** : chaque scheduler doit avoir un **nom unique** (`schedulerName`) pour que Kubernetes puisse les différencier. Le scheduler par défaut s'appelle généralement **`default-scheduler`**.

### Configuration des schedulers

Le scheduler par défaut n'a pas besoin de fichier de config explicite, mais on peut en créer un :

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: default-scheduler
```

Pour un scheduler personnalisé, on change simplement le nom :

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: my-scheduler
```

### Les méthodes de déploiement

Il existe **3 façons** de déployer un scheduler supplémentaire :

#### 1. En tant que service (systemd)

Le même binaire `kube-scheduler` avec un fichier de config unique :

```bash
# my-scheduler-2.service
ExecStart=/usr/local/bin/kube-scheduler \
--config=/etc/kubernetes/config/my-scheduler-2-config.yaml
```

#### 2. En tant que Pod

Manifeste de pod (dans `kube-system`) pointant vers la config du scheduler :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-custom-scheduler
  namespace: kube-system
spec:
  containers:
    - name: kube-scheduler
      image: k8s.gcr.io/kube-scheduler-amd64:v1.11.3
      command:
        - kube-scheduler
        - --address=127.0.0.1
        - --kubeconfig=/etc/kubernetes/scheduler.conf
```

#### 3. En tant que Deployment

Approche moderne (comme kubeadm) : construire une image Docker personnalisée du scheduler, la déployer via un Deployment avec un **ServiceAccount**, des **RBAC** (ClusterRoleBindings) et une **ConfigMap** montée en volume pour la configuration.

### Leader Election (haute disponibilité)

Quand on exécute **plusieurs instances du même scheduler** (ex. sur différents nœuds master), il faut activer le **leader election** pour qu'**une seule instance soit active à la fois** :

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: my-scheduler
  leaderElection:
    leaderElect: true
    resourceNamespace: kube-system
    resourceName: lock-o
```

### Configuration RBAC (déploiement sécurisé)

Pour un scheduler déployé comme Deployment, créer un **ServiceAccount** et le lier aux ClusterRoles nécessaires :
- `system:kube-scheduler`
- `system:volume-scheduler`

via des **ClusterRoleBindings**.

### Utiliser le scheduler personnalisé pour un Pod (point essentiel)

Il suffit d'ajouter le champ **`schedulerName`** dans le manifeste du pod :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
    - name: nginx
      image: nginx
  schedulerName: my-custom-scheduler
```

```bash
kubectl create -f nginx-pod.yaml
```

> Si le scheduler personnalisé est **mal configuré**, le pod reste en état **`Pending`**.

### Vérification et dépannage (troubleshooting)

Vérifier que le scheduler tourne :

```bash
kubectl get pods --namespace=kube-system
```

Inspecter les événements d'un pod :

```bash
kubectl describe pod nginx
kubectl get events -o wide
```

Dans les événements, la colonne **SOURCE** confirme quel scheduler a assigné le pod (ex. `my-custom-scheduler` → `Successfully assigned default/nginx to node01`).

Consulter les logs du scheduler :

```bash
kubectl logs my-custom-scheduler --namespace=kube-system
```

### À retenir

- Plusieurs schedulers peuvent coexister ; chacun a un **`schedulerName` unique**.
- **3 méthodes de déploiement** : service, pod, ou Deployment (avec image custom + RBAC + ConfigMap).
- Un pod choisit son scheduler via le champ **`schedulerName`** dans sa spec.
- **Leader election** indispensable pour la HA quand plusieurs instances tournent.
- Débogage : pod `Pending` = scheduler mal configuré ; vérifier via `describe pod`, `get events` (colonne SOURCE), et `logs`.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Réglage des performances du scheduler : https://kubernetes.io/docs/concepts/scheduling-eviction/scheduler-perf-tuning/

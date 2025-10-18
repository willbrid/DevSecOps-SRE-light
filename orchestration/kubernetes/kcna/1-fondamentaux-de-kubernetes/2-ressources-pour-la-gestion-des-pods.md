# Ressources pour la gestion des pods

- **ReplicaSet** - Garantit qu'un nombre donné d'instances de pods s'exécutent à un moment donné.

- **Deployment** - Mises à jour déclaratives pour les **ReplicaSets** et les **Pods**. Idéal pour la mise à l'échelle des applications sans état. Utiliser la stratégie de déploiement **RollingUpdate** par défaut pour les déploiements sans temps d'arrêt.

- Commande impérative pour créer un Déploiement :

```
kubectl create deploy <name> --image=<image> -- replicas=<replicas> .
```

- **StatefulSet** - Semblable au déploiement, mais pour les applications avec état. Les instances de pods ont une identité persistante. Requis pour créer manuellement un service headless qui est un type de service dans Kubernetes qui ne possède pas de cluster IP et permet d'accéder directement aux pods via leur adresse IP individuelle.

- **DaemonSet** - Exécute dynamiquement une instance de pod sur chaque nœud ou seulement sur certains nœuds.

- **Job** - Exécute une tâche conteneurisée jusqu'à son achèvement. Réessaie automatiquement en cas d'échec.

- **CronJob** - Exécute les tâches à plusieurs reprises par intervalle de temps régulier.

[kubernetes-workloads](https://kubernetes.io/docs/concepts/workloads/controllers/)
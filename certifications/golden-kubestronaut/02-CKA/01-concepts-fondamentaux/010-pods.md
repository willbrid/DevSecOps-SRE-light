# Pods

### Qu'est-ce qu'un Pod ?

Prérequis supposés : application déjà développée, buildée en **images Docker** et hébergée sur un dépôt (ex. Docker Hub) ; cluster Kubernetes opérationnel.

Point fondamental : Kubernetes ne déploie **pas les conteneurs directement**, il les **encapsule dans un objet appelé Pod**.

- Un **Pod** = **une instance unique** d'une application.
- C'est la **plus petite unité déployable** de Kubernetes.

Dans le cas le plus simple : un cluster mono-nœud exécute une instance de l'application dans un conteneur, encapsulé par un Pod.

### Mise à l'échelle (scaling)

> **Règle clé** : mettre à l'échelle dans Kubernetes = **augmenter/diminuer le nombre de Pods**, **PAS** le nombre de conteneurs dans un même Pod.

- Pour absorber plus de charge, on crée **de nouveaux Pods** (chacun une instance isolée).
- Kubernetes **répartit** les Pods sur les nœuds disponibles.
- Si la demande dépasse la capacité, on peut ajouter des Pods **sur d'autres nœuds** (extension du cluster).

### Pods multi-conteneurs

Généralement, **un Pod héberge un seul conteneur** (l'application principale). Mais un Pod **peut contenir plusieurs conteneurs**, en principe **complémentaires** (et non redondants) — par exemple un conteneur **helper** pour le traitement de données ou l'upload de fichiers.

Les conteneurs d'un même Pod **partagent** :
- le **même network namespace** → communication directe via **localhost**,
- les **volumes de stockage**,
- les **événements de cycle de vie** → ils démarrent et s'arrêtent **ensemble**.

**Pourquoi le Pod simplifie tout** : en Docker « brut », gérer plusieurs instances + un helper impose de gérer manuellement les `--link`, réseaux personnalisés et volumes partagés :
```bash
docker run helper --link app1
docker run helper --link app2   # ... complexe et fastidieux
```

Avec un Pod multi-conteneurs, ce partage (réseau, stockage, cycle de vie) est **automatique**.

> Même avec un seul conteneur par Pod, Kubernetes **impose l'abstraction Pod** → prépare l'application au **scaling** et aux évolutions futures. Les Pods multi-conteneurs restent **moins courants**.

### Déployer des Pods

Créer un Pod avec `kubectl run` :
```bash
kubectl run nginx --image nginx
```

Vérifier l'état :
```bash
kubectl get pods
# NAME                   READY   STATUS              RESTARTS   AGE
# nginx-8586cf59-whssr   1/1     Running   0          8s
```

États successifs typiques : **`ContainerCreating` → `Running`**.

> À ce stade, l'accès **externe** au serveur nginx n'est **pas** configuré : il n'est accessible **qu'à l'intérieur du nœud**. L'exposition passera par les **Services** (leçon ultérieure).

### À retenir

- **Pod = plus petite unité déployable** de Kubernetes ; il **encapsule** un ou plusieurs conteneurs (on ne déploie jamais un conteneur « nu »).
- **Scaling = nombre de Pods**, jamais le nombre de conteneurs dans un Pod.
- **1 conteneur/Pod** = cas standard ; **multi-conteneurs** = pour des rôles **complémentaires** (helper/sidecar).
- Les conteneurs d'un Pod **partagent** : **réseau (localhost)**, **volumes**, **cycle de vie** (démarrage/arrêt communs).
- Déploiement rapide : `kubectl run <nom> --image <image>` ; suivi : `kubectl get pods`.
- États à reconnaître : `ContainerCreating`, `Running`.
- Un Pod fraîchement créé **n'est pas exposé** à l'extérieur → nécessite un **Service**.

### Liens utiles

- Docker Hub : https://hub.docker.com/
- Concept des Pods (doc Kubernetes) : https://kubernetes.io/docs/concepts/workloads/pods/
- Référence `kubectl run` : https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run

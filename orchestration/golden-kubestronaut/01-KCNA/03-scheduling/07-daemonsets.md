# DaemonSets

Un **DaemonSet** garantit qu'**exactement une instance d'un Pod tourne sur chaque nœud** du cluster. Quand des nœuds sont ajoutés ou retirés, le DaemonSet **ajoute ou supprime automatiquement** le Pod correspondant.

### DaemonSet vs ReplicaSet (distinction clé)

| Objet | Garantie |
|-------|----------|
| **ReplicaSet** | Un **nombre défini** de replicas répartis dans le cluster |
| **DaemonSet** | **Une copie du Pod sur CHAQUE nœud** |

### Cas d'usage

Les DaemonSets sont idéaux pour les services devant être présents **partout** :
- **Monitoring et logging** : agents de surveillance et collecteurs de logs sur tous les nœuds.
- **Networking** : agent d'une solution réseau sur chaque nœud (ex. **weave-net**, composants VNet).
- **Composants d'infrastructure critiques** : ex. **kube-proxy**, qui doit résider sur chaque nœud.

### Créer un DaemonSet

La création est **quasi identique à celle d'un ReplicaSet** : mêmes sections `apiVersion`, `kind`, `metadata`, `spec`. La **seule différence majeure** est `kind: DaemonSet` (et l'absence de champ `replicas`, puisqu'il gère un Pod par nœud).

```yaml
# daemon-set-definition.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitoring-daemon
spec:
  selector:
    matchLabels:
      app: monitoring-agent
  template:
    metadata:
      labels:
        app: monitoring-agent
    spec:
      containers:
      - name: monitoring-agent
        image: monitoring-agent
```

> Les labels du **`selector`** doivent **correspondre** à ceux du **template du Pod**.

Créer et vérifier :

```bash
kubectl apply -f daemon-set-definition.yaml
kubectl get daemonsets
```

```
NAME                DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   AGE
monitoring-daemon   1         1         1       1            1           41s
```

### Fonctionnement interne

- Le DaemonSet planifie automatiquement un Pod sur chaque nœud.
- **Avant la version 1.12** : il utilisait le champ **`nodeName`** pour assigner directement les Pods aux nœuds, **contournant le scheduler**.
- **Depuis la version 1.12** : il s'appuie sur le **scheduler par défaut** et les règles de **node affinity** pour gérer le placement des Pods.

### À retenir

- Un DaemonSet = **un Pod par nœud**, ajusté automatiquement quand le cluster grandit ou rétrécit.
- Usages typiques : **monitoring, logging, networking** (kube-proxy, weave-net…).
- YAML **identique à un ReplicaSet** sauf `kind: DaemonSet` (pas de `replicas`).
- Les labels **selector ↔ template** doivent correspondre.
- Depuis la **1.12**, le placement passe par le **scheduler + node affinity** (avant : via `nodeName`).

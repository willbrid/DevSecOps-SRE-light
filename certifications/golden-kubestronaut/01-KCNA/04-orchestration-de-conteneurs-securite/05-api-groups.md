# API Groups

Ce contenu permet de omprendre l'organisation des **groupes d'API** de Kubernetes, colonne vertébrale de toutes les interactions avec le cluster. Que l'on utilise `kubectl` ou l'API REST directement, chaque opération communique avec le **kube-apiserver**.

### Exemples d'accès à l'API

Vérifier la version du cluster (port par défaut **6443**) :

```bash
curl -k https://kube-master:6443/version
```

Lister les pods :

```bash
curl -k https://kube-master:6443/api/v1/pods
```

### Les endpoints de l'API

Kubernetes organise son API en plusieurs groupes selon la fonctionnalité :
- **`/version`** : version du cluster ;
- **`/metrics`** et **`/healthz`** : surveillance de la santé du cluster ;
- **`/logs`** : intégration avec des systèmes de logging tiers ;
- **`/api`** et **`/apis`** : fonctionnalités cœur du cluster.

### Les deux grandes catégories d'API

#### 1. Core API Group (`/api`)

Contient les ressources **fondamentales** :
- **Namespaces**, **Pods**, **Replication Controllers**, **Events**, **Endpoints** ;
- **Nodes**, **Bindings**, **Persistent Volumes (PV)**, **Persistent Volume Claims (PVC)** ;
- **Config Maps**, **Secrets**, **Services**.

→ Ces APIs cœur font partie du groupe **`v1`**.

#### 2. Named API Groups (`/apis`)

Organisent les fonctionnalités **plus récentes**, par catégorie :
- **apps** → **Deployments**, **ReplicaSets**, **StatefulSets** ;
- **extensions** ;
- **networking** (networking.k8s.io) → Network Policies ;
- **storage** ;
- **authentication**, **authorization** ;
- **certificates** (certificate signing requests), etc.

### Les verbes (verbs)

Chaque ressource supporte un ensemble d'**opérations (verbs)** : **list, get, create, delete, update, watch**.

### Explorer les API groups depuis le cluster

Lister tous les chemins disponibles (sans path) :

```bash
curl -k https://localhost:6443
# → /api, /api/v1, /apis, /healthz, /logs, /metrics, /openapi/v2...
```

Filtrer les named API groups :

```bash
curl -k https://kube-master:6443/apis | grep "name"
# → apps, batch, networking.k8s.io, rbac.authorization.k8s.io,
#   storage.k8s.io, scheduling.k8s.io, certificates.k8s.io...
```

### Authentification requise

> Sans authentification, l'accès direct par curl renvoie une **erreur 403 Forbidden** :

```json
"message": "Forbidden: User \"system:anonymous\" cannot get path \"/\"",
"code": 403
```

Deux solutions :
1. **Passer les certificats** en ligne de commande (`--key`, `--cert`, `--cacert`) ;
2. Utiliser le **`kubectl proxy`**.

```
curl -k --cert client.crt --key client.key https://kube-master:6443/apis | grep "name"
```

**client.crt** et **client.key** sont issus du kubeconfig par décode base64 de **client-certificate** et **client-key**.

### Le kubectl proxy (astuce pratique)

La commande **`kubectl proxy`** lance un proxy HTTP local sur le **port 8001**, qui utilise **automatiquement** les identifiants et certificats du **kubeconfig** — évitant de spécifier l'authentification manuellement.

```bash
kubectl proxy
# Starting to serve on 127.0.0.1:8001
curl http://localhost:8001
```

### kube-proxy ≠ kubectl proxy (distinction clé)

| Composant | Rôle |
|-----------|------|
| **kube-proxy** | Assure la **communication réseau** entre pods et services à travers les nœuds du cluster. |
| **kubectl proxy** | Proxy **HTTP** qui transmet vos requêtes à l'API server via les identifiants du **kubeconfig**. |

→ Ce sont **deux composants distincts** à ne pas confondre.

### À retenir

- Toutes les opérations passent par le **kube-apiserver** (port **6443**).
- **2 catégories** : **Core API Group** (`/api/v1` : pods, services, nodes, namespaces, secrets…) et **Named API Groups** (`/apis` : apps, networking, storage, rbac…).
- Chaque ressource supporte des **verbs** : list, get, create, delete, update, watch.
- Accès direct sans auth = **403 Forbidden** (`system:anonymous`).
- **`kubectl proxy`** (port 8001) simplifie l'accès en utilisant le kubeconfig.
- Ne pas confondre **kube-proxy** (réseau pods/services) et **kubectl proxy** (proxy HTTP vers l'API).

### Liens utiles

- Référence de l'API Kubernetes : https://kubernetes.io/docs/reference/

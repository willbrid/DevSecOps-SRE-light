# Service Accounts

Ce contenu explore les **service accounts** Kubernetes : leur rôle dans la sécurité, leur gestion et la gestion des tokens.

### Deux types de comptes (point essentiel)

| Type | Pour qui ? | Exemples |
|------|-----------|----------|
| **User Account** | **Humains** | Administrateurs, développeurs |
| **Service Account** | **Machines** (machine-à-machine) | Prometheus (monitoring), Jenkins (build), applications |

### Créer et inspecter un Service Account

```bash
kubectl create serviceaccount dashboard-sa
kubectl get serviceaccounts
kubectl describe serviceaccount dashboard-sa
```

Le token (avant 1.24) est automatiquement créé et stocké dans un objet **Secret**. Il sert de **bearer token** pour l'authentification :

```bash
curl https://192.168.56.70:6443/api --insecure --header "Authorization: Bearer eyJhbG..."
```

### Montage automatique du token dans les Pods

- Chaque **namespace** possède un **service account `default`**, utilisé automatiquement si aucun autre n'est spécifié.
- Le token est **monté automatiquement** dans le pod comme un **volume**, à l'emplacement :

  ```
  /var/run/secrets/kubernetes.io/serviceaccount
  ```

- Ce dossier contient 3 fichiers : **`ca.crt`**, **`namespace`**, **`token`**.

Vérifier depuis l'intérieur du pod :

```bash
kubectl exec -it my-kubernetes-dashboard -- ls /var/run/secrets/kubernetes.io/serviceaccount
# ca.crt  namespace  token
```

### Utiliser un Service Account personnalisé

Ajouter le champ **`serviceAccountName`** dans la spec du pod :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-kubernetes-dashboard
spec:
  containers:
    - name: my-kubernetes-dashboard
      image: my-kubernetes-dashboard
  serviceAccountName: dashboard-sa
```

> **On ne peut pas changer le service account d'un pod existant** → il faut le **supprimer et le recréer**. Dans un Deployment, modifier la définition déclenche un **nouveau rollout**.

### Désactiver le montage automatique du token

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-kubernetes-dashboard
spec:
  containers:
    - name: my-kubernetes-dashboard
      image: my-kubernetes-dashboard
  automountServiceAccountToken: false
```

### Évolution de la gestion des tokens (point crucial)

#### Avant Kubernetes 1.22

- Chaque service account était associé à un **Secret contenant un token qui n'expirait JAMAIS** (non-expiring).
- Ces tokens statiques posaient des problèmes de **sécurité et de scalabilité**.

#### Kubernetes 1.22 – Token Request API (KEP 1205)

- Introduction de la **Token Request API** générant des tokens plus sûrs :
  - **audience bound** (liés à un public) ;
  - **time bound** (limités dans le temps / expiration) ;
  - **object bound** (liés à un objet).
- Le token est monté dans un pod comme **projected volume** (avec `expirationSeconds`).

#### Kubernetes 1.24 – Réduction des tokens basés sur Secret (KEP 2799)

- Un service account **ne crée plus automatiquement** de Secret avec token non-expirant.
- Pour générer un token (avec **expiration**, ~1 heure) :

  ```bash
  kubectl create serviceaccount dashboard-sa

  kubectl create token dashboard-sa
  ```
- Le token peut être décodé (JWT) via `jwt.io` ou avec `jq`.

```
jq -R 'split(".") | select(length > 0) | .[0],.[1] | @base64d | fromjson' <<< <token>
```

**Si besoin d'un token non-expirant** (déconseillé), créer manuellement un Secret :

```yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: mysecretname
  annotations:
    kubernetes.io/service-account.name: dashboard-sa
```

> Le service account (`dashboard-sa`) doit **exister** avant la création du Secret.

### À retenir

- **User account** (humains) vs **Service account** (machines/applications).
- Chaque namespace a un service account **`default`** monté automatiquement dans les pods sous `/var/run/secrets/kubernetes.io/serviceaccount` (fichiers : `ca.crt`, `namespace`, `token`).
- **`serviceAccountName`** dans la spec du pod pour utiliser un SA personnalisé ; **impossible de le changer sur un pod existant** (recréer).
- **`automountServiceAccountToken: false`** désactive le montage auto.
- **Évolution des tokens** : avant 1.22 = tokens **non-expirants** (peu sûrs) → **1.22** Token Request API (audience/time/object bound) → **1.24** plus de Secret auto, `kubectl create token` (avec expiration).
- Éviter les **tokens non-expirants** ; privilégier la **Token Request API**.

### Liens utiles

- Décodeur de token JWT : https://jwt.io/

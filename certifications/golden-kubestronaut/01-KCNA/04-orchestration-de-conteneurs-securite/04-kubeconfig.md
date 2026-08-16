# KubeConfig

Le fichier **kubeconfig** simplifie l'**authentification** et la **gestion des contextes** lors des interactions avec les clusters Kubernetes. Il consolide dans un seul fichier les détails (adresse de l'API server, certificats, clés, contextes), évitant de ressaisir les paramètres à chaque commande.

### Le problème résolu

Sans kubeconfig, il faudrait passer tous les paramètres à chaque commande :

```bash
kubectl get pods \
  --server my-kube-playground:6443 \
  --client-key admin.key \
  --client-certificate admin.crt \
  --certificate-authority ca.crt
```

C'est **fastidieux** → on consolide tout dans un fichier kubeconfig.

### Emplacement par défaut

- Placé à **`~/.kube/config`**, kubectl l'utilise **automatiquement**, sans avoir à le spécifier.
- On peut aussi cibler un fichier précis :

```bash
kubectl get pods --kubeconfig my_custom_config
```

### Structure d'un kubeconfig

Fichier YAML organisé en **3 sections principales** :

| Section | Rôle | Exemple |
|---------|------|---------|
| **Clusters** | Détails des clusters (dev, test, prod, cloud) | `server: https://my-kube-playground:6443` |
| **Users** | Identifiants et certificats des utilisateurs | `client-certificate: admin.crt` |
| **Contexts** | Lient un **user** à un **cluster** (et éventuellement un namespace) | `cluster: production, user: admin` |

Exemple :

```yaml
apiVersion: v1
kind: Config
clusters:
- name: my-kube-playground
  cluster:
    certificate-authority: ca.crt
    server: https://my-kube-playground:6443
contexts:
- name: my-kube-admin@my-kube-playground
  context:
    cluster: my-kube-playground
    user: my-kube-admin
users:
- name: my-kube-admin
  user:
    client-certificate: admin.crt
    client-key: admin.key
```

> Convention de nommage des contextes : **`user@cluster`** (ex. `admin@production`).

### Le current-context

Le champ **`current-context`** définit le contexte **par défaut** utilisé par kubectl :

```yaml
apiVersion: v1
kind: Config
current-context: dev-user@google
clusters:
- name: my-kube-playground
- name: development
- name: production
- name: google
contexts:
- name: my-kube-admin@my-kube-playground
- name: dev-user@google
- name: prod-user@production
users:
- name: my-kube-admin
- name: admin
- name: dev-user
- name: prod-user
```

### Commandes essentielles (kubectl config)

Voir la configuration :

```bash
kubectl config view
```

Changer de contexte actif :

```bash
kubectl config use-context prod-user@production
```

→ met à jour le `current-context` dans le fichier.

### Namespaces dans le kubeconfig (point utile)

On peut associer un **namespace** à un contexte : ainsi, changer de contexte **active automatiquement** le bon namespace.

```yaml
apiVersion: v1
kind: Config
clusters:
- name: production
  cluster:
    certificate-authority: ca.crt
    server: https://my-kube-playground:6443
contexts:
- name: admin@production
  context:
    cluster: production
    user: admin
    namespace: finance
users:
- name: admin
  user:
    client-certificate: admin.crt
    client-key: admin.key
```

### Certificats : fichier vs données embarquées

Deux façons de référencer les certificats :
- **Par chemin de fichier** : `certificate-authority: ca.crt` (ou chemin complet `/etc/kubernetes/pki/ca.crt`).
- **Données embarquées** : encoder le certificat en **base64** et l'inclure sous **`certificate-authority-data`** :

```yaml
apiVersion: v1
kind: Config
clusters:
- name: production
  cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
```

```yaml
apiVersion: v1
kind: Config
clusters:
- name: production
  cluster:
    certificate-authority-data: LS0tC...0V1lQjkFReR...
```

→ Cela supprime la dépendance à des fichiers externes. Applicable aussi aux certificats et clés clients (`client-certificate-data`, `client-key-data`).

> **Sécurité** : ne jamais exposer les clés ou certificats dans des dépôts publics.

### Tableau récapitulatif

| Section | But | Exemple |
|---------|-----|---------|
| Clusters | Détails du cluster | `server: https://...:6443` |
| Users | Identifiants/certificats | `client-certificate: admin.crt` |
| Contexts | Associe user + cluster (+ namespace) | `{cluster: production, user: admin, namespace: finance}` |
| Current Context | Contexte par défaut | `current-context: prod-user@production` |

### À retenir

- Le kubeconfig regroupe **Clusters + Users + Contexts** dans un seul fichier YAML.
- Placé dans **`~/.kube/config`**, il est utilisé automatiquement.
- Un **context** = un **user** + un **cluster** (+ un namespace optionnel), nommé `user@cluster`.
- **`current-context`** définit le contexte par défaut ; **`kubectl config use-context`** en change.
- **`kubectl config view`** affiche la configuration.
- Certificats : par **chemin** ou embarqués en **base64** (`...-data`).
- Kubernetes ne modifie pas les fichiers originaux : c'est purement de la configuration côté client.

### Liens utiles

- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Docker Hub : https://hub.docker.com/
- Terraform Registry : https://registry.terraform.io/

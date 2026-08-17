# Security Contexts

Les **security contexts** permettent de renforcer la sécurité des conteneurs dans Kubernetes en configurant les **identifiants utilisateur (user IDs)** et les **capacités Linux (Linux capabilities)**.

### Rappel : options de sécurité dans Docker

Docker permet déjà de définir des standards de sécurité au lancement d'un conteneur :

```bash
docker run --user=1001 ubuntu sleep 3600      # définir l'ID utilisateur
docker run --cap-add MAC_ADMIN ubuntu         # ajouter une capacité Linux
```

Ce concept s'étend à Kubernetes.

### Appliquer un Security Context dans Kubernetes

Kubernetes encapsule les conteneurs dans des pods et offre deux niveaux de configuration :
- **Au niveau du pod** (`securityContext` sous `spec`) : affecte **tous** les conteneurs du pod ;
- **Au niveau du conteneur** (`securityContext` sous `containers`) : s'applique à un conteneur précis.

> **Règle de priorité (point crucial)** : si les deux niveaux sont définis, les **paramètres au niveau du conteneur l'emportent** sur ceux du pod.

### Exemple : security context au niveau du conteneur

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
spec:
  containers:
    - name: ubuntu
      image: ubuntu
      command: ["sleep", "3600"]
      securityContext:
        runAsUser: 1000
        capabilities:
          add: ["MAC_ADMIN"]
```

Décomposition :
- **`runAsUser: 1000`** : exécute le conteneur en tant qu'utilisateur d'ID 1000 ;
- **`capabilities.add: ["MAC_ADMIN"]`** : ajoute la capacité Linux `MAC_ADMIN`.

> **Point important** : les **`capabilities`** ne sont supportées **qu'au niveau du conteneur**, pas au niveau du pod.

### Correspondance Docker ↔ Kubernetes

| Docker | Kubernetes (securityContext) |
|--------|------------------------------|
| `--user=1001` | `runAsUser: 1001` |
| `--cap-add MAC_ADMIN` | `capabilities: { add: ["MAC_ADMIN"] }` |

### À retenir

- Le **`securityContext`** configure la sécurité des conteneurs (user ID, capabilities Linux).
- Deux niveaux : **pod** (tous les conteneurs) ou **conteneur** (un seul).
- En cas de conflit, **le niveau conteneur l'emporte** sur le niveau pod.
- **`runAsUser`** définit l'ID utilisateur ; **`capabilities.add`** ajoute des capacités Linux.
- Les **capabilities** ne sont disponibles qu'au **niveau conteneur**.

### Liens utiles

- Kubernetes Overview (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Documentation Docker : https://docs.docker.com/

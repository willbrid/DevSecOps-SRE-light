# Image Security

Ce contenu couvre les **bonnes pratiques** pour sécuriser les images de conteneurs : convention de nommage, dépôts sécurisés, et configuration des pods pour utiliser des **registres privés**.

### La convention de nommage des images (point essentiel)

Quand on spécifie une image comme `nginx`, on suit la convention de nommage Docker :

```
image: nginx
```

Cela signifie en réalité **`library/nginx`** :
- Sans nom de compte, Docker utilise par défaut le compte **`library`** (qui héberge les **images officielles** maintenues par Docker).
- Pour nos propres images : **`notrenom/nomimage`** au lieu de `library/nomimage`.

Sans emplacement précisé, l'image est tirée du registre par défaut, **Docker Hub** (DNS : **`docker.io`**). Ainsi :

```
image: nginx
# équivaut à →
image: docker.io/library/nginx
```

**Structure complète** : `[registre]/[compte]/[image]` → `docker.io/library/nginx`.

### Registres publics et privés

| Registre | Adresse | Description |
|----------|---------|-------------|
| **Docker Hub** | `docker.io` | Registre par défaut (images officielles et communautaires) |
| **Google Container Registry (GCR)** | `gcr.io` | Nombreuses images liées à Kubernetes, publiques |
| **Registres privés** | Variable | Pour applications internes confidentielles ; proposés par AWS, Azure, GCP |

> **Bonne pratique** : restreindre l'accès à son dépôt par des **identifiants**, quel que soit le registre.

### Utiliser une image privée avec Docker

Il faut d'abord se **connecter** au registre privé :

```bash
docker login private-registry.io
# Username / Password → Login Succeeded
```

Puis exécuter le conteneur :

```bash
docker run private-registry.io/apps/internal-app
```

### Configurer Kubernetes pour un registre privé

Kubernetes a besoin des **identifiants** pour tirer les images d'un registre privé. On procède en 2 étapes :

#### Étape 1 : Créer un Secret de type docker-registry

```bash
kubectl create secret docker-registry regcred \
  --docker-server=private-registry.io \
  --docker-username=registry-user \
  --docker-password=registry-password \
  --docker-email=registry-user@org.com
```

Note : le type de secret spécifique est **`docker-registry`**.

#### Étape 2 : Référencer le Secret dans le Pod via `imagePullSecrets`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: private-registry.io/apps/internal-app
  imagePullSecrets:
  - name: regcred
```

À la création du pod, Kubernetes utilise les identifiants du secret pour **s'authentifier** auprès du registre privé et **tirer** l'image.

> Le **nom du secret** référencé dans le pod (`regcred`) doit **correspondre** à celui utilisé lors de sa création.

### À retenir

- Nommage des images : **`registre/compte/image`** → `nginx` = `docker.io/library/nginx`.
- Le compte **`library`** héberge les **images officielles** ; registre par défaut = **Docker Hub** (`docker.io`).
- Registres : **Docker Hub**, **GCR** (`gcr.io`), et **registres privés** (AWS/Azure/GCP).
- Pour un registre privé dans Kubernetes : créer un **Secret `docker-registry`** puis le référencer via **`imagePullSecrets`** dans le pod.
- Le nom du secret dans le pod doit **correspondre** exactement à celui créé.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Docker Hub : https://hub.docker.com/
- Google Container Registry : https://cloud.google.com/container-registry
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/

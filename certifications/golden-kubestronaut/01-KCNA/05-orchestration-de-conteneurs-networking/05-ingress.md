# Ingress

Ce contenu revisite les services Kubernetes pour aboutir progressivement à l'**Ingress**, en expliquant les différences entre services et Ingress, et les bonnes pratiques pour gérer l'**accès externe** aux applications.

**Scénario évolutif** : déploiement d'une boutique en ligne `myonlinestore.com`.
1. L'application est empaquetée en image Docker, déployée en pod via un **Deployment**.
2. Une base MySQL est déployée en pod, exposée par un service **ClusterIP** (`MySQL service`) pour la communication **interne**.
3. Pour exposer l'application en **externe**, on crée un service **NodePort** sur le port `38080`. Les utilisateurs accèdent via `http://<node-ip>:38080`. Le service répartit le trafic sur les réplicas.

#### Les limites du NodePort en production

- Exposer directement les IP des nœuds et les ports n'est **pas idéal**.
- On peut configurer le **DNS** pour mapper `myonlinestore.com` vers les IP des nœuds et le port `38080`, mais l'utilisateur devrait **toujours préciser le port** dans l'URL.
- **Solution** : ajouter un **serveur proxy** qui redirige le port standard **80** vers `38080`. Une fois le DNS pointant vers le proxy, l'accès se fait simplement via `myonlinestore.com`.

#### Le service LoadBalancer (cloud)

Sur un cloud public (ex. **GCP**), on peut utiliser un service **LoadBalancer** au lieu de NodePort : Kubernetes provisionne un port élevé **et** demande un **load balancer réseau** au cloud. Ce dernier reçoit une **IP externe** mappée au DNS, permettant l'accès sans préciser de port.

#### Le problème qui justifie l'Ingress

En ajoutant des services (ex. un service de streaming vidéo accessible via `myonlinestore.com/watch` tout en gardant `myonlinestore.com/wear`), chaque service exigerait **son propre load balancer** → **coûts additionnels**. On veut aussi :
- activer le **SSL (HTTPS)** ;
- **centraliser** la terminaison SSL, le load balancing et le routage dans Kubernetes, plutôt que de disperser ces réglages.

> **L'Ingress** permet la gestion **centralisée** du routage HTTP, de la terminaison SSL et du load balancing via des objets natifs de l'API Kubernetes.

L'Ingress fournit une solution de **load balancing de niveau 7 (couche 7)** intégrée à Kubernetes. Après avoir exposé l'**Ingress controller** en externe (via NodePort ou load balancer cloud), les configurations (load balancing, authentification, SSL, routage par URL) se gèrent via des **ressources Ingress** dans le cluster.

Sans Ingress, il faudrait déployer un reverse proxy dédié (**NGINX, HAProxy, Traefik**) et gérer des configurations complexes **séparément** pour chaque service — ce qui devient ingérable à mesure que les services se multiplient.

---

### Ingress Controller

Un **Ingress controller** est responsable de l'**implémentation des règles Ingress**. Il :
- surveille en continu le cluster pour détecter les nouvelles ressources Ingress ;
- **reconfigure dynamiquement** le proxy sous-jacent (ex. NGINX).

> **Point crucial** : Kubernetes **n'inclut PAS** d'Ingress controller par défaut → il faut en **déployer un**. Options : **GCE, NGINX, Contour, HAProxy, Traefik, Istio**. Ce guide utilise le **NGINX Ingress Controller** (activement supporté par le projet Kubernetes).

#### Déploiement du NGINX Ingress Controller

**1. Le Deployment** (1 réplica, label `nginx-ingress`, image NGINX dédiée) :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress-controller
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-ingress
  template:
    metadata:
      labels:
        app: nginx-ingress
    spec:
      containers:
      - name: nginx-ingress-controller
        image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.21.0
        args:
        - /nginx-ingress-controller
```

**2. Un ConfigMap** pour découpler la configuration runtime de l'image (chemins de logs, keep-alive, SSL, timeouts de session) :
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-configuration
```

**3. Un Service (NodePort)** exposant le controller sur les ports HTTP (80) et HTTPS (443) :
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  - name: https
    port: 443
    targetPort: 443
    protocol: TCP
  selector:
    app: nginx-ingress
```

**4. Un déploiement enrichi** avec variables d'environnement (métadonnées du pod) et référence au ConfigMap :
```yaml
        args:
        - /nginx-ingress-controller
        - --configmap=$(POD_NAMESPACE)/nginx-configuration
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
```

**Récapitulatif** : mettre en place un Ingress controller nécessite **4 objets** :
- un **Deployment** exécutant le NGINX Ingress Controller ;
- un **Service** pour l'exposer en externe ;
- un **ConfigMap** pour la configuration dynamique ;
- un **Service Account** avec les permissions nécessaires.

---

### Ingress Resources

Une **ressource Ingress** définit les **règles de routage** du trafic HTTP/HTTPS externe vers les services backend du cluster.

#### 1. Single Backend (backend unique)

Pour les cas simples, tout le trafic est dirigé vers un **seul service** :
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wear
spec:
  backend:
    service:
      name: wear-service
      port: 
        number: 80
```
```bash
kubectl create -f Ingress-wear.yaml
kubectl get ingress
# NAME           HOSTS   ADDRESS   PORTS   AGE
# ingress-wear   *                 80      2s
```

#### 2. Routage par chemin d'URL (URL Path Rules)

Pour séparer le trafic selon l'URL (ex. `/wear` et `/watch`) :
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wear-watch
spec:
  rules:
  - http:
      paths:
      - path: /wear
        backend:
          service:
            name: wear-service
            port: 
              number: 80
      - path: /watch
        backend:
          service:
            name: watch-service
            port: 
              number: 80
```

Vérifier :
```bash
kubectl describe ingress ingress-wear-watch
```

La sortie montre les règles (`/wear` → `wear-service:80`, `/watch` → `watch-service:80`) et un **Default backend**.

#### 3. Routage par nom d'hôte (Host-Based Rules)

Pour router selon le **domaine/sous-domaine** :
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-host-based
spec:
  rules:
  - host: wear.my-online-store.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: wear-service
            port: 
              number: 80
  - host: watch.my-online-store.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: watch-service
            port: 
              number: 80
```
💡 **Point important** : si le champ **`host` est omis**, les règles s'appliquent à **tout** le trafic entrant.

#### Le Default Backend (404)

Si un utilisateur navigue vers une URL non définie (ex. `myonlinestore.com/listen` ou `/eat`), on peut configurer un **default backend** renvoyant une page **404 Not Found**.

---

### Path-based vs Host-based (distinction clé)

| Type de routage | Critère | Exemple |
|-----------------|---------|---------|
| **Par chemin (path)** | Le **chemin** de l'URL | `myonlinestore.com/wear` vs `/watch` |
| **Par hôte (host)** | Le **sous-domaine** | `wear.my-online-store.com` vs `watch.my-online-store.com` |

En exploitant ces configurations, un **seul Ingress controller** peut servir plusieurs services, centralisant SSL, load balancing et routage dans Kubernetes → opérations simplifiées et **coûts cloud réduits**.

---

### À retenir

- L'**Ingress** = load balancing de **niveau 7** intégré, pour gérer de façon **centralisée** le routage HTTP/HTTPS, le **SSL** et le load balancing (évite un load balancer par service).
- Il faut **2 composants** : l'**Ingress controller** (le moteur, à déployer soi-même — NGINX, Traefik, Istio…) + les **ressources Ingress** (les règles de routage).
- Kubernetes **ne fournit pas** de controller par défaut.
- Déployer un controller NGINX = **Deployment + Service (NodePort) + ConfigMap + ServiceAccount**.
- 3 types de règles : **backend unique**, **par chemin d'URL** (`/wear`, `/watch`), **par hôte** (`wear.` vs `watch.`).
- `host` omis → règle appliquée à tout le trafic ; **default backend** → page 404 pour les URL non définies.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- NGINX Ingress Controller : https://www.nginx.com/
- Google Cloud Platform : https://cloud.google.com

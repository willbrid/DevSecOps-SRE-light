# Envoy et le concept de Proxy (KCNA)

Quand on entre dans le monde du **service mesh**, **Envoy** est l'un des **proxies les plus courants** dont on entend parler. Pour bien le comprendre, il faut d'abord mettre Kubernetes de côté un instant et comprendre **ce qu'est un proxy**.

### Le problème : trop de responsabilités dans l'application

Considérons un utilisateur qui essaie de se connecter à une application. Actuellement, l'application contient :
- sa **logique metier** (ce qu'elle fait concrètement, sa valeur métier) ;
- **mais aussi** d'autres tâches annexes :
  - sécuriser les connexions via **TLS** ;
  - l'**authentification** ;
  - le **retry** des requêtes si l'application ne répond pas aux utilisateurs, etc.

Tout cela devrait être **codé dans l'application** — ce qui l'alourdit et détourne les développeurs de l'essentiel.

### La solution : externaliser via un Proxy

Et si toutes ces **fonctionnalités supplémentaires** pouvaient être **externalisées** dans un **service séparé**, pour que les développeurs puissent se concentrer **uniquement sur la logique metier** ?

> C'est exactement ce qu'on appelle un **proxy**.

**Fonctionnement** :
- L'utilisateur ne contacte plus directement l'application, mais **contacte le proxy** ;
- Le proxy **transmet la requête** à l'application ;
- Le proxy gère au passage TLS, authentification, retry, etc.

### Qu'est-ce qu'Envoy ?

**Envoy** est un **proxy open-source** conçu pour les **architectures orientées services modernes**.

Historique et maturité :
- Débuté principalement chez **Lyft en 2015**, lorsqu'ils cherchaient à résoudre leurs propres problèmes de **microservices** ;
- Conçu principalement pour les **architectures distribuées** et les **microservices** ;
- En **2017**, le projet est **accepté au sein de la CNCF** ;
- En **2018**, il atteint le niveau **« graduated »** de la CNCF, ce qui signifie qu'il est **battle-tested** (éprouvé en conditions réelles), **prêt pour la production**, et dispose d'un **bon nombre de contributeurs**.

Envoy est à la fois :
- un **proxy** ;
- un **communication bus** doté de **fonctionnalités avancées**.

### Le lien avec les sidecars

Envoy **fonctionne comme un sidecar**, à côté de votre container (comme vu dans le concept de sidecar précédent), **pour que le trafic entrant et sortant** du Pod **utilise Envoy comme proxy**.

De nombreuses implémentations de **service mesh** utilisent aujourd'hui Envoy, et il jouera un rôle central dans l'architecture d'**Istio** (abordée ultérieurement).

#### Manifest d'exemple : Envoy comme sidecar proxy

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-envoy-sidecar
  labels:
    app: my-app
spec:
  containers:
    # Container principal : la logique metier
    - name: my-app
      image: my-app
      ports:
        - containerPort: 8080

    # Sidecar Envoy : proxy pour le trafic entrant/sortant
    - name: envoy-proxy
      image: envoyproxy/envoy:v1.33-latest
      ports:
        - containerPort: 10000   # port d'écoute du proxy
      volumeMounts:
        - name: envoy-config
          mountPath: /etc/envoy

  # Configuration d'Envoy montée via une ConfigMap
  volumes:
    - name: envoy-config
      configMap:
        name: envoy-configuration
```

**Décomposition** :
- Le container **my-app** (principal) se concentre uniquement sur la **logique metier** ;
- Le sidecar **envoy-proxy** intercepte le **trafic entrant et sortant** et gère TLS, authentification, retry, etc. ;
- Les deux partagent le **même network** au sein du Pod (communication via `localhost`).

### À retenir

- Un **proxy** permet d'**externaliser** les tâches annexes (TLS, authentification, retry…) hors de l'application, pour que les développeurs se concentrent sur la **logique metier**.
- Avec un proxy, l'utilisateur **contacte le proxy**, qui **transmet** ensuite la requête à l'application.
- **Envoy** = **proxy open-source** pour les architectures **microservices / distribuées**, né chez **Lyft en 2015**, **accepté à la CNCF en 2017**, **graduated en 2018** (donc mature et prêt pour la production).
- Envoy est à la fois un **proxy** et un **bus de communication** aux fonctionnalités avancées.
- Envoy s'exécute comme un **sidecar** : tout le trafic **entrant et sortant** du Pod passe par lui.
- Il est la **brique de base** de nombreux service meshes, notamment **Istio**.

### Liens utiles

- https://www.envoyproxy.io/docs
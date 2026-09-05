# Service mesh

Avec les microservices, on a vu le problème des **cross-cutting concerns** : au lieu d'intégrer toutes les exigences (networking, sécurité, etc.) **dans chaque microservice**, on va les **remplacer par un seul proxy** sous forme de **sidecar container**.

### Qu'est-ce qu'un Service Mesh ?

Un **Service Mesh** est une **couche d'infrastructure (infrastructure layer) dédiée et configurable** qui gère la **communication entre les services**, **sans avoir à modifier le code** dans le microservice.

Principe de fonctionnement :
- Chaque microservice est accompagné d'un **proxy sidecar** ;
- Les **proxies communiquent entre eux** via ce qu'on appelle le **data plane** ;
- Ils communiquent avec un composant côté serveur appelé **control plane** ;
- Le **control plane gère tout le trafic** entrant et sortant de vos services, via les proxies.

> **Résultat clé** : toute la **logique de networking** est ainsi **abstraite** de votre **code métier (business logic)**.

### Data Plane vs Control Plane (architecture clé)

| Composant | Rôle |
|-----------|------|
| **Data plane** | L'ensemble des **proxies sidecars** qui communiquent entre eux et gèrent concrètement le trafic entre services |
| **Control plane** | Le composant **côté serveur** qui **gère et configure** tout le trafic, en pilotant les proxies |

### L'avantage : configuration dynamique

Avec un Service Mesh, on peut **configurer dynamiquement** la manière dont les services communiquent entre eux, **sans toucher au code**.

### Les fonctionnalités principales du Service Mesh

Lorsque les services communiquent entre eux, le mesh apporte :

- **mTLS (mutual TLS)** : sécurise les workloads en chiffrant et authentifiant la communication **service-to-service** ;
- **Observabilité (visibility)** : meilleure visibilité sur les **performances** de l'application de bout en bout, et sur l'**emplacement des problèmes et bottlenecks** ;
- **Service discovery** : dans un cluster **dynamique**, il faut savoir sur **quelles IP et quels ports** les services sont exposés pour qu'ils puissent **se trouver** mutuellement ;
- **Health checks** : aident à garder **dynamiquement** les services opérationnels dans le mesh ; ceux qui sont **down sont écartés** ;
- **Load balancing** : dirige le trafic vers les **instances saines** et le **coupe** pour celles qui sont **en échec**.

### Exemple de manifest illustratif : injection d'un sidecar proxy

Dans un service mesh (comme Istio), le proxy sidecar (Envoy) est **automatiquement injecté** dans chaque Pod. Voici l'idée :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reviews
  labels:
    app: reviews
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reviews
  template:
    metadata:
      labels:
        app: reviews
      annotations:
        # Annotation qui déclenche l'injection auto du sidecar Envoy (data plane)
        sidecar.istio.io/inject: "true"
    spec:
      containers:
        # Container principal : la business logic
        - name: reviews
          image: bookinfo/reviews:java-v1
          ports:
            - containerPort: 9080
        # Le sidecar Envoy est injecté automatiquement par le control plane
        # (pas besoin de le déclarer manuellement)
```

**Décomposition** :
- L'**annotation** `sidecar.istio.io/inject: "true"` indique au **control plane** d'injecter automatiquement le **proxy sidecar (Envoy)** dans le Pod ;
- Le container `reviews` reste dédié à la **business logic** ;
- Le proxy injecté gère mTLS, service discovery, load balancing, etc. **sans modifier le code** de l'application.

### À retenir (synthèse)

- Un **Service Mesh** = **couche d'infrastructure dédiée et configurable** qui gère la communication **service-to-service** **sans modifier le code**.
- Il remplace les **cross-cutting concerns** dispersés par un **proxy sidecar** unique par microservice.
- **Architecture** : le **data plane** (les proxies sidecars, qui échangent entre eux) + le **control plane** (côté serveur, qui gère/configure tout le trafic).
- La **logique de networking est abstraite** du code métier → configuration **dynamique**.
- **Fonctionnalités clés** : **mTLS** (sécurité), **observabilité**, **service discovery**, **health checks**, **load balancing**.
- Le service mesh de référence est **Istio** (utilisant **Envoy** comme proxy sidecar).

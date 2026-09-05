# Istio

### Qu'est-ce qu'Istio ?

**Istio** est un **service mesh gratuit et open-source** qui offre un moyen **efficace** de **sécuriser, connecter et monitorer** les services.

Caractéristiques :
- Fonctionne avec **Kubernetes** et les **workloads traditionnels** ;
- Apporte : le **gestion du trafic**, la **telemetrie** et la **securité** aux déploiements complexes ;
- Est **supporté et implémenté** par les principaux **cloud providers et consultants**.

### Rappel : le proxy sidecar et le data plane

Le **proxy sidecar** s'occupe de toutes les tâches à **externaliser** du microservice. Ces proxies, et la **communication entre eux**, forment le **data plane**.

**Istio** implémente ces proxies via un **proxy open-source haute performance appelé Envoy**. Les proxies communiquent avec un composant **côté serveur** appelé **control plane**.

### L'architecture historique du Control Plane (3 composants)

À l'origine, le **control plane** se composait de **trois composants** :

| Composant | Rôle |
|-----------|------|
| **Citadel** | Gérait la **génération des certificats** (sécurité / mTLS) |
| **Pilot** | S'occupait du **service discovery** |
| **Galley** | Aidait à **valider les fichiers de configuration** |

### L'évolution : istiod (architecture actuelle)

Ces **trois composants ont ensuite été combinés en un seul daemon** appelé **istiod**.

Côté **data plane** :
- Chaque **service (ou pod)** contient un **composant distinct**, **en plus du proxy Envoy**, appelé **Istio agent** ;
- L'**Istio agent** est responsable de **transmettre les configurations et secrets** (configuration secrets) aux **proxies Envoy**.

### Schéma récapitulatif de l'architecture

```
CONTROL PLANE
   └── istiod  (fusion de Citadel + Pilot + Galley)
        │  distribue config, certificats, service discovery
        ▼
DATA PLANE (dans chaque Pod)
   ┌─────────────────────────────────────┐
   │  Pod                                 │
   │   ├── Container applicatif           │
   │   ├── Istio agent  ← reçoit config/secrets d'istiod
   │   └── Proxy Envoy  ← reçoit config de l'Istio agent
   └─────────────────────────────────────┘
```

### À retenir

- **Istio** = **service mesh** open-source et gratuit pour **sécuriser, connecter et monitorer** les services ; fonctionne avec Kubernetes et les workloads traditionnels (traffic management, telemetry, security).
- **Data plane** = les proxies **Envoy** (haute performance) qui échangent entre eux.
- **Control plane** = historiquement **3 composants** : **Citadel** (certificats), **Pilot** (service discovery), **Galley** (validation de config).
- **Évolution majeure** : ces 3 composants ont fusionné en un **seul daemon**, **istiod**.
- Dans chaque Pod, en plus du proxy **Envoy**, il y a un **Istio agent** chargé de transmettre les **configurations et secrets** aux proxies Envoy.

### Liens utiles

- Documentation officielle Istio : https://istio.io/latest/docs/


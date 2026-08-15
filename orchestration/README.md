# Orchestration

Ce dossier regroupe **uniquement** les contenus liés à l'**orchestration de conteneurs**, autour de deux orchestrateurs :

- **Kubernetes**
- **Docker Swarm**

On y traite des concepts, des configurations et des travaux pratiques permettant de déployer, exposer, mettre à l'échelle et exploiter des applications conteneurisées.

> Les contenus dédiés à la **préparation aux certifications** ne sont pas dans ce dossier : ils sont regroupés dans le dossier [certifications](../certifications/).

### Contenus

#### 1. kubernetes

| Répertoire | Description |
| --- | --- |
| [kcna](kubernetes/kcna/) | Fondamentaux de Kubernetes, orchestration de conteneurs, architecture cloud native, observabilité et livraison d'applications |
| [cka](kubernetes/cka/) | Gestion des clusters, objets Kubernetes, pods et conteneurs, allocation avancée, déploiements, réseau, services, stockage et troubleshooting |
| [ckad](kubernetes/ckad/) | Conception et construction d'applications, déploiement, observabilité et maintenance, configuration et sécurité des applications, services et réseau |
| [cks](kubernetes/cks/) | Configuration et durcissement du cluster, durcissement du système, réduction des vulnérabilités des microservices, sécurité de la chaîne d'approvisionnement, monitoring et sécurité d'exécution |
| [helm](kubernetes/helm/) | Packaging et gestion du cycle de vie des applications Kubernetes avec Helm |
| [keda](kubernetes/keda/) | Mise à l'échelle automatique des workloads pilotée par les évènements avec KEDA |
| [hands-on-labs](kubernetes/hands-on-labs/) | Travaux pratiques de bout en bout pour mettre en application les concepts |

#### 2. docker swarm

Contenus liés à l'orchestration native de Docker : initialisation d'un cluster (managers / workers), services et réplicas, réseaux overlay, secrets et configs, stacks et mises à jour progressives.

> Cette section est en cours de rédaction.

### Prérequis

Une bonne compréhension de la **conteneurisation** est recommandée avant d'aborder ces contenus : voir le dossier [conteneur](../conteneur/).

### Références

- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Docker Swarm Documentation](https://docs.docker.com/engine/swarm/)
- [Helm Documentation](https://helm.sh/docs/)
- [Keda Documentation](https://keda.sh/docs)

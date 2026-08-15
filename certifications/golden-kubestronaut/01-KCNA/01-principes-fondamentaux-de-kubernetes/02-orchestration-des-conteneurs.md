# Orchestration des conteneurs

Après avoir maîtrisé les fondamentaux des conteneurs et de Docker, cette section explique comment **déployer des applications conteneurisées en production**. Trois questions essentielles se posent :
- Comment exécuter l'application en environnement de production ?
- Comment gérer les services dépendants (bases de données, systèmes de messagerie, composants backend) ?
- Comment adapter l'échelle (scaling) selon la demande, à la hausse comme à la baisse ?

### Qu'est-ce que l'orchestration ?

Une **plateforme d'orchestration** est nécessaire pour gérer la connectivité entre conteneurs et ajuster dynamiquement les services selon la charge. Ce processus s'appelle l'**orchestration de conteneurs**.

### Les outils d'orchestration

Trois solutions principales existent :

| Outil | Caractéristiques |
|-------|------------------|
| **Docker Swarm** | Configuration simple, mais fonctionnalités limitées pour les applications complexes. |
| **Apache Mesos** | Puissant, mais difficile à configurer au départ. |
| **Kubernetes** | Configuration initiale plus exigeante, mais offre une personnalisation étendue, supporte les architectures complexes et est intégré aux principaux clouds publics (GCP, Azure, AWS). Très populaire sur GitHub. |

### Les avantages de l'orchestration

- **Haute disponibilité** : réduction des interruptions grâce à plusieurs instances réparties sur différents nœuds.
- **Répartition de charge (Load Balancing)** : distribution équilibrée du trafic entre les conteneurs.
- **Scalabilité** : déploiement fluide d'instances supplémentaires selon la demande.
- **Flexibilité** : adaptation des services et des nœuds sous-jacents sans interruption.
- **Simplicité** : gestion via des fichiers de configuration déclaratifs.

### Kubernetes

Kubernetes permet de gérer et déployer des **centaines, voire des milliers de conteneurs** dans un environnement en cluster.

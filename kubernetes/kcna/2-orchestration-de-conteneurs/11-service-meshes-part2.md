# Service Meshes [PART2]

#### Architecture

À un niveau de base, un maillage de services se compose de services et de proxys exécutés en tant que side-cars vers les services. Il inclut également une autorité qui configure ces proxys pour combiner les proxys et services en un système distribué approprié, qui comprend un plan de données et un plan de contrôle. Toutes les requêtes adressées à ou depuis un service passent par deux proxys au sein du maillage : le proxy du service appelant et le proxy du service destinataire.
<br>
Cette architecture élimine toutes les fonctions qui ne sont pas liées à la logique métier des services et des développeurs de services. Le plan de données gère les proxys et les services. Le plan de contrôle est l'autorité qui fournit une stratégie et une configuration au plan de données.
<br>
Le plan de contrôle du maillage de services permet aux proxys d'effectuer les fonctions suivantes :

- Recherche de services
- Routage de services
- Équilibrage de charge
- Authentification et autorisation
- Observabilité
<br><br>

Le plan de contrôle est responsable des éléments suivants :

- **Registre de service** : le plan de contrôle doit disposer d'une liste des services et points de terminaison disponibles pour les fournir aux proxys. Le plan de contrôle compile ce registre en interrogeant le système de planification d'infrastructure sous-jacent, tel que Kubernetes, pour obtenir la liste de tous les services disponibles.
- **Configuration du proxy side-car** : la configuration des proxys side-car inclut des stratégies et des configurations à l'échelle du maillage dont les proxys doivent être informés pour effectuer correctement leurs fonctions.

#### Service Mesh Interface (SMI)

Le SMI fournit :

- Une interface standard pour les maillages de services sur Kubernetes
- Un ensemble de fonctionnalités de base pour les cas d'utilisation de maillage de services les plus courants
- Flexibilité pour prendre en charge de nouvelles capacités de maillage de services au fil du temps
- Un espace pour que l'écosystème innove avec la technologie de maillage de services

<br>

Le  est une spécification qui couvre les fonctionnalités de service mesh les plus courantes :

- Politique de trafic - appliquer des politiques telles que le chiffrement de l'identité et du transport à travers les services
- Télémétrie du trafic - capturer des mesures clés telles que le taux d'erreur et la latence entre les services
- Gestion du trafic - déplacer le trafic entre différents services

<br>

La SMI est spécifiée comme une collection de définitions de ressources personnalisées (CRD) Kubernetes et de serveurs d'API d'extension. Ces API peuvent être installées sur n'importe quel cluster Kubernetes et manipulées à l'aide d'outils standard.
<br>
L'objectif de l'API SMI est de fournir un ensemble commun et portable d'API de maillage de services qu'un utilisateur Kubernetes peut utiliser de manière indépendante du fournisseur. De cette façon, les gens peuvent définir des applications qui utilisent la technologie de maillage de services sans se lier étroitement à une implémentation spécifique.

[https://cloud.google.com/architecture/service-meshes-in-microservices-architecture?hl=fr](https://cloud.google.com/architecture/service-meshes-in-microservices-architecture?hl=fr)

[https://smi-spec.io/](https://smi-spec.io/)
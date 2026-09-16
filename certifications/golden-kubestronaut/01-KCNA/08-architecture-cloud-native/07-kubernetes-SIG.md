# Kubernetes SIG

### Kubernetes, un projet open-source massif

Kubernetes est l'un des projets open-source les plus populaires : plus de **80 000 stars sur GitHub**, plus de **2 500 développeurs** contributeurs et plus d'**1 million de contributions**. C'est la plateforme d'orchestration de référence pour les applications conteneurisées.

Les grands acteurs (**Google, Microsoft, AWS**) s'appuient sur Kubernetes pour leurs besoins de gestion de conteneurs, leurs solutions d'hébergement et contribuent à son développement.

### Historique et croissance

- Kubernetes a été **développé par Google en 2014** pour simplifier le déploiement et la gestion d'applications conteneurisées sur plusieurs hôtes ;
- **Premier commit** : **6 juin 2014** ;
- Son évolution s'est accélérée en rejoignant la **CNCF (Cloud Native Computing Foundation) en 2016**.

**Croissance des contributeurs** : ~20 développeurs au départ → ~400 après avoir rejoint la CNCF → plus de **3 000 contributeurs** aujourd'hui.

### Le défi de gérer un projet aussi vaste (analogie)

**Analogie** : gérer Kubernetes, c'est comme **construire un gratte-ciel** dans une ville animée — coordonner les ouvriers, gérer les chaînes d'approvisionnement, assurer la sécurité, le tout simultanément.

Kubernetes exige une gestion méticuleuse de nombreux domaines : **architecture, sécurité, APIs, CLI, autoscaling, networking, storage**, et les intégrations avec les cloud providers.

### Le modèle de gouvernance communautaire

De par sa nature open-source, Kubernetes est géré par une **communauté diverse** plutôt que par une organisation centralisée. Son succès repose sur un **modèle de gouvernance bien défini**.

#### Le Steering Committee (comité de pilotage)

Au **sommet de la hiérarchie** se trouve le **Kubernetes Steering Committee**, responsable de :
- définir la **direction générale** du projet ;
- définir l'**architecture** du système ;
- **prioriser** les nouvelles features ;
- **résoudre les conflits** entre les différents domaines ;
- guider les **working groups** et les **SIGs**.

Membres du comité (au moment de l'enregistrement) : Benjamin Elder (Google), Christoph Blecker (Red Hat), Carlos Panato Jr. (ChainGuard), Stephen Augustus (Cisco), Bob Killen (Google), Nabarun Pal (VMware), Tim Pepper (VMware).

### Working Groups vs SIGs (distinction clé)

Sous le Steering Committee se trouvent les **working groups** et les **SIGs** :
- **Working groups** : traitent des **défis transversaux (cross-cutting)** couvrant plusieurs domaines ;
- **SIGs (Special Interest Groups)** : équipes **spécialisées** responsables de **facettes distinctes** de Kubernetes.

**Analogie** : le SIG Architecture fonctionne comme une **équipe d'architectes** concevant un gratte-ciel, veillant à une approche architecturale cohérente. Les SIGs rationalisent le développement, favorisent l'innovation rapide et évitent les **chevauchements** de responsabilités.

### Les responsabilités clés des SIGs

1. **Code Development** : nouvelles features, correction de bugs, amélioration du code ;
2. **Testing and Validation** : garantir que les releases respectent les standards de qualité ;
3. **Documentation** : maintenir à jour les guides, références et documentation API ;
4. **Community Outreach and Education** : organiser meetups, webinars, conférences ;
5. **Release Management** : coordonner tout le processus de release ;
6. **Architecture and Design Guidance** : garantir scalabilité, fiabilité et maintenabilité.

### Fonctionnement et transparence des SIGs

- Les discussions se font **ouvertement** : visioconférences, chat, mailing lists, groupes Slack, GitHub issues et pull requests ;
- Tous les détails des réunions sont sur le **calendrier public** de la communauté, avec **enregistrements disponibles** ;
- Les propositions techniques et changements de design sont gérés via le processus **KEP (Kubernetes Enhancement Proposal)** ;
- Chaque SIG est dirigé par un ou plusieurs **chairs** (présidents) qui facilitent les discussions et les décisions ;
- Une liste complète des SIGs (co-chairs, canaux, horaires) est **publiquement accessible**.

### Exemples de SIGs

| SIG | Rôle |
|-----|------|
| **SIG Architecture** | Supervise le design global et la cohérence de l'API |
| **SIG Cluster Lifecycle** | Gère la création, gestion et mise à niveau des clusters |
| **SIG Storage** | Gestion du stockage, cohérence des API entre fournisseurs |
| **SIG Network** | Fonctionnalités réseau avec API cohérente entre fournisseurs |

### Création de nouveaux SIGs

La création d'un nouveau SIG (ou l'expansion des membres) commence par des **propositions communautaires**, examinées par le **Steering Committee** pour vérifier l'alignement avec les objectifs communautaires. Une fois approuvé, le SIG adopte sa **propre structure de gouvernance** via un processus de **nomination et d'élection** de ses leaders.

### À retenir (synthèse)

- Kubernetes : développé par **Google en 2014** (1er commit le 6 juin 2014), rejoint la **CNCF en 2016** ; projet open-source massif (3 000+ contributeurs).
- **Gouvernance hiérarchique** : au sommet, le **Steering Committee** (direction, architecture, priorités, conflits) ; en dessous, **working groups** (transversaux) et **SIGs** (spécialisés).
- Les **SIGs (Special Interest Groups)** = équipes spécialisées par domaine (Architecture, Cluster Lifecycle, Storage, Network, Security…), évitant les chevauchements.
- **6 responsabilités** des SIGs : code, tests, documentation, outreach, release management, architecture.
- Fonctionnement **ouvert et transparent** (Slack, mailing lists, GitHub, calendrier public) ; changements techniques via les **KEPs** ; dirigés par des **chairs**.

### Liens utiles

- Liste officielle des SIGs Kubernetes : https://github.com/kubernetes/community/blob/master/sig-list.md
- Communauté Kubernetes (gouvernance) : https://github.com/kubernetes/community
- Valeurs de la communauté Kubernetes : https://github.com/kubernetes/community/blob/master/values.md

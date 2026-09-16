# Serverless

### Introduction : qu'est-ce que le serverless ? (analogie)

**Analogie** : imaginez organiser une fête d'anniversaire chez vous en engageant une **équipe de nettoyage professionnelle**. Elle prépare la maison avant l'événement, la maintient propre pendant, et nettoie une fois les invités partis. C'est exactement l'esprit du **serverless computing**.

**Le principe** :
- En informatique **traditionnelle**, les entreprises doivent **acheter/gérer les serveurs** elles-mêmes, les configurer et les maintenir continuellement ;
- En **serverless**, le **cloud provider gère toute l'infrastructure** (provisioning, maintenance, scaling) → vous vous concentrez **uniquement sur la logique métier** de votre application.

> **Nuance importante** : même si l'infrastructure serveur est gérée par le cloud provider, votre application effectue toujours des **tâches essentielles** (redimensionner des images, envoyer des notifications, déclencher des emails). Ce sont vos **business logic** qui tournent en arrière-plan. (Le nom « serverless » ne signifie pas « sans serveur », mais « sans gestion de serveur » de votre côté.)

### Function as a Service (FaaS)

**Analogie** : le FaaS, c'est comme engager une **équipe d'aides spécialisées** pour votre fête : l'un accueille les invités, un autre sert les boissons, un autre anime. Chacun a un **rôle unique et clair**, et ne travaille **que quand nécessaire**.

**Le concept** : le FaaS permet d'écrire de **petits morceaux de code spécifiques à une tâche**, qui s'exécutent **en réponse à des événements** (requêtes HTTP, messages dans une file d'attente).

**Fonctionnement** :
- Ces fonctions spécialisées sont **uploadées** chez un cloud provider, qui les **exécute automatiquement** lorsqu'un événement spécifique les déclenche ;
- **Modèle de tarification pay-as-you-go** : vous ne payez **que lorsque le code s'exécute** (comme n'engager les aides que pour leur temps de travail) ;
- **Idéal** pour les applications à trafic ou usage **imprévisible**.

**Exemple concret** : une petite boutique de t-shirts en ligne doit envoyer un email de confirmation après un achat. Au lieu de gérer un serveur d'email, on implémente une **fonction** (ex. **AWS Lambda**), déclenchée automatiquement après l'achat, envoyant l'email via **SendGrid** ou **Amazon SES**. La plateforme FaaS **scale** la fonction selon le volume de requêtes.

**Offres FaaS des principaux cloud providers** :
- **AWS Lambda** et **AWS Fargate** (Amazon Web Services) ;
- **Azure Functions** (Microsoft Azure) ;
- **Google Cloud Functions** (Google Cloud) ;
- **IBM Cloud Functions**.

### Kubernetes Serverless : l'approche hybride

Le **Kubernetes serverless** combine la **scalabilité de Kubernetes** avec la **simplicité du serverless**.

**Contexte** : dans un setup Kubernetes standard, les conteneurs tournent dans des clusters répartis sur plusieurs serveurs/VM. Kubernetes assure la haute disponibilité via l'**auto-scaling**, le **load balancing** et le **self-healing**.

**Les plateformes** : pour répondre à la demande croissante d'architectures serverless, des plateformes comme **Knative** et **OpenFaaS** ont été développées **au-dessus de Kubernetes**. Elles permettent de déployer des **fonctions serverless** qui gèrent automatiquement :
- le **scaling** ;
- le **déclenchement par événements (event triggering)** ;
- la **gestion du cycle de vie (lifecycle management)**.

**Bénéfices du modèle hybride** : scalabilité accrue, **coûts opérationnels réduits** et **productivité développeur améliorée**.

### Synthèse des bénéfices

- Le **serverless** vous libère de la **gestion de l'infrastructure** → focus sur la **logique applicative** ;
- Le **FaaS** offre une exécution de code **efficace, event-driven** et en **pay-as-you-go** ;
- Le **Kubernetes serverless** combine l'**orchestration de conteneurs** avec les **avantages opérationnels du serverless**.

### À retenir

- **Serverless** = le cloud provider gère l'infrastructure (provisioning, maintenance, scaling) ; vous ne gérez que votre **code métier** (« sans gestion de serveur », pas « sans serveur »).
- **FaaS** = petites **fonctions** déclenchées par des **événements** (HTTP, messages), en **pay-as-you-go** (payer uniquement à l'exécution), idéal pour un trafic imprévisible.
- Offres FaaS : **AWS Lambda/Fargate, Azure Functions, Google Cloud Functions, IBM Cloud Functions**.
- **Kubernetes serverless** = approche **hybride** (scalabilité de Kubernetes + simplicité du serverless) via **Knative** et **OpenFaaS** (scaling, event triggering, lifecycle management auto).
- Bénéfices : moins de gestion d'infra, coûts réduits, productivité accrue.

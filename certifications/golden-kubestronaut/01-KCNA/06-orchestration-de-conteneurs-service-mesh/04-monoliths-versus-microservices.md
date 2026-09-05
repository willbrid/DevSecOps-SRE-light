# Monolithes vs Microservices

### Le problème du monolithe

Quand on travaille sur une **seule grosse application** et que quelque chose casse, **tout tombe en panne**. En revanche, si on modifie de **petites portions** de l'app, les choses seraient plus **sous contrôle** : la partie expérimentée pourrait être affectée, mais le **risque serait moindre**.

C'est pourquoi on a commencé à concevoir des applications **de plus en plus petites**, afin d'**isoler les risques** pendant l'expérimentation, et de **déployer plus vite et plus fréquemment**.

Les **systèmes géants** sont devenus un **frein majeur** à l'innovation et à l'agilité → il a fallu **repenser les architectures logicielles traditionnelles**.

### Qu'est-ce qu'un monolithe ? (définition)

Le terme **monolith** est utilisé quand **toutes les fonctionnalités** d'une app doivent être **déployées en même temps**, avec une **approche unifiée**. Caractéristiques :
- Toutes les fonctionnalités **partagent presque toujours le même code de base**, sans véritables limites entre elles ;
- Ces pièces sont **étroitement couplées (tightly coupled)** ;
- Tout le code pourrait même fonctionner comme un **seul process** ;
- Il y a généralement une **seule base de données** pour la persistance → ce qui finit par devenir un **énorme bottleneck (goulot d'étranglement)**.

### Exemple concret : l'application Bookinfo

Elle se compose de **quatre modules** :
- **details**
- **reviews**
- **ratings**
- **product page**

C'est une application **modulaire**, mais **toujours un monolith** : tous les services dépendent d'une **version spécifique des autres**. Il faut **déployer l'ensemble du package** et éventuellement envoyer des scripts à la base de données.

#### Les dépendances dans Bookinfo

- La **product page** affiche les informations, les reviews et les ratings du livre ;
- Toutes les données proviennent de **différents modules**, mais ils ne sont **pas conçus séparément** et **ne peuvent pas être scalés** individuellement ;
- Quand un client arrive sur la **product page** :
  - la product page récupère les infos auprès des services **reviews** et **details** ;
  - le service **Review** récupère le nombre de ratings depuis le service **Ratings**.

#### Les limites du monolithe illustrées

- Tous les modules sont écrits dans le **même langage (Java)** ;
- En plus des modules, l'application gère aussi : le **networking**, l'**authentification**, les **règles d'authorization**, le **transfert de données** entre modules, le **logging**, le **monitoring** et le **tracing** ;
- **Problème de scaling** : si le module **ratings** a un problème à cause de la quantité de données, cela **affecte tout le système**. Il n'est **pas possible** de simplement scaler `ratings` seul ou de le retirer **sans toucher au code et redéployer** ;
- **Problème de flexibilité technologique** : si une nouvelle équipe veut développer un module avec un **langage différent**, c'est difficile car tout est **unifié** et que les fonctionnalités importantes (comme l'**authorization**) se trouvent dans le monolith → dur à changer l'architecture ;
- **Problème de versions** : si les product owners veulent tester une **nouvelle version de reviews** (ex. avec des étoiles rouges pour Noël) sur un **segment d'utilisateurs**, ce n'est **pas possible** de déployer l'application entière en **deux versions différentes**.

### Le Big Ball of Mud (Grosse boule de boue)

Sur de **très grandes applications** existant depuis des décennies, avec des **centaines de développeurs** et des **règles d'architecture souples**, ces systèmes peuvent devenir un **« big ball of mud »** (une grosse boule de boue) — un concept célèbre pour ce type de systèmes logiciels. Sans s'en rendre compte, une application monolithique peut devenir **incontrôlable** et se transformer en l'un d'eux.

### La transformation en microservices

**Refactorer** des monolithes n'est **pas une tâche facile**, ni une transformation qui se fait **du jour au lendemain**. C'est un effort **culturel, technique et organisationnel** qui ouvre la voie au **cloud-native**.

Avec l'architecture **microservices**, chaque module devient sa **propre application, indépendante et séparée**.

#### Bookinfo transformé en microservices

- **product page** → transformée en app **Python** (sert toujours de landing page) ;
- **book details** → refactoré en app **Ruby** ;
- **reviews** → transformé en app **Java** ;
- **ratings** → redessiné et implémenté en **Node.js**.

De plus, l'app **reviews** a maintenant **plusieurs versions** pour tester différentes idées :
- **v1** : version **sans étoile** ;
- **v2** : version avec **étoiles noires** ;
- **v3** : version avec **étoiles rouges**.

Comme avant, les utilisateurs arrivent sur la product page, qui contacte les services **details** et **reviews** pour afficher les infos.

### Les bénéfices des microservices

- **Scaling indépendant** : le module `ratings` étant totalement indépendant, on peut le **scale up ou down** selon la charge des clients ;
- **Déploiement indépendant** : on peut déployer chaque partie de Bookinfo **sans interférer avec les autres** → releases plus **petites, plus rapides et moins risquées** ;
- **Liberté technologique** : chaque service peut être écrit dans un **langage différent** (ici, 4 langages différents), et chaque équipe a son **autonomie** ;
- **Résilience** : les services sont **isolés des pannes** des autres grâce au **loose coupling (couplage faible)** → l'application de bout en bout est **plus résiliente** ;
- **Opérations facilitées** : les différentes parties peuvent être **monitorées, modifiées ou rolled back facilement**.

> **Principe idéal** : au lieu d'une seule grosse application, on en a **six plus petites**. Dans un scénario idéal, un microservice devrait avoir une **seule responsabilité**.

### Le nouveau problème : les Cross-Cutting Concerns

Rappel : le monolithe gérait aussi le **networking**, l'**authentification**, les **règles d'authorization**, le **transfert de données**, le **logging** et le **monitoring**. **Où sont passées ces fonctionnalités** dans le modèle microservices ? **Elles ne sont plus là** ! Les microservices n'implémentent **rien de tout ça** par défaut.

Si on veut les ajouter, il faudrait les **intégrer dans chacun** des microservices → et là surgit le problème :
- **Chaque microservice** doit **réimplémenter les mêmes fonctionnalités** encore et encore ;
- **Chaque équipe** doit résoudre les **mêmes problèmes**, probablement de **manière différente** → **duplication du code** ;
- Difficile de coordonner : comment demander à toutes les équipes de changer un **certificat** ou une **version d'agent de monitoring** ?
- Tout développeur devra connaître tous ces **composants supplémentaires**, en plus de la **core business logic** que le microservice est censé assurer.

**Définition** : ces problèmes à gérer dans chaque microservice sont appelés **cross-cutting concerns** (préoccupations transversales). Lorsqu'ils sont codés dans le microservice, ils vont **à l'encontre de la raison d'être** des microservices (avoir des composants **petits et indépendants**). C'est ce qu'on appelle le **problème des « fat microservices »** (microservices obèses).

### Les microservices ne sont pas que du plaisir

Ils ont leurs **propres défis** et tendent à devenir **très complexes** :
- Dans le monolithe, le **networking** et la **security** étaient codés **directement** dans l'application. Maintenant, toutes ces zones d'ombre **intégrées** dans le monolithe sont **exposées** et doivent être **gérées** ;
- Comment la **product page** saura-t-elle vers **quelle version de reviews** se diriger ? Comment un service **en trouvera-t-il un autre** ? Quelles sont les **traffic rules** ? Quels sont les **timeouts** ?
- Avec **trop de petits services éparpillés**, il devient **beaucoup plus difficile** de répondre à ces questions ;
- **Securité** : c'était bien plus simple à gérer dans le monolithe. Assurer une bonne securité entre microservices, sécuriser la communication **service-to-service** et **user-to-service** de bout en bout devient un **problème en soi** ;
- **Observabilité** : avec de petits morceaux **loosely coupled** et de **nombreuses couches d'abstraction**, il devient difficile de **pinpoint (localiser)** un problème → besoin d'une **stratégie d'observabilité** ;
- **Opérations** : même pour une petite app, on a utilisé 4 langages et diverses technologies → les **opérations traditionnelles deviennent très exigeantes**.

### La solution organisationnelle : DevOps

Les opérations peuvent devenir un **bottleneck** pour les organisations qui adoptent les microservices. Il existe une nouvelle approche pour cela appelée **DevOps**, où les équipes de **développement travaillent étroitement avec les opérations** et **assument ensemble** la responsabilité de leurs microservices pour le **deploiement, le monitoring et le fixing**.

### Exemple de manifest illustratif (microservices)

Voici comment les 4 microservices de Bookinfo pourraient être déployés (chacun indépendamment) :

```yaml
# Microservice "ratings" (Node.js) — scalable indépendamment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ratings
  labels:
    app: ratings
spec:
  replicas: 3   # scale up/down indépendant des autres services
  selector:
    matchLabels:
      app: ratings
  template:
    metadata:
      labels:
        app: ratings
    spec:
      containers:
        - name: ratings
          image: bookinfo/ratings:nodejs-v1
          ports:
            - containerPort: 9080
---
# Microservice "reviews" (Java) — plusieurs versions (v1, v2, v3)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reviews-v3
  labels:
    app: reviews
    version: v3   # version avec étoiles rouges
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reviews
      version: v3
  template:
    metadata:
      labels:
        app: reviews
        version: v3
    spec:
      containers:
        - name: reviews
          image: bookinfo/reviews:java-v3
          ports:
            - containerPort: 9080
```

Ce manifest illustre deux bénéfices clés : le **scaling indépendant** (`replicas` propre à `ratings`) et le **versioning** (`version: v3` pour `reviews`), impossibles dans le monolithe.

### À retenir (synthèse)

- **Monolithe** : toutes les fonctionnalités **déployées ensemble**, **tightly coupled**, **même code base**, **une seule DB** → risque global, scaling impossible par module, rigidité technologique. Risque de devenir un **« big ball of mud »**.
- **Microservices** : chaque module = app **indépendante et séparée** → **scaling indépendant**, **déploiement indépendant**, **liberté de langage**, **résilience** (loose coupling), **versions multiples** possibles.
- **Nouveau problème** : les **cross-cutting concerns** (networking, sécurité, auth, logging, monitoring…) doivent être **réimplémentés dans chaque service** → duplication, complexité, **« fat microservices »**.
- Défis des microservices : **service discovery**, **traffic rules**, **timeouts**, **sécurité service-to-service**, **observabilité**, **opérations complexes**.
- Réponses à ces défis : culturellement le **DevOps** (dev + ops ensemble) — et techniquement le **service mesh** (avec Envoy/Istio) qui externalise les cross-cutting concerns hors du code applicatif.

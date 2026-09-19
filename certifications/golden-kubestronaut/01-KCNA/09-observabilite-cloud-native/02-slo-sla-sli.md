# SLO - SLA - SLI

Pour concevoir un système robuste, les équipes doivent définir des **objectifs clairs et mesurables**. Ces cibles permettent :
- d'équilibrer le **développement produit** et le **travail opérationnel** ;
- de donner aux clients une **attente concrète** de la fiabilité du service.

**Exemple** : une application peut être tenue de délivrer un minimum de **97% d'uptime** sur une période glissante de **30 jours**.

### SLI – Service Level Indicator

Un **SLI** est une **métrique quantitative** évaluant un aspect spécifique de la performance du service. En clair, il **mesure** à quel point un service fonctionne bien, selon des indicateurs clés.

**SLI courants** :
- **Request latency** (latence des requêtes) ;
- **Error rates** (taux d'erreur) ;
- **Saturation / throughput** (saturation / débit) ;
- **Availability** (disponibilité, ex. 99% d'uptime).

> **Point crucial** : **toutes les métriques ne sont PAS des SLI**. Les SLI les plus efficaces **reflètent au plus près l'expérience utilisateur**. Par exemple :
- une **charge CPU** ou une **consommation mémoire** élevée est un souci **technique**, mais ne dégrade pas forcément l'expérience utilisateur ;
- en revanche, le **temps de réponse** et les **taux d'erreur** sont de **meilleurs indicateurs** de la qualité perçue par le client.

### SLO – Service Level Objective

Un **SLO** représente la **valeur cible** (ou la plage acceptable) pour un SLI. C'est l'**objectif mesurable** aligné sur l'expérience client.

**Exemples** :
- Si le SLI est la **latence** → le SLO pourrait être « maintenir la latence **sous 100 ms** » ;
- Un SLO de **disponibilité** pourrait exiger **99,9% d'uptime**.

> **Attention (point important)** : viser des cibles **extrêmement élevées** (100% ou 99,999% d'uptime) mène souvent à des **coûts inutiles** sans bénéfice significatif pour les clients. Il faut trouver le bon équilibre.

### SLA – Service Level Agreement

Un **SLA** est un **contrat formel** entre un fournisseur (vendor) et un utilisateur, qui **s'engage à respecter un SLO spécifique**.
- Les SLA sont généralement **juridiquement contraignants (legally binding)** ;
- Le **non-respect** des cibles convenues peut entraîner des **pénalités financières** ou d'autres mesures correctives.

### La relation SLI → SLO → SLA (récapitulatif clé)

| Terme | Rôle | Exemple |
|-------|------|---------|
| **SLI** (Indicator) | **Mesure** la qualité du service (métrique) | Latence = 80 ms |
| **SLO** (Objective) | Fixe la **cible** pour le SLI | Latence < 100 ms |
| **SLA** (Agreement) | **Formalise** la cible dans un **contrat** contraignant | Contrat garantissant 99,9% d'uptime, pénalités sinon |

**La logique** : le SLI **mesure**, le SLO **fixe l'objectif**, le SLA **engage contractuellement**.

### À retenir

- **SLI (Service Level Indicator)** = **métrique** quantitative mesurant la qualité du service ; les bons SLI reflètent l'**expérience utilisateur** (latence, erreurs) plutôt que des métriques purement techniques (CPU, mémoire).
- **SLO (Service Level Objective)** = **valeur cible** pour un SLI (ex. latence < 100 ms, 99,9% uptime) ; éviter les cibles trop élevées (coûteuses et peu utiles).
- **SLA (Service Level Agreement)** = **contrat** formel et **juridiquement contraignant** garantissant un SLO, avec **pénalités** en cas de non-respect.
- Ensemble : **SLI mesure → SLO cible → SLA engage** → ils assurent un service cohérent et de qualité.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Docker Hub : https://hub.docker.com/


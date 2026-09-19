# Gestion des coûts

**Analogie** : gérer un business dans le cloud avec diverses ressources (VM, volumes de stockage, services web) qui alimentent chacune la **facture mensuelle**, c'est comme laisser des lumières allumées chez soi → cela augmente la facture d'électricité. Il faut donc **surveiller et gérer** ces dépenses avec soin.

**Le concept (point essentiel)** : la **gestion des coûts cloud** consiste à **planifier et organiser** les dépenses liées aux technologies cloud. En **scalant les ressources up et down** selon les besoins (comme éteindre les lumières inutilisées), on **optimise l'utilisation** et **contrôle les coûts**. C'est crucial avec le modèle **pay-for-what-you-use (payer à l'usage)** des cloud providers.

> **Sans supervision**, les dépenses peuvent **exploser** — comme laisser la climatisation à fond avec les fenêtres ouvertes.

### 1. Choisir l'infrastructure appropriée

La plupart des cloud providers offrent **trois catégories d'instances** (serveurs virtuels), chacune avec son modèle de prix :

| Type d'instance | Caractéristiques | Réduction |
|-----------------|------------------|-----------|
| **On-demand** | Flexibilité maximale (créer/supprimer à volonté), mais **coûteux** | Aucune (prix plein) |
| **Reserved** | **Réduction** en échange d'un **engagement long terme** | ~**30%+** de réduction |
| **Spot** | Le plus **économique** (utilise la capacité inutilisée), mais peut être **terminé brutalement** si le provider a besoin de la capacité | Jusqu'à **90%** de réduction |

**Détails** :
- **On-demand** : idéal pour la flexibilité, mais le plus cher ;
- **Reserved** : ex. KodeKloud engage un contrat long terme pour ses labs → **30%+ de réduction** ;
- **Spot** : jusqu'à **90% de réduction**, mais **interruptible** ; certains providers offrent des **signaux de rééquilibrage (capacity rebalancing)** pour alerter, sans garantie de préavis suffisant.

### 2. Rightsizing : équilibrer performance et coût

Il faut un **équilibre optimal** entre performance et coût :
- **Over-provisioning** (sur-provisionnement) → **dépenses inutiles** ;
- **Under-provisioning** (sous-provisionnement) → **problèmes de performance**.

**La solution : l'autoscaling**. Kubernetes permet de scaler **automatiquement** applications et infrastructure selon la demande :
- Définir des **node pools** avec des **limites hautes et basses** ;
- Le scaling dynamique garantit que **seules les ressources nécessaires** sont actives → évite le gaspillage ;
- Les systèmes cloud peuvent **allouer et libérer** des volumes de stockage externes à la demande.

> **Point clé** : définir des **limites optimales** (upper/lower limits) et sélectionner les **bonnes métriques de performance** est crucial pour un autoscaling efficace et pour prévenir l'over-provisioning.

### 3. Planifier l'extinction et supprimer les ressources inutilisées

Toutes les ressources n'ont **pas besoin de tourner en continu** :
- **Scheduling** : programmer l'**extinction** des ressources non essentielles pendant les **heures non ouvrées** ou les **week-ends** → économies significatives ;
- **Nettoyage régulier** : réviser régulièrement l'infrastructure pour **supprimer les instances inutilisées**. Les ressources inactives augmentent non seulement les coûts, mais peuvent aussi introduire des **risques de sécurité**.

### Les outils de gestion des coûts

**Outils natifs des cloud providers** :
- **AWS Cost Explorer** (AWS) ;
- **Azure Cost Management and Billing** (Azure).

**Outils tiers** :
- **Harness**, **Kubecost**, **Cloudability**, **Densify**, **CloudZero**.

### À retenir

- La **gestion des coûts** cloud = planifier et optimiser les dépenses sous le modèle **pay-for-what-you-use** (scaler up/down selon les besoins).
- **3 types d'instances** : **On-demand** (flexible, cher), **Reserved** (engagement → ~30% de réduction), **Spot** (jusqu'à 90% de réduction, mais interruptible).
- **Rightsizing** : éviter l'**over-provisioning** (gaspillage) et l'**under-provisioning** (perf) via l'**autoscaling** et des **node pools** aux limites bien définies.
- **Scheduling** : éteindre les ressources non essentielles (nuits, week-ends) et **supprimer les ressources inutilisées** (coûts + sécurité).
- **Outils** : natifs (AWS Cost Explorer, Azure Cost Management) et tiers (Kubecost, Harness, Cloudability, Densify, CloudZero).

### Liens utiles

- AWS Cost Explorer : https://aws.amazon.com/aws-cost-management/aws-cost-explorer/
- Azure Cost Management and Billing : https://azure.microsoft.com/en-us/services/cost-management/
- Kubecost : https://kubecost.com
- Harness : https://harness.io
- Cloudability : https://www.apptio.com/products/cloudability
- Densify : https://www.densify.com
- CloudZero : https://www.cloudzero.com

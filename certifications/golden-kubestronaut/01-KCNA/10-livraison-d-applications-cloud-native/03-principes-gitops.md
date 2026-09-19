# Principes GitOps

**le besoin d'une gouvernance**

Quand une nouvelle technologie émerge, des débats sur sa **gouvernance** et ses **principes fondamentaux** sont inévitables. Un **organe de gouvernance dédié** aide à définir des standards et garantit un développement **impartial et communautaire (community-driven)**.

**Exemple** : Kubernetes est guidé par la **CNCF (Cloud Native Computing Foundation)**, qui maintient son éthos **vendor-neutral** et communautaire.

### L'OpenGitOps project et la GitOps Working Group

Pour assurer **clarté et cohérence** dans les pratiques GitOps, la CNCF a formé la **GitOps Working Group**, sous son **App Delivery Special Interest Group (SIG)**. Ce groupe vise à :
- définir une compréhension **vendor-neutral** de GitOps ;
- établir un **langage commun** pour la communauté.

> Vendor = fournisseur, éditeur, acteur proposant un produit ou service.
> Vendor-neutral = qui ne privilégie ni ne dépend d'un fournisseur particulier.

La GitOps Working Group a lancé le **projet OpenGitOps**, unissant experts et parties prenantes pour **standardiser les bonnes pratiques**. Ce projet est une étape fondatrice favorisant la **collaboration et l'interopérabilité** entre la communauté open source, les fournisseurs (vendors) et les organisations utilisatrices (end-users).

### Les 4 principes fondamentaux de GitOps

Après de nombreuses discussions, le projet OpenGitOps a défini GitOps via **quatre principes fondamentaux** :

#### 1. Le système entier doit être défini de manière déclarative

Tout le système doit être décrit de façon **déclarative**. Dans Kubernetes, l'**état désiré** est spécifié via des **fichiers YAML** plutôt que par des commandes manuelles. Ces YAML décrivent les réglages essentiels : **images de conteneurs, nombre de replicas, types de service** et autres configurations → ils décrivent **directement l'état voulu** du système.

#### 2. L'état désiré définitif est maintenu dans Git

Après avoir commité la configuration désirée (fichier YAML) dans **Git**, elle devient **versionnée**, permettant :
- le **suivi des changements** dans le temps ;
- le **retour facile** à des versions antérieures.

> **Point important** : une fois appliqué au cluster, le YAML est traité comme **immuable** ; les mises à jour se font en **créant une nouvelle version**, pas en modifiant l'actuelle.

#### 3. Les changements approuvés sont automatiquement propagés au système

Des outils comme **Flux** ou **Argo CD** surveillent en continu le dépôt Git. Quand des changements sont poussés, ces outils **détectent** la nouvelle config et l'**appliquent automatiquement** au cluster.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
```
→ Cette automatisation **minimise l'intervention manuelle**, accélère les déploiements, améliore la fiabilité et réduit les erreurs.

#### 4. Les outils GitOps surveillent en continu et corrigent les divergences

Même **après le déploiement**, les outils GitOps **surveillent constamment** le cluster pour garantir que son **état réel correspond à l'état désiré** défini dans Git. En cas de **divergence** (ex. si le nombre de replicas est changé manuellement), l'outil GitOps prend **rapidement des mesures correctives** pour restaurer la configuration voulue.

### Récapitulatif des 4 principes

| # | Principe | Idée clé |
|---|----------|----------|
| **1** | **Déclaratif** | Le système entier décrit via YAML (état désiré, pas de commandes manuelles) |
| **2** | **Versionné dans Git** | Git = source de vérité ; état **immuable**, mises à jour = nouvelles versions |
| **3** | **Propagation automatique** | Flux/Argo CD appliquent automatiquement les changements approuvés |
| **4** | **Réconciliation continue** | Surveillance permanente + **correction automatique** des divergences |

### À retenir

- La **CNCF** a créé la **GitOps Working Group** (sous l'App Delivery SIG) et le projet **OpenGitOps** pour standardiser GitOps de façon **vendor-neutral**.
- **4 principes fondamentaux** de GitOps :
  1. **Déclaratif** : tout le système décrit en YAML (état désiré) ;
  2. **Versionné dans Git** : Git = source de vérité, état **immuable** (nouvelles versions) ;
  3. **Propagation automatique** : les outils (Flux, Argo CD) appliquent les changements approuvés ;
  4. **Réconciliation continue** : surveillance permanente + **correction auto** des divergences.
- Ces principes assurent un **état cohérent et fiable**, une **efficacité opérationnelle** accrue et l'**intégrité** du système.

### Liens utiles

- Projet OpenGitOps : https://opengitops.dev/

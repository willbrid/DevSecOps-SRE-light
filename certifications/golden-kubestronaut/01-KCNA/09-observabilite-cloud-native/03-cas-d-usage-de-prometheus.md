# Cas d'usage de Prometheus

Ce contenu explore plusieurs **cas d'usage de Prometheus**, illustrant ses applications pratiques dans le **monitoring d'infrastructure moderne**.

### 1. Agrégation unifiée des métriques (Unified Metrics Aggregation)

**Le défi** : les organisations avec **plusieurs data centers** et services cloud (ex. AWS) peinent à monitorer des environnements distribués.

**Scénario** : une entreprise avec des data centers dans les régions **West, Central et East**, plus des services cloud. L'objectif est d'**agréger les métriques** de ces sources diverses et de les présenter dans un **dashboard unique** et lisible.

**La solution** : Prometheus est conçu pour **scraper (collecter) les métriques** depuis diverses localisations (on-premises ou cloud), et fournit des **utilitaires de dashboarding intégrés** pour afficher les données dans une **vue consolidée**.

### 2. Alerting proactif pour la santé des serveurs (Proactive Alerting)

**Scénario** : un serveur de base de données MySQL connaît une **utilisation mémoire élevée**, pouvant mener à des pannes. L'équipe ops doit être **alertée** quand la consommation atteint un niveau critique (ex. **80% d'utilisation**) pour **intervenir avant** que les utilisateurs ne soient impactés.

**La solution** : Prometheus offre des **mécanismes d'alerting intégrés**. Quand une métrique dépasse un **seuil prédéfini (threshold)**, il déclenche des notifications via divers canaux : **email, Slack, SMS**.

**Pour configurer l'alerting** (3 étapes) :
1. Définir les **requêtes de métriques** dans Prometheus ;
2. Définir les **règles de seuil (threshold rules)** ;
3. **Intégrer** avec vos systèmes de notification préférés.

### 3. Analyse de performance des nouvelles fonctionnalités (Performance Analysis)

**Scénario** : lors de l'introduction d'une nouvelle fonctionnalité (ex. **upload de vidéos**), le monitoring des performances devient crucial. Si les uploads de gros fichiers augmentent la **latence**, il faut déterminer à partir de **quelle taille de fichier** la performance se dégrade significativement.

**La solution** : en collectant des métriques sur la **taille moyenne des fichiers** ET la **latence des requêtes**, Prometheus permet de **corréler** ces valeurs et d'identifier le **seuil** où les problèmes apparaissent. Ses outils de **visualisation** représentent graphiquement cette analyse, soutenant l'optimisation.

### Récapitulatif des capacités de Prometheus

| Capacité | Description |
|----------|-------------|
| **Aggregated Metrics Display** | Collecte les métriques de data centers distribués et de services cloud dans un **dashboard unifié** |
| **Proactive Alerting** | Surveille les KPI et déclenche des **alertes** pour prévenir les pannes |
| **Feature Performance Analysis** | Analyse l'impact des **nouvelles fonctionnalités** sur la performance |

> Prometheus permet de maintenir une infrastructure **fiable et performante** en identifiant et traitant **proactivement** les problèmes potentiels.

### À retenir

- **Prometheus** = outil polyvalent de monitoring, centré sur les **métriques**, avec **3 cas d'usage clés** :
  1. **Agrégation unifiée** : scraper les métriques de sources diverses (on-prem + cloud) dans un **dashboard unique** ;
  2. **Alerting proactif** : notifications (email/Slack/SMS) quand une métrique dépasse un **seuil** (ex. MySQL à 80% de mémoire) → prévenir les pannes ;
  3. **Analyse de performance** : corréler des métriques (ex. taille de fichier ↔ latence) pour localiser les seuils de dégradation.
- Configurer l'alerting = **requêtes** + **règles de seuil** + **intégration notifications**.

### Liens utiles

- Documentation Prometheus : https://prometheus.io/docs/
- Bonnes pratiques de monitoring (Datadog) : https://www.datadoghq.com/

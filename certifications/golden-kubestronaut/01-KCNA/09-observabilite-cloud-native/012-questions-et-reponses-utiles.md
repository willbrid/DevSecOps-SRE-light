# Questions et réponses utiles

Voici quelques points clés à retenir, organisés par thème.

### Observabilité

- **Un des bénéfices clés de l'observabilité dans les environnements dynamiques** : des **sorties exploitables (actionable outputs)** à partir de scénarios inattendus.

### Logging

- **Composants essentiels d'une entrée de log** (plusieurs réponses) :
  - le **timestamp** (horodatage) indiquant quand le log s'est produit ;
  - un **message** contenant l'information.

### SLI, SLO et SLA

- **Objectif principal d'un SLO (Service Level Objective)** dans le contexte de la fiabilité : **quantifier la fiabilité** d'un produit vis-à-vis d'un client.
- **Ce que représente la valeur du SLO** (dans les exemples SLI/SLO donnés) : la **latence maximale autorisée** (the maximum allowable latency).

### Prometheus et modèles de collecte

- **Systèmes de monitoring reposant sur un modèle push-based** : **Logstash et Graphite**.
- **Composant de Prometheus responsable du stockage des métriques** collectées dans une base de séries temporelles : la **Time Series Database (TSDB)**.
- **Bénéfice d'un système de monitoring pull-based** : la **gestion centralisée des configurations des targets** (registre centralisé des cibles).

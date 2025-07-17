# Introduction à alertmanager

**Alertmanager** est une application qui s'exécute dans un processus distinct du serveur prometheus. Il est responsable de la gestion des alertes qui lui sont envoyées par des clients tels que le serveur prometheus.

Les alertes sont des notifications déclenchées automatiquement par les données de métrique.

Par exemple : un serveur tombe en panne, et l'administrateur d'astreinte reçoit automatiquement un email l'informant du problème afin qu'il puisse agir.

**Alertmanager** effectue les opérations suivantes :
- dédupliquer des alertes lorsque plusieurs clients envoient la même alerte
- regrouper plusieurs alertes lorsqu'elles se produisent à peu près au même moment
- acheminer les alertes vers la bonne destination, par exemple par e-mail ou par une autre application d'alerte telle que pageDurty ou opsGenie

**Alertmanager** ne crée pas d'alertes et ne détermine pas quand les alertes doivent être envoyées en fonction des données métriques. Prometheus gère cette étape et transmet les alertes résultantes à **Alertmanager**.
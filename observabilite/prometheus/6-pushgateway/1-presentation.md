# Introduction à Pushgateway

Le serveur prometheus utilise une méthode d'extraction pour collecter des métriques, ce qui signifie que prometheus contacte les exportateurs pour extraire des données. Les exportateurs ne contactent pas prometheus.
<br>
Cependant, il existe certains cas d'utilisation où une méthode push est nécessaire, comme la surveillance des processus de job par lots.
<br>
Prometheus **pushgateway** sert d'intermédiaire pour ces cas d'utilisation :

- les clients poussent les données métriques vers **pushgateway**
- le serveur prometheus extrait les métriques de **pushgateway**, comme n'importe quel autre exportateur.

## Quand utiliser pushgateway
La documentation prometheus recommande d'utiliser pushgateway uniquement pour des cas d'utilisation très spécifiques.Celles-ci impliquent généralement des jobs par lots au niveau du service. Le processus d'un job par lots se termine lorsque le traitement est terminé. Il est incapable de fournir des métriques une fois la tâche terminée. Il ne devrait pas être nécessaire d'attendre un scrap du serveur prometheus pour fournir des métriques; par conséquent, ces jobs ont besoin d'un moyen de pousser les métriques au moment approprié.

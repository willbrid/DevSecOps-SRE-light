# Télémétrie et observabilité

Les environnements de microservices peuvent inclure des dizaines à des centaines de services, ce qui rend difficile la détermination des chemins de requête et le diagnostic des problèmes. Et les charges de surveillance des performances des applications (APM) ne font qu'augmenter avec l'orchestration, l'automatisation et la CI/CD pour les déploiements logiciels fréquents. Sans l'instrumentation de surveillance appropriée, les organisations risquent que leurs équipes aient à rechercher des réponses dans des systèmes distribués à plusieurs reprises, ce qui augmente le temps moyen de résolution (MTTR) et prend du temps pour le développement de logiciels innovants.
<br>
L'**observabilité** réduit la complexité des logiciels et offre une visibilité de bout en bout qui permet aux équipes de résoudre les problèmes plus rapidement, de travailler plus intelligemment et de créer de meilleures expériences numériques pour leurs clients. L'**observabilité** crée des informations contextuelles et exploitables, entre autres, en combinant quatre types essentiels de données d'**observabilité** : les **métriques**, les **événements**, les **journaux** et les **traces** (MELT).
<br><br>
Les traces, plus précisément les traces distribuées, sont essentielles pour les équipes logicielles qui ont migré (ou envisagent de migrer) vers le cloud et ont adopté des architectures de microservices. En effet, le traçage distribué est le meilleur moyen de comprendre rapidement ce qu'il advient des requêtes lorsqu'elles transitent par les microservices qui composent les applications distribuées.
<br>
Les chefs d'entreprise, les ingénieurs DevOps, les propriétaires de produits, les ingénieurs de fiabilité du site (SRE), les chefs d'équipe logicielle ou d'autres parties prenantes peuvent utiliser le traçage distribué pour trouver les goulots d'étranglement ou les erreurs et obtenir un avantage grâce à un dépannage plus rapide.
<br><br>
Le traçage distribué est désormais un enjeu majeur pour l'exploitation et la surveillance des environnements applicatifs modernes. Lorsque les équipes surveillent les performances des logiciels et des systèmes pour l'observabilité, le traçage est un moyen de surveiller et d'analyser les demandes à mesure qu'elles se propagent dans un environnement distribué et passent d'un service à l'autre.
<br>
Le traçage distribué est la capacité de tracer une solution pour suivre et observer les demandes de service lorsqu'elles transitent par des systèmes distribués en collectant des données au fur et à mesure que les demandes passent d'un service à un autre. Les données de trace aident les équipes à comprendre le flux de demandes dans l'environnement de microservices et à identifier où les pannes ou les problèmes de performances se produisent dans le système, et pourquoi.
<br>
Lorsque les équipes instrumentent les systèmes pour le traçage distribué, toutes les transactions génèrent une **télémétrie de traçage**, de l'utilisateur frontal aux appels de la base de données principale. Par exemple, lorsque les clients cliquent sur un panier pour effectuer un achat dans une application de commerce électronique, cette demande transite par plusieurs services frontend et backend distincts sur plusieurs conteneurs, environnements sans serveur, machines virtuelles, différents fournisseurs de cloud, sur site (on- prem), ou toute combinaison de ceux-ci. La demande peut inclure le service d'inventaire pour s'assurer que l'inventaire est disponible, le service de paiement et le service d'expédition. Et finalement, la demande se termine et revient à l'utilisateur. Chaque fois qu'une requête saute d'un service à un autre, elle émet un **span** avec télémétrie de traçage. Une fois la demande terminée, les délais sont assemblés pour créer une trace complète du parcours de la demande dans le système.

- Commande pour obtenir les journaux d'un conteneur

```
kubectl logs nom_pod -c nom_conteneur
```

- **Trace** : un ensemble d'événements liés sur plusieurs composants.
- **Span** : données sur un seul composant dans une trace.

[https://kubernetes.io/docs/reference/kubectl/cheatsheet/](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

[https://newrelic.com/resources/ebooks/quick-introduction-distributed-tracing](https://newrelic.com/resources/ebooks/quick-introduction-distributed-tracing)
# Introduction à Prometheus

**Prometheus** est un outil qui nous permet de collecter des données métriques pour les applications et les systèmes.
<br>
**Grafana** : un outil qui peut être utilisé pour créer des visualisations d'utilisation des données Prometheus.

Les différents types de métrique Prometheus :
- **compteur** 

C'est une métrique cumulative qui représente un seul compteur croissant de façon monotone dont la valeur ne peut qu'augmenter ou être remise à zéro au redémarrage. Par exemple, nous pouvons utiliser un **compteur** pour représenter le nombre de demandes traitées, de tâches terminées ou d'erreurs.
<br>
N'utilisons pas de compteur pour exposer une valeur qui peut diminuer. Par exemple, n'utilisons pas de compteur pour le nombre de processus en cours d'exécution ; utilisons plutôt une jauge.

- **jauge** 

C'est une métrique qui représente une valeur numérique unique qui peut monter et descendre arbitrairement.
<br>
Les jauges sont généralement utilisées pour les valeurs mesurées telles que les températures ou l'utilisation actuelle de la mémoire, mais également pour les "comptes" qui peuvent monter et descendre, comme le nombre de requêtes simultanées.

- **histogramme**

C'est une métrique qui échantillonne les observations (généralement des éléments tels que la durée des requêtes ou la taille des réponses) et les compte dans des compartiments configurables. Il fournit également une somme de toutes les valeurs observées.
<br>
Un histogramme avec un nom de métrique de base <basename> expose plusieurs séries temporelles lors d'un scraping : <br>

--- compteurs cumulatifs pour les buckets d'observation, exposés en tant que <basename>_bucket{le="<limite inclusive supérieure>"} <br>
--- la somme totale de toutes les valeurs observées, exposées sous la forme <basename>_sum <br>
--- le nombre d'événements qui ont été observés, exposés en tant que <basename>_count (identique à <basename>_bucket{le="+Inf"} ci-dessus)

- **Résumé**

Semblable à un histogramme, un résumé échantillonne des observations (généralement des éléments tels que la durée des requêtes et la taille des réponses). Bien qu'il fournisse également un nombre total d'observations et une somme de toutes les valeurs observées, il calcule des quantiles configurables sur une fenêtre temporelle glissante.
<br>
Un récapitulatif avec un nom de métrique de base <basename> expose plusieurs séries temporelles lors d'un scraping : <br>

--- flux φ-quantiles (0 ≤ φ ≤ 1) des événements observés, exposés sous la forme <basename>{quantile="<φ>"} <br>
--- la somme totale de toutes les valeurs observées, exposées sous la forme <basename>_sum <br>
--- le nombre d'événements observés, exposés sous la forme <basename>_count

[https://prometheus.io/docs/concepts/metric_types/](https://prometheus.io/docs/concepts/metric_types/)
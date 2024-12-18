# Qu'est-ce qu'OpenSearch ?

**OpenSearch** est un moteur de recherche et d'analyse distribué basé sur Apache Lucene. Après avoir ajouté vos données à **OpenSearch**, nous pouvons y effectuer des recherches en texte intégral avec toutes les fonctionnalités auxquelles nous pourrions nous attendre : recherche par champ, recherche dans plusieurs index, amplification des champs, classement des résultats par score, tri des résultats par champ et agrégation des résultats.

Sans surprise, les gens utilisent souvent des moteurs de recherche comme **OpenSearch** comme backend pour une application de recherche, comme Wikipedia ou une boutique en ligne. Il offre d'excellentes performances et peut évoluer à mesure que les besoins de l'application augmentent ou diminuent.

Un cas d'utilisation tout aussi populaire, mais moins évident, est l'analyse des journaux, dans laquelle nous prenons les journaux d'une application, les alimentons dans **OpenSearch** et utilisons la fonctionnalité de recherche et de visualisation enrichie pour identifier les problèmes. Par exemple, un serveur Web défectueux peut générer une erreur 500 0,5 % du temps, ce qui peut être difficile à remarquer à moins que nous n'ayons un graphique en temps réel de tous les codes d'état HTTP que le serveur a générés au cours des quatre dernières heures. Nous pouvons utiliser les tableaux de bord **OpenSearch** pour créer ces types de visualisations à partir de données dans **OpenSearch**.

### Composants

**OpenSearch** est bien plus que le moteur principal. Il comprend également les composants suivants :

- **Tableaux de bord OpenSearch** : l'interface utilisateur de visualisation des données OpenSearch.
- **Data Prepper** : un collecteur de données côté serveur capable de filtrer, d'enrichir, de transformer, de normaliser et d'agréger des données pour une analyse et une visualisation en aval.
- **Clients** : API de langage qui nous permettent de communiquer avec **OpenSearch** dans plusieurs langages de programmation courants.

### Cas d'utilisation

**OpenSearch** prend en charge une variété de cas d'utilisation, par exemple :

- **Observabilité** : visualiser les événements pilotés par les données en utilisant le langage PPL (Piped Processing Language) pour explorer, découvrir et interroger les données stockées dans OpenSearch.
- **Recherche** : choisir la meilleure méthode de recherche pour notre application, de la recherche lexicale classique à la recherche conversationnelle optimisée par l'apprentissage automatique (ML).
- **Apprentissage automatique** : intégrer des modèles ML dans notre application OpenSearch.
- **Analyse de sécurité** : étudier, détecter, analyser et répondre aux menaces de sécurité qui peuvent compromettre le succès de l'organisation et les opérations en ligne.

Source : [OpenSearch Doc](https://opensearch.org/docs)
# Réécriture des étiquettes

La **réécriture des étiquettes** permet de classer et de filtrer les cibles et les métriques Prometheus en réécrivant leur ensemble d'étiquettes.

Les directives de configuration permettant de faire la **réécriture des étiquettes** :

- **relabel_configs** : directive de **scrape_configs** utilisée avant le scraping pour modifier ou filtrer les étiquettes des cibles (**target**) détectées via la découverte de services.

- **metric_relabel_configs** : directive de **scrape_configs** utilisée après le scraping, pour modifier ou filtrer les étiquettes des métriques elles-mêmes, juste avant leur stockage.

- **write_relabel_configs** : directive de **remote_write** utilisée pour modifier ou filtrer les étiquettes des métriques elles-mêmes avant de les envoyer à un système de stockage distant.

- **alert_relabel_configs** : directive de **alerting** appliquée aux alertes avant de les envoyer à **Alertmanager** pour permettre la personnalisation du contenu et du routage des alertes.

### Règle de réécriture d'étiquettes

Une règle de réécriture d'étiquettes associée aux directives **relabel_configs|metric_relabel_configs|write_relabel_configs|alert_relabel_configs** est composée de plusieurs champs :

- **source_labels** : liste d’étiquettes (labels) à utiliser comme entrée pour la transformation. Son contenu est concaténé à l'aide du champ **separator** et comparé à l'expression régulière fournie via le champ **regex**

- **separator** : chaîne utilisée pour séparer les valeurs des éléments du champ **source_labels** (par défaut : **;**)

- **regex** : expression régulière utilisée pour faire correspondre la valeur combinée des éléments du champ **source_labels**. La valeur par défaut est **(.*)**, qui correspond à tout

- **target_label** : nom de l'étiquette à créer ou à modifier après transformation. Il est obligatoire pour l'action **replace**

- **replacement** : valeur utilisée pour remplacer les correspondances du **regex**

- **action** : action à effectuer en fonction de la correspondance **regex**

- **modulus** : pour l'action **hashmod**, cela spécifie le nombre de groupes pour les cibles ou les métriques.

### Valeurs possibles de la règle action

La règle **action** possède plusieurs valeurs :

- **replace** : il compare l'expression régulière à la valeur d'étiquettes source concaténées. Ensuite, il définit la valeur de l'étiquette cible avec la valeur du champ **replacement**, en substituant les références de groupe de correspondance (${1}, ${2}, ...) dans **replacement** par leur valeur. Si l'expression régulière ne correspond pas, aucun remplacement n'a lieu.

- **keep** : supprime les cibles pour lesquelles l'expression régulière ne correspond pas à la valeur des étiquettes source concaténées.

- **drop** : supprime les cibles pour lesquelles l'expression régulière correspond à la valeur des étiquettes étiquettes source concaténées.

- **labelmap** : renomme plusieurs étiquettes en fonction d’un motif **regex** et via la valeur du champ **replacement**.

- **labeldrop** : compare l'expression régulière à tous les noms d'étiquettes. Toute étiquette correspondante sera supprimée de l'ensemble des étiquettes.

- **labelkeep** : compare l'expression régulière à tous les noms d'étiquettes. Toute étiquette non correspondante sera supprimée de l'ensemble des étiquettes.

```
<relabel_configs|metric_relabel_configs|write_relabel_configs|alert_relabel_configs>:
  - source_labels: [label_name,...]
    separator: ;
    regex: <(.*)>
    target_label: label_name
    replacement: <$1>
    action: replace
    modulus: <int>
```
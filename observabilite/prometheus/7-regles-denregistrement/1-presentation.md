# Règles d'enregistrement

Les règles d'enregistrement nous permettent de pré-calculer les valeurs des expressions et des requêtes et d'enregistrer les résultats sous leur propre ensemble distinct de données de séries chronologiques.

Les règles d'enregistrement sont évaluées selon une planification, en exécutant une expression et en enregistrant le résultat en tant que nouvelle métrique.

Les règles d'enregistrement sont particulièrement utiles lorsque nous avons des requêtes complexes ou coûteuses qui sont exécutées fréquemment. Par exemple, en enregistrant des résultats précalculés à l'aide d'une règle d'enregistrement, l'expression n'a pas besoin d'être réévaluée chaque fois que quelqu'un ouvre un tableau de bord.

Les règles d'enregistrement sont configurées à l'aide de yaml. Créeons-les en plaçant les fichiers yaml à l'emplacement spécifié par **rule_files** dans **prometheus.yml**

Lors de la création ou de la modification des règles d'enregistrement, rechargeons leur configuration de la même manière que nous le ferions lors de la modification du fichier **prometheus.yml**.

**Exemple de configuration** :

```
groups:
- name: my_rule_group
  rules:
  - record: my_custom_metric
    expr: up{job="My Job"}
```
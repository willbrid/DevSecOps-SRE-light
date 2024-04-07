# Vérifier la qualité du code dans un pipeline CI/CD

La fonctionnalité **Code Quality** de Gitlab garantit que le code de notre projet respecte certaines normes de qualité. La fonctionnalité **Code Quality** s’appuie sur un service extérieur appelé **Code Climate**. Bien que ce service puisse analyser le code écrit dans tous les principaux langages informatiques, il ne peut pas gérer toutes les langues disponibles. Nous pouvons nous référer à la documentation officielle de **Code Climate** pour voir une liste des langues prises en charge (Lien: [https://docs.codeclimate.com/docs/supported-languages-for-maintainability](https://docs.codeclimate.com/docs/supported-languages-for-maintainability)).

Les catégories générales de problème gérées par cette fonctionnalité **Code Quality** incluent les **performances**, le **style**, la **complexité**, la **sécurité** et les **codes smell** (c'est-à-dire les modèles de code qui indiquent un risque élevé de bugs).

La fonctionnalité **Code Quality** est suffisamment intelligente pour détecter tous les langages informatiques utilisés dans notre projet GitLab et exécuter les scanners appropriés pour chaque langage.

### Activation de la fonctionnalité Code Quality

Nous activons la fonctionnalité **Code Quality** via le fichier **.gitlab-ci.yml** de notre projet **sortAndTotal**.

```
cd $HOME/sortAndTotal
```

```
vi .gitlab-ci.yml
```

```
variables:
  OUTPUT_NAME: __bin__/$CI_PROJECT_NAME

default:
  tags:
    - dev
    - linux

stages:
  - test
  - build

include:
  template: Code-Quality.gitlab-ci.yml

compilation:
  stage: build
  script:
    - mkdir -p $OUTPUT_NAME
    - go build -o $OUTPUT_NAME ./...
  artifacts:
    paths:
      - $OUTPUT_NAME
```

Nous avons inclus le template **Code-Quality.gitlab-ci.yml** natif à Gitlab au niveau global. Nous avons aussi défini les tags au niveau global afin qu'elle soit réutilisée automatiquement au niveau de chaque tâche.

Une fois le pipeline exécuté, la page de détails du pipeline comprendra un nouvel onglet appelé **Code Quality**, qui révèle les résultats de l'analyse de la qualité du code.
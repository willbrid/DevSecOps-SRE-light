# Comprendre la structure du pipeline CI/CD de GitLab [Part4]

Nous présentons ici comment configurer les pipelines GitLab CI/CD.

Toute la configuration du pipeline CI/CD s'effectue dans un fichier appelé **.gitlab-ci.yml**, qui se trouve à la racine du référentiel de notre projet.

Chaque fichier **.gitlab-ci.yml** utilise un langage spécifique au domaine composé de mots-clés, de valeurs et d'un peu de colle syntaxique. Certains mots-clés définissent des étapes (**stages**) et des tâches (**jobs**) au sein de ces étapes (**stages**). D'autres mots-clés configurent les tâches (**jobs**) pour qu'elles effectuent différentes choses au sein du pipeline. Néanmoins, d'autres mots-clés définissent des variables, spécifient des images Docker pour les tâches (**jobs**) ou affectent le pipeline global de diverses manières.

Il existe environ **30 mots-clés** disponibles à utiliser dans un fichier **.gitlab-ci.yml**. Plutôt que d'essayer de mémoriser les détails et les options de configuration disponibles pour chacun, il est recommandé de nous concentrer sur la vue d'ensemble de ce qui est possible avec les pipelines CI/CD, puis d'apprendre les nuances des mots-clés pertinents si nécessaire. La documentation officielle de GitLab est la meilleure source d'informations sur ces mots-clés, d'autant plus qu'ils changent de temps en temps.

Les fichiers **.gitlab-ci.yml** utilisent le format YAML pour les données structurées. La plupart des fichiers de configuration CI/CD commencent par définir les étapes du pipeline. Si nous ne définissons aucune étape, notre pipeline comportera par défaut des étapes (**stages**) de création (**build**), de test et de déploiement. Si nous définissons des étapes (**stages**), celles-ci remplaceront et non augmenteront les trois étapes (**stages**) par défaut.

Exemple de pipeline

```
stages:
  - build
  - test

image: python:3.10

data-type-check:
  stage: build
  script:
    - pip install mypy
    - mypy src/hats-for-cats.py

unit-tests:
  stage: test
  script:
    - pip install pytest
    - pytest test/ --junitxml=unit_test_results.xml
  artifacts:
    reports:
      junit: unit_test_results.xml
    when: always
```

- A la 7ème ligne, puisque le mot n’est pas un mot-clé reconnu par GitLab, GitLab suppose qu’il s’agit du nom d’une nouvelle tâche à définir. La ligne suivante attribue cette tâche à l'étape (**stage**) de construction (**build**). La ligne suivante installe et exécute un script python.

- A la 13ème ligne, puisque le mot n’est pas un mot-clé reconnu par GitLab, GitLab suppose qu’il s’agit du nom d’une nouvelle tâche à définir. La ligne suivante attribue la tâche à l'étape (**stage**) de **test**. Suite au mot-clé **script**, il définit deux commandes pour la tâche. La première installe le package **pytest**, tandis que la seconde exécute l'outil **pytest** nouvellement installé sur tous les tests unitaires qui se trouvent dans le répertoire **test/**. De plus, il précise que **pytest** doit afficher les résultats des tests unitaires dans un fichier appelé **unit_test_results.xml**, qui sera au format **JUnit XML**.

La section qui commence par le mot-clé **artefacts** permet à GitLab de conserver le fichier de résultats des tests unitaires une fois la tâche terminée, au lieu de le supprimer. Dans la terminologie GitLab, tous les fichiers générés par une tâche puis conservés sont appelés **artefacts**. Il est important de comprendre que tous les fichiers générés par une tâche mais non déclarés comme **artefacts** sont supprimés dès la fin de la tâche.

La dernière ligne de la section **artefacts** indique à GitLab de conserver le fichier de résultats en tant qu'**artefact**, même si la tâche de tests unitaires échoue. La tâche aura le statut **failed** s'il y a des échecs de test, mais nous souhaitons afficher les résultats du test à chaque fois que cette tâche s'exécute, même si (ou surtout si !) il y a des échecs de test.
# Nomenclature des commits Git

### Objectifs

Ce référentiel présente un guide structuré sur la rédaction de messages de commits Git.

### Pourquoi suivre une convention de commit ?

- Améliorer la lisibilité de l'historique Git
- Faciliter la génération de changelogs
- Permettre l'automatisation de la version sémantique (SemVer)
- Clarifier le contexte d'un changement pour les autres développeurs
- Rendre les revues de code plus efficaces

### Format d'un commit

```
<type>(<portée>): <sujet>

<description>

<footer>
```

##### Les différents **types** de commit

Le type du commit décrit l’origine du changement. Il peut avoir plusieurs valeurs :

- **build** : gestion des fichiers liés au build (dockerfile, gulp, webpack, npm)
- **ci** : gestion des fichiers de pipeline (gitHub actions, gitLab ci, circle ci,...)
- **docs** : gestion des fichiers de documentation (README,...)
- **feat** : Ajout d'une nouvelle fonctionnalité
- **fix** : correction d’un bug
- **perf** : modification permettant d'améliorer les performances
- **refactor** : modification n’ajoutant pas de fonctionnalités, ni de correction de bug (renommage d’une variable, suppression de code redondant, simplification du code,...)
- **chore** : mise à jour de dépendances (sans impact direct sur le code)
- **style** : changement du style du code (indentation, point virgule,...)
- **test** : gestion des fichiers de tests

##### La portée d'un type du commit

La **portée** d'un type du commit est un élément facultatif qui indique simplement le contexte du commit, c'est à dire la partie de votre librairie/application qui est affectée par le commit.

##### Le sujet du commit

Le **sujet** du commit contient une description succinte des changements et doit respecter certaines règles :

- le sujet doit faire moins de 50 caractères
- les verbes doivent être à l’impératif (add, update, change, remove, bump,...)
- la première lettre ne doit pas être en majuscule
- le sujet ne doit pas se terminer par un point

##### La description du commit

Le **description** du commit, bien que facultatif, sert à expliquer les raisons du changement ou à fournir des détails supplémentaires. Il peut aussi signaler des changements majeurs (breaking changes). Il doit respecter une longueur inférieure à 100 caractères et suivre les mêmes règles de style que le sujet.

##### Le footer du commit

Le **footer**, bien que facultatif, permet de référencer des issues (GitHub/GitLab) ou d’indiquer des changements majeurs (breaking changes). Il doit faire moins de 100 caractères.

### Quelques commandes git avec les parties d'un commit

- faire un commit avec type et sujet

```
git commit -m "feat: add user authentication with JWT"
```

- faire un commit avec type, portée et sujet

```
git commit -m "fix(api): correct HTTP status code on login failure"
```

- faire un commit avec type, portée, sujet et description

```
git commit -m "fix(api): correct HTTP status code on login failure" -m "Now returns a 401 code instead of 500 for invalid credentials"
```

- faire un commit avec type, portée, sujet, description et footer

```
git commit -m "feat(auth): add JWT authentication" \
           -m "Implement JWT-based authentication to secure API endpoints and user sessions. This change allows users to securely login and access protected routes." \
           -m "BREAKING CHANGE: The authentication system has been completely replaced by JWT authentication, requiring changes in the login flow and API token handling." \
           -m "Closes #42"
```

### Quelques exemples de contenu de commit par type

- **build**

```
build: add Dockerfile for production deployment

Adds a Dockerfile to build an optimized image of the application
```

```
build: update dependencies to latest stable versions

Updates dependencies in package.json and go.mod to fix security warnings
```

- **ci**

```
ci: add GitHub Actions workflow for running tests

Add a workflow to run unit tests on every push to the main branch
```

```
ci: fix GitLab pipeline job name typo

Fixes a syntax error that prevented the pipeline from running on GitLab
```

- **docs**

```
docs: add setup instructions to README

Added setup instructions to README file for new contributors
```

```
docs: fix broken link to contribution guide

Fixes an invalid link in the CONTRIBUTING.md file
```

- **feat**

```
feat: add user authentication with JWT

Implements JWT token authentication to secure API endpoints
```

```
feat: allow bulk CSV upload for data import

Adds bulk import functionality via CSV file for admins
```

- **fix**

```
fix: prevent crash on empty user input

Fixes a crash that occurred when the user submitted an empty field
```

```
fix(api): correct HTTP status code on login failure

Now returns a 401 code instead of 500 for invalid credentials
```

- **perf**

```
perf: optimize SQL query for dashboard loading

Reduces dashboard response time from 2s to 500ms
```

```
perf: use gzip compression in HTTP server

Enables gzip compression to improve client-side loading times
```

- **refactor**

```
refactor: extract auth logic into middleware

Separates authentication logic into dedicated middleware
```

```
refactor: rename variables for clarity in payment service

Improves code readability without changing how it works
```

- **chore**

```
chore: update .gitignore to exclude temp files

Adds system temporary files to .gitignore
```

```
chore: remove unused scripts from package.json

Cleanup of obsolete scripts that are no longer used
```

- **style**

```
style: fix indentation in login component

Fix login component indentation to match project conventions
```

```
style: remove trailing whitespace and reformat imports

General code cleanup without logic changes
```

- **test**

```
test: add unit tests for user service

Adds unit tests to verify user business logic
```

```
test: refactor existing tests to use mock database

Uses a mock database to speed up integration testing
```

#### Références

- [conventionalcommits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Grafikart nommage-commit](https://grafikart.fr/tutoriels/nommage-commit-1009)
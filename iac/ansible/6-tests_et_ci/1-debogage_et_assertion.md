# Débogage et assertion

### Tests unitaires, d'intégration et fonctionnels

Pour tester une infrastructure Ansible, il est essentiel de comprendre les types de tests et leur utilité :
- Tests unitaires : appliqués aux playbooks individuels, ils sont souvent limités à la vérification de la syntaxe YAML afin d'éviter des erreurs bloquantes.
- Tests d'intégration : plus utiles, ils vérifient que plusieurs rôles et playbooks fonctionnent bien ensemble, en les testant individuellement sur des machines virtuelles isolées.
- Tests fonctionnels : concernent l'ensemble de l'infrastructure déployée, garantissant que tout fonctionne comme prévu. Le reporting d'Ansible et des outils externes permettent d'approfondir ces tests.

### Tester un playbook Ansile

Tester un playbook Ansible consiste principalement à vérifier les modifications de configuration et le bon état du système en cours d'exécution. Il est recommandé d'intégrer des tests simples directement dans les playbooks à l'aide de modules dédiés :

- Module **debug** : permet d'afficher des variables et des messages pendant l'exécution, utile pour le débogage et la journalisation.
- Module **fail** : force l'arrêt du playbook si une condition spécifique est remplie.
- Module **assert** : vérifie qu'une condition est vraie et génère un message en cas d'échec. Contrairement à fail, une assertion réussie apparaît comme une tâche validée (ok).

Ces modules facilitent le diagnostic et garantissent que l’infrastructure est bien configurée à chaque exécution du playbook.

```
---
- hosts: 127.0.0.1
  gather_facts: no
  connection: local
  
  tasks:
    - name: Register the output of the 'uptime' command.
      command: uptime
      register: system_uptime

    - name: Print the registered output of the 'uptime' command.
      debug:
        var: system_uptime.stdout

    - name: Print a message if a command resulted in a change.
      debug:
        msg: "Command resulted in a change!"
      when: system_uptime is changed
```

```
---
- hosts: 127.0.0.1
  gather_facts: no
  connection: local

  vars:
    should_fail_via_fail: true
    should_fail_via_assert: false
    should_fail_via_complex_assert: false

  tasks:
    - name: Fail if conditions warrant a failure.
      fail:
        msg: "There was an epic failure."
      when: should_fail_via_fail

    - name: Stop playbook if an assertion isn't validated.
      assert:
        that: "should_fail_via_assert != true"

    - name: Assertions can have contain conditions.
      assert:
      that:
        - should_fail_via_fail != true
        - should_fail_via_assert != true
        - should_fail_via_complex_assert != true    
```

### Analyse de code YAML avec yamllint

Avant d'exécuter un playbook Ansible, il est recommandé de vérifier la syntaxe YAML pour éviter des erreurs courantes, par exemple les erreurs liées aux espaces. L'outil **yamllint** (**https://yamllint.readthedocs.io/en/stable/**), installable via **pipx**, permet d'analyser et de valider la structure des fichiers YAML afin d'assurer leur conformité.

```
# Installation de pipx sous Ubuntu 24.04
sudo apt install pipx
```

```
pipx install yamllint

pipx ensurepath
```

La commande "**pipx ensurepath**" permet d'ajouter automatiquement notre PATH **$HOME/.local/bin** dans le fichier de configuration de notre shell (**$HOME/.bashrc**).

**Exemple de playbook avec un contenu yaml mal formaté**

```
mkdir -p $HOME/test-yamllint && cd $HOME/test-yamllint
```

```
vim $HOME/test-yamllint/playbook.yaml
```

```
- hosts: 127.0.0.1
  gather_facts: no
  connection: local
  
  tasks:
  - name: Register the output of the 'uptime' command.
    command: uptime
    register: system_uptime # Save uptime output

  - name: Print the registered output of the 'uptime' command.
    debug:
     var: system_uptime.stdout

  - name: Print a message if a command resulted in a change.
    debug:
      msg: "Command resulted in a change!"
    when: system_uptime is changed
```

Appliquons la commmande **yamllint** dans le repertoire **$HOME/test-yamllint**

```
yamllint .
```

On aura le résultat :

```
./playbook.yaml
  1:1       warning  missing document start "---"  (document-start)
  2:17      warning  truthy value should be one of [false, true]  (truthy)
  4:1       error    trailing spaces  (trailing-spaces)
  6:3       error    wrong indentation: expected at least 3  (indentation)
  8:29      warning  too few spaces before comment  (comments)
  16:7      error    wrong indentation: expected 5 but found 6  (indentation)
```

Dans ce cas particulier, nous pouvons corriger certaines erreurs rapidement :
- ajouter un indicateur de début de document YAML (---) en haut du playbook.
- supprimer l'espace superflu sur la ligne de commande.
- ajouter un espace supplémentaire avant le commentaire #.
- s'assurer que la ligne var est indentée d'un espace supplémentaire.

```
- hosts: 127.0.0.1
  gather_facts: no
  connection: local
  
  tasks:
    - name: Register the output of the 'uptime' command.
      command: uptime
      register: system_uptime # Save uptime output

    - name: Print the registered output of the 'uptime' command.
      debug:
        var: system_uptime.stdout

    - name: Print a message if a command resulted in a change.
      debug:
        msg: "Command resulted in a change!"
      when: system_uptime is changed
```

Pour le warning "**truthy value should be one of [false, true]**", Nous pouvons le faire en personnalisant Yamllint avec un fichier de configuration. Créons un fichier dans le même répertoire, nommé **.yamllint**.

```
vim $HOME/test-yamllint/.yamllint
```

```
---
extends: default

rules:
  truthy:
    allowed-values:
      - 'true'
      - 'false'
      - 'yes'
      - 'no'
```

En appliquant à nouveau la commande **yamllint** nous aurons aucun message en sortie : pas de **warning**, pas **erreur**.

### Exécution d'une vérification syntaxique : --syntax-check

L'option **--syntax-check** de la commande **ansible-playbook** permet de vérifier la syntaxe d’un playbook sans l’exécuter. Elle charge l’ensemble du playbook statiquement pour détecter des erreurs comme des fichiers manquants, des modules mal orthographiés ou des paramètres invalides. <br>
Cette vérification rapide est utile avant l’exécution et peut être intégrée aux tests **CI/CD** ainsi qu’aux hooks **pre-commit** dans un dépôt Git, en complément de **yamllint**.

La vérification syntaxique d'Ansible charge un playbook de manière statique, mais ne valide pas les inclusions dynamiques (**include_tasks**) ni les variables. Pour garantir une exécution correcte, des tests d'intégration supplémentaires sont nécessaires.

### Analyse du contenu Ansible avec ansible-lint

L'utilitaire **ansible-lint** permet d'analyser les tâches et les playbooks Ansible. (**https://github.com/ansible/ansible-lint**)

- Installation via pipx sous Ubuntu 24.04

```
pipx install ansible-lint
```

- Appliquons la commande **ansible-lint** à notre playbook

```
cd $HOME/test-yamllint
```

```
ansible-lint playbook.yaml
```

On aura le résultat :

```
...
WARNING  Listing 6 violation(s) that are fatal
name[play]: All plays should be named.
playbook.yaml:2

fqcn[action-core]: Use FQCN for builtin module actions (command).
playbook.yaml:7 Use `ansible.builtin.command` or `ansible.legacy.command` instead.

no-changed-when: Commands should not change things if nothing needs doing.
playbook.yaml:7 Task/Handler: Register the output of the 'uptime' command.

fqcn[action-core]: Use FQCN for builtin module actions (debug).
playbook.yaml:11 Use `ansible.builtin.debug` or `ansible.legacy.debug` instead.

fqcn[action-core]: Use FQCN for builtin module actions (debug).
playbook.yaml:15 Use `ansible.builtin.debug` or `ansible.legacy.debug` instead.

no-handler: Tasks that run when changed should likely be handlers.
playbook.yaml:15 Task/Handler: Print a message if a command resulted in a change
...
```

Chaque suggestion correspond à une « règle » ; toutes les règles par défaut sont répertoriées dans la **documentation d'Ansible Lint** (**https://ansible.readthedocs.io/projects/lint/rules/**).

Pour corriger ces problèmes, procédons comme suit :
- ajouter un nom à la tâche uptime pour résoudre la **violation de la règle name[play]**
- ajouter le préfix **ansible.builtin.** à toutes les actions des tâches de notre playbook pour résoudre la **violation de la règle fqcn[action-core]**
- ajouter **changed_when: false** à la tâche uptime pour résoudre la **violation de la règle no-changed-when**. Puisque la tâche ne modifie rien sur le système, il est conseillé de la marquer comme telle afin d'éviter toute violation de l'idempotence

```
---
- name: Uptime checker
  hosts: 127.0.0.1
  gather_facts: no
  connection: local

  tasks:
    - name: Register the output of the 'uptime' command.
      ansible.builtin.command: uptime
      register: system_uptime  # Save uptime output
      changed_when: false

    - name: Print the registered output of the 'uptime' command.
      ansible.builtin.debug:
        var: system_uptime.stdout

    - name: Print a message if a command resulted in a change.
      ansible.builtin.debug:
        msg: "Command resulted in a change!"
      when: system_uptime is changed
```

La plupart des règles sont simples, mais nous pouvons en ignorer certaines si nous avons de bonnes raisons de ne pas respecter les règles par défaut. Comme avec yamllint, nous pouvons ajouter un fichier nommé **.ansible-lint**, fournissant une configuration spécifique à notre projet.
(**https://ansible.readthedocs.io/projects/lint/configuring/#ansible-lint-configuration**)

Ignorons notre dernière violation de la règle **no-handler** via le fichier **.ansible-lint**.

```
vim $HOME/test-yamllint/.ansible-lint
```

```
---
skip_list:
  - no-handler
```

En appliquant à nouveau la commande **ansible-lint** nous aurons un message indiquant : aucun **avertissement**, aucune **erreur**.
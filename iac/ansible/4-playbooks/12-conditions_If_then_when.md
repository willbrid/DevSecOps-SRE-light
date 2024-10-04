# Les conditions If/then/when

De nombreuses tâches ne doivent être exécutées que dans certaines circonstances. Certaines tâches utilisent des modules avec idempotence intégrée (comme c'est le cas pour s'assurer qu'un package yum ou apt est installé), et nous n'avons généralement pas besoin de définir d'autres comportements conditionnels pour ces tâches. Nous pouvons utiliser les conditions Ansible avec les expressions **Jinja** pour aussi exécuter des tâches sous condition.

### **register**

Dans Ansible, n'importe quel jeu peut « enregistrer » une variable, et une fois enregistrée, cette variable sera disponible pour toutes les tâches suivantes. Les variables enregistrées fonctionnent comme des variables normales ou des faits d'hôte. Souvent, nous pouvons avoir besoin la sortie (**stdout** ou **stderr**) d'une commande shell, et nous pouvons l'obtenir dans une variable en utilisant la syntaxe suivante :

```
---
- hosts: multi
  tasks:
  - name: Check for file presence
    stat:
      path: /etc/hosts
    register: file_info
```

Plus tard, nous pouvons accéder à **stdout** (sous forme de chaîne) avec **my_command_result.stdout** et à **stderr** avec **my_command_result.stderr**.

Les faits enregistrés sont très utiles pour de nombreux types de tâches et peuvent être utilisés à la fois avec des conditions (définir quand et comment une tâche se déroule) et dans n'importe quelle partie de la tâche.

### **when**

Dans cet exemple ci-dessous, nous exécuterons la tâche **Show file status** si la valeur de la variable **file_info.stat.exists** est **vraie** ou ignorerons la tâche lorsque cette valeur est **fausse**.

```
---
- hosts: multi
  tasks:
  - name: Check for file presence
    stat:
      path: /etc/hosts
    register: file_info

  - name: Show file status
    debug:
      msg: "The file existe"
    when: file_info.stat.exists
```

S'il existe des moments où la variable **file_info** peut ne pas être définie du tout, alors nous pouvons exécuter des tâches de manière conditionnelle comme suit :

```
---
- hosts: multi
  tasks:
  - name: Check for file presence
    stat:
      path: /etc/hosts
    register: file_info

  - name: Show file status
    debug:
      msg: "The file existe"
    when: (file_info is defined) and file_info.stat.exists
```

### changed_when, failed_when et ignore_errors

```
---
- hosts: multi
  tasks:
  - name: Check for file presence
    command: ls /tmp/test_file.txt
    register: file_check
    ignore_errors: true

  - name: Determine if a file has changed
    debug:
      msg: "File does not exist, action required"
    changed_when: file_check.rc != 0

  - name: Fail if the file is not found and should not be missing
    debug:
      msg: "The file is missing, but it shouldn't be"
    failed_when: file_check.rc != 0 and "file_should_exist" in ansible_facts
```

Nous pouvons utiliser **changed_when** et **failed_when** pour influencer les rapports d’Ansible indiquant quand une certaine tâche entraîne des modifications ou des échecs :
- **changed_when** : permet de définir si une tâche doit être marquée comme ayant changé quelque chose en fonction de la condition que nous spécifions
- **failed_when** : permet de définir quand une tâche doit être considérée comme ayant échoué en fonction de la condition que nous spécifions

Pour certaines situations, nous pouvons ajouter **ignore_errors: true** à une tâche, et Ansible restera parfaitement inconscient des problèmes d'exécution de la tâche particulière. Il est généralement préférable de trouver un moyen de travailler avec et de contourner les erreurs générées par les tâches afin que les playbooks échouent en cas de problèmes réels.
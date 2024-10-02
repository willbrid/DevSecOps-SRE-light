# Les conditions If/then/when

De nombreuses tâches ne doivent être exécutées que dans certaines circonstances. Certaines tâches utilisent des modules avec idempotence intégrée (comme c'est le cas pour s'assurer qu'un package yum ou apt est installé), et nous n'avons généralement pas besoin de définir d'autres comportements conditionnels pour ces tâches. Nous pouvons utiliser les conditions Ansible avec les expressions **Jinja** pour aussi exécuter des tâches sous condition.

### **register**

Dans Ansible, n'importe quel jeu peut « enregistrer » une variable, et une fois enregistrée, cette variable sera disponible pour toutes les tâches suivantes. Les variables enregistrées fonctionnent comme des variables normales ou des faits d'hôte. Souvent, nous pouvons avoir besoin la sortie (**stdout** ou **stderr**) d'une commande shell, et nous pouvons l'obtenir dans une variable en utilisant la syntaxe suivante :

```
- shell: my_command_here
  register: my_command_result
```

Plus tard, nous pouvons accéder à **stdout** (sous forme de chaîne) avec **my_command_result.stdout** et à **stderr** avec **my_command_result.stderr**.

Les faits enregistrés sont très utiles pour de nombreux types de tâches et peuvent être utilisés à la fois avec des conditions (définir quand et comment une tâche se déroule) et dans n'importe quelle partie de la tâche.

### **when**

L’instruction ci-dessous suppose que nous avons défini la variable **is_db_server** comme un booléen (vrai ou faux) plus tôt et que nous exécuterons la tâche si la valeur est **vraie** ou ignorerons la tâche lorsque la valeur est **fausse**.

```
- yum: name=mysql-server state=present
  when: is_db_server
```

Par exemple si nous définissons uniquement la variable **is_db_server** sur les serveurs de base de données (ce qui signifie qu'il existe des moments où la variable peut ne pas être définie du tout), nous pouvons exécuter des tâches de manière conditionnelle comme suit :

```
- yum: name=mysql-server state=present
  when: (is_db_server is defined) and is_db_server
```

**when** est encore plus intéressant s'il est utilisé en conjonction avec des variables enregistrées par des tâches précédentes. Par exemple, nous voulons vérifier l'état d'une application en cours d'exécution et exécuter une lecture uniquement lorsque cette application signale qu'elle est « prête » dans sa sortie :

```
- command: app --status
  register: app_result

- command: do-something-to-app
  when: "'ready' in app_result.stdout"
```

### changed_when et failed_when

Nous pouvons utiliser **changed_when** et **failed_when** pour influencer les rapports d’Ansible indiquant quand une certaine tâche entraîne des modifications ou des échecs.

```
- name: Install dependencies via Composer.
  command: "/usr/local/bin/composer global require phpunit/phpunit --prefer-dist"
  register: composer
  changed_when: "'Nothing to install' not in composer.stdout"
```

```
- name: Import a Jenkins job via CLI.
  shell: >
    java -jar /opt/jenkins-cli.jar -s http://localhost:8080/
    create-job "My Job" < /usr/local/my-job.xml
  register: import
  failed_when: "import.stderr and 'exists' not in import.stderr"
```

### ignore_errors

Pour certaines situations, nous pouvons ajouter **ignore_errors: true** à une tâche, et Ansible restera parfaitement inconscient des problèmes d'exécution de la tâche particulière.

Il est généralement préférable de trouver un moyen de travailler avec et de contourner les erreurs générées par les tâches afin que les playbooks échouent en cas de problèmes réels.
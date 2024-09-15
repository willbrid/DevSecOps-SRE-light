# Les variables

Les variables dans Ansible fonctionnent comme les variables dans la plupart des autres systèmes. Les variables commencent généralement par une lettre ( [A-Za-z] ), mais peuvent également commencer par un trait de soulignement ( _ ). Les variables peuvent inclure n'importe quel nombre de lettres, de traits de soulignement ou de chiffres.

## Les variables de playbook

Il existe de nombreuses façons différentes de définir des variables à utiliser dans les tâches :

- les variables peuvent être transmises via la ligne de commande, lors de l'appel **ansible-playbook** avec l'option **--extra-vars**

```
ansible-playbook example.yml --extra-vars "foo=bar"
```

Nous pouvons également transmettre des variables supplémentaires en utilisant du JSON, du YAML entre guillemets, ou même en transmettant directement un fichier **JSON** ou **YAML**.

```
ansible-playbook example.yml --extra-vars "@even_more_vars.json"
```

```
ansible-playbook example.yml --extra-vars "@even_more_vars.yml"
```

- les variables peuvent être incluses en ligne dans un playbook au niveau d'une section **vars**

```
---
- hosts: multi

  vars:
    dest: /tmp

  tasks:
  - debug:
      msg: "Variable 'dest' is set to {{ dest }}"
```

- les variables peuvent également être incluses dans un fichier séparé, en utilisant la section **vars_files**

```
# fichier playbook
---
- hosts: multi

  vars_files:
  - vars.yml

  tasks:
  - debug:
      msg: "Variable 'dest' is set to {{ dest }}"
```

```
# fichier 'vars.yml' dans le même répertoire que le playbook
---
dest: /tmp
```

- les fichiers variables peuvent également être importés de manière conditionnelle. Supposons, par exemple, que nous ayons un ensemble de variables pour nos serveurs RHEL (où le service Apache est nommé httpd ) et un autre pour nos serveurs Debian (où le service Apache est nommé apache2). Dans ce cas, nous pouvons inclure conditionnellement des fichiers variables en utilisant **include_vars**.

```
# fichier playbook
---
- hosts: multi

  pre_tasks:
  - include_vars: "{{ item }}"
    with_first_found:
    - "apache_{{ ansible_os_family }}.yml"
    - "apache_default.yml"

  tasks:
  - debug:
      msg: "Variable 'log_system' is set to {{ log_system }}"
```

Nous ajoutons trois fichiers dans le même dossier que notre fichier de playbook, **apache_Rocky.yml**, **apache_Ubuntu.yml** et **apache_default.yml**.

```
# Fichier apache_Rocky.yml
---
log_system: /var/log/messages
```

```
# Fichier apache_Ubuntu.yml
---
log_system: /var/log/syslog
```

```
# Fichier apache_default
---
log_system: /var/log/syslog
```

Ansible stocke le système d'exploitation du serveur dans la variable **ansible_os_family**.
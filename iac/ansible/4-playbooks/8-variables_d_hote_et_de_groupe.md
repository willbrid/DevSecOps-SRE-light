# Variables d'hôte et de groupe

Ansible nous permet de définir ou de remplacer facilement des variables par hôte ou par groupe.

- La manière la plus simple de définir des variables par hôte ou par groupe est de le faire directement dans le fichier d'inventaire

```
[app]
192.168.56.4 admin_user=app1
192.168.56.5 admin_user=app2
192.168.56.7

[multi:vars]
admin_user=app
```

Dans ce cas, Ansible utilisera la valeur par défaut **app** pour la variable **admin_user** du groupe **multi**, mais pour **192.168.56.4** et **192.168.56.5**, la variable **admin_user** définie à côté du nom d’hôte sera utilisée.

- Ansible recherchera dans le même répertoire que notre fichier d'inventaire (ou dans **/etc/ansible** si nous utilisons le fichier d'inventaire par défaut **/etc/ansible/hosts** ) deux répertoires spécifiques : **group_vars** et **host_vars** . Nous pouvons placer des fichiers YAML dans ces répertoires nommés d'après le nom du groupe ou le nom d'hôte défini dans notre fichier d'inventaire.

```
---
# File: /etc/ansible/group_vars/multi
admin_user: app
```

```
---
# File: /etc/ansible/host_vars/192.168.56.4
admin_user: app1
```

```
---
# File: /etc/ansible/host_vars/192.168.56.5
admin_user: app2
```

- Même si nous utilisons le fichier d’inventaire par défaut (ou un fichier d’inventaire en dehors du répertoire racine de notre playbook), Ansible utilisera également les fichiers de variables d’hôte et de groupe situés dans les répertoires **group_vars** et **host_vars** de notre playbook. Cela est pratique lorsque nous souhaitons regrouper l’intégralité de notre playbook et de notre configuration d’infrastructure dans un référentiel git.

- Si nous avons besoin de récupérer les variables d’un hôte spécifique à partir d’un autre hôte, Ansible fournit une variable **hostvars** magique contenant toutes les variables d’hôte définies (à partir des fichiers d’inventaire et de tous les fichiers YAML découverts dans les répertoires **host_vars**).

```
# Depuis n'importe quel hôte, cela renvoie app1
{{ hostvars['192.168.56.4']['admin_user'] }}
```

- Il existe une variété d'autres variables fournies par Ansible.

--- **groups** : une liste de tous les noms de groupe dans l'inventaire. <br>
--- **group_names** : une liste de tous les groupes dont l'hôte actuel fait partie. <br>
--- **inventory_hostname** : le nom d'hôte de l'hôte actuel, selon l'inventaire (cela peut différer de **ansible_hostname** , qui est le nom d'hôte du système). <br>
--- **inventory_hostname_short** : la première partie de **inventory_hostname** , jusqu'au premier point. <br>
--- **play_hosts** : tous les hôtes sur lesquels la partie en cours sera exécutée.

```
---
- hosts: multi
  become: no

  tasks:
  - name: display groups variable
    debug:
      msg: "groups : {{ groups }}"

  - name: display group_names variable
    debug:
      msg: "group_names : {{ group_names }}"

  - name: display inventory_hostname variable
    debug:
      msg: "inventory_hostname : {{ inventory_hostname }}"

  - name: display inventory_hostname_short variable
    debug:
      msg: "inventory_hostname_short : {{ inventory_hostname_short }}"    

  - name: display play_hosts variable
    debug:
      msg: "play_hosts : {{ play_hosts }}"
```
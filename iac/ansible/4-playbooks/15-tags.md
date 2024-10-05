# Tags

Les tags nous permettent d'exécuter (ou d'exclure) des sous-ensembles de tâches d'un playbook. Nous pouvons baliser : des rôles, des fichiers inclus, des tâches individuelles et même des playbooks entiers.

```
vi setting-up-nginx-playbook.yml
```

```
---
- hosts: app
  become: yes

  tasks:
  - name: Install Nginx
    yum:
      name: nginx
      state: present
      update_cache: yes
    tags: 
    - install
    - nginx

  - name: Start and enable Nginx
    service:
      name: nginx
      state: started
      enabled: yes
    tags: 
    - configure
    - nginx

  - name: Create a custom index file for the website
    copy:
      dest: /usr/share/nginx/html/custom-index.html
      content: "<h1>Welcome to Nginx</h1>"
    tags:
    - configure
    - content

  - name: Restart Nginx after configuration
    service:
      name: nginx
      state: restarted
    tags: 
    - restart
    - nginx
```

Pour exécuter uniquement les tâches marquées avec le tag **install**

```
ansible-playbook setting-up-nginx-playbook.yml --tags "install"
```

Pour exécuter uniquement les tâches marquées avec les tags **install** et **configure**

```
ansible-playbook setting-up-nginx-playbook.yml --tags "install,configure"
```

Pour exécuter uniquement les tâches non marquées avec le tag **configure**

```
ansible-playbook setting-up-nginx-playbook.yml --skip-tags "configure"
```

- **--tags** : cette option permet de sélectionner uniquement les tâches marquées avec un ou plusieurs tags spécifiques. Si cette option est utilisée, seules les tâches correspondant aux tags spécifiés seront exécutées.

- **--skip-tags** : cette option permet d'ignorer les tâches marquées avec les tags spécifiés. Toutes les autres tâches seront exécutées sauf celles qui portent les tags indiqués.

En général, il est recommandé d'utiliser des tags pour les playbooks plus volumineux, en particulier avec des rôles et des playbooks individuels. A moins de déboguer un ensemble de tâches, il faut généralement éviter d'ajouter des tags aux tâches individuelles ou aux inclusions.
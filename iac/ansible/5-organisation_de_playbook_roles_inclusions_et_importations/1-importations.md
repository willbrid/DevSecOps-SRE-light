# Importations

### vars_files

On peut utiliser **vars_files** pour placer des variables dans un fichier **vars.yml** séparé au lieu de les intégrer au playbook.

```
# vars.yml
nginx_package: nginx
nginx_service: nginx
website_content: "<h1>Bienvenue sur Nginx!</h1>"
website_path: "/usr/share/nginx/html/custom-index.html"
```

```
---
- hosts: app
  become: yes

  vars_files:
  - vars.yml

  tasks:
  - name: Install Nginx
    yum:
      name: "{{ nginx_package }}"
      state: present

  - name: Start and enable Nginx
    service:
      name: "{{ nginx_service }}"
      state: started
      enabled: yes

  - name: Create a custom index file for the website
    copy:
      dest: "{{ website_path }}"
      content: "{{ website_content }}"

  - name: Restart Nginx after configuration
    service:
      name: "{{ nginx_service }}"
      state: restarted
```

### import_tasks

Les tâches peuvent facilement être incluses grâce aux directives **import_tasks** dans la section **tasks** de notre playbook. Les fichiers importés peuvent même importer d'autres fichiers.

```
# vars.yml
nginx_package: nginx
nginx_service: nginx
website_content: "<h1>Bienvenue sur Nginx!</h1>"
website_path: "/usr/share/nginx/html/custom-index.html"
```

```
# install_nginx.yml
- name: Install Nginx
  yum:
    name: "{{ nginx_package }}"
    state: present

- name: Start and enable Nginx
  service:
    name: "{{ nginx_service }}"
    state: started
    enabled: yes
```

```
# configure_website.yml
- name: Create a custom index file for the website
  copy:
    dest: "{{ website_path }}"
    content: "{{ website_content }}"

- name: Restart Nginx after configuration
  service:
    name: "{{ nginx_service }}"
    state: restarted
```

```
---
- hosts: app
  become: yes

  vars_files:
  - vars.yml

  tasks:
  - import_tasks: install_nginx.yml
  - import_tasks: configure_website.yml
```

### Includes

Si nous utilisons **import_tasks**, Ansible importe de manière statique le fichier de tâches comme s'il faisait partie du playbook principal, 
une fois, avant l'exécution du playbook Ansible. Si nous devons inclure des tâches dynamiques, nous pouvons utiliser **include_tasks**. 
Donc **import_tasks** charge les tâches statiquement au moment de la lecture du playbook alors que **include_tasks** charge les tâches 
dynamiquement pendant l'exécution du playbook, ce qui permet une flexibilité, notamment avec l'usage de conditions ou de boucles.


```
# display-content.yml
- name: Get remote file contents
  command: cat /etc/hosts
  register: file_content

- name: Show file contents in Ansible output
  debug:
    var: file_content.stdout
```

```
---
- hosts: app
  become: no

  tasks:
  - name: Check if /etc/hosts is present
    stat:
      path: /etc/hosts
    register: fileinfo

  - include_tasks: display-content.yml
    when: fileinfo.stat.exists
```

### Handler : imports et includes

Les **handlers** peuvent être importés ou inclus comme des tâches, dans la section **handlers** d’un playbook.

```
# vars.yml
nginx_package: nginx
nginx_service: nginx
website_content: "<h1>Bienvenue sur Nginx!</h1>"
website_path: "/usr/share/nginx/html/custom-index.html"
```

```
# install_nginx.yml
- name: Install Nginx
  yum:
    name: "{{ nginx_package }}"
    state: present

- name: Start and enable Nginx
  service:
    name: "{{ nginx_service }}"
    state: started
    enabled: yes
```

```
# configure_website.yml
- name: Create a custom index file for the website
  copy:
    dest: "{{ website_path }}"
    content: "{{ website_content }}"
  notify: Restart Nginx after configuration
```

```
# handlers.yml
- name: Restart Nginx after configuration
  service:
    name: "{{ nginx_service }}"
    state: restarted
```

```
---
- hosts: app
  become: yes

  vars_files:
  - vars.yml

  tasks:
  - import_tasks: install_nginx.yml
  - import_tasks: configure_website.yml

  handlers:
  - name: Inclure nginx handlers after configuration 
    import_tasks: handlers.yml
```

### import_playbook

Les playbooks peuvent même être inclus dans d'autres playbooks, en utilisant la même syntaxe d'importation avec **import_playbook** au niveau 
supérieur de notre playbook. L'important de playbooks avec **import_playbook** n'est pas dynamique comme les inclusions de tâches avec 
**include_tasks**.

**Cas d'utilisation concret** : nous pouvons créer des playbooks pour configurer tous les serveurs de notre infrastructure, puis créer 
un playbook principal qui inclut chacun des playbooks individuels.

```
- hosts: multi
  become: yes

  tasks:
  - name: Configure all servers

- import_playbook: web.yml
- import_playbook: db.yml
```
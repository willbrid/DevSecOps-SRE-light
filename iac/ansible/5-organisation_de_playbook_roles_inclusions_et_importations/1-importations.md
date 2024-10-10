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
      update_cache: yes

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
    update_cache: yes

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
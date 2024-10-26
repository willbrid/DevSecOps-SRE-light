# Roles

Un rôle Ansible est une structure de dossiers et de fichiers prédéfinie permettant de regrouper et organiser logiquement des éléments Ansible
comme des tâches, des variables, des fichiers, des templates, des handlers, et d'autres ressources. Les rôles facilitent la réutilisation et 
le partage de code entre différents playbooks, ce qui les rend pratiques pour des configurations complexes et modulaires.

Il n'y a que deux répertoires requis pour créer un rôle Ansible fonctionnel :

```
role_name/
  meta/
  tasks/
```

Pour un rôle dans un playbook on définit la section **roles** :

```
---
- hosts: multi
  
  roles:
  - role_name
```

Nos rôles peuvent résider à plusieurs endroits différents : le chemin de rôle Ansible global par défaut (configurable dans **/etc/ansible/ansible.cfg**) 
ou un dossier de rôles dans le même répertoire que notre fichier de playbook principal.

Pour permettre qu'un ensemble de tâches s'exécute avant d'autres tâches, on définit la section **pre_tasks**.

```
- hosts: multi

  pre_tasks:
  - name: Install epel repo

  tasks:
  - name: Install httpd
```

**Exemple de playbook avec role :**

```
mkdir $HOME/configure-welcome-with-nginx $HOME/configure-welcome-with-nginx/roles $HOME/configure-welcome-with-nginx/roles/nginx $HOME/configure-welcome-with-nginx/roles/nginx/defaults $HOME/configure-welcome-with-nginx/roles/nginx/meta $HOME/configure-welcome-with-nginx/roles/nginx/tasks $HOME/configure-welcome-with-nginx/roles/nginx/handlers
```

```
# $HOME/configure-welcome-with-nginx/vars.yml
website_path: "/usr/share/nginx/html/welcome.html"
```

```
# $HOME/configure-welcome-with-nginx/playbook.yml
---
- hosts: app
  become: yes

  vars_files:
  - vars.yml

  pre_tasks:
  - name: Installation of nginx
    debug:
      msg: "Install and configure nginx with custom welcome page"

  roles:
  - nginx

  tasks:
  - name: Restart nginx after configuration
    notify: Restart Nginx
```

```
# $HOME/configure-welcome-with-nginx/roles/nginx/defaults/main.yml
nginx_package: nginx
nginx_service: nginx
website_content: "<h1>Bienvenue sur Nginx!</h1>"
website_path: "/usr/share/nginx/html/custom-index.html"
```

```
# $HOME/configure-welcome-with-nginx/roles/nginx/meta/main.yml
---
dependencies: []
```

```
# $HOME/configure-welcome-with-nginx/roles/nginx/tasks/main.yml
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
```

```
# $HOME/configure-welcome-with-nginx/roles/nginx/handlers/main.yml
- name: Restart Nginx
  service:
    name: "{{ nginx_service }}"
    state: restarted
```

Deux choses importantes à noter à propos du style d'inclusion spécifique à une distribution :

1. Lorsque nous incluons des fichiers **vars** et **tasks** (avec **include_vars** ou **include_tasks**), nous pouvons en fait utiliser des variables dans le nom du fichier. Cela est pratique dans de nombreuses situations ; ici, nous incluons un fichier **vars** au format **distribution_name.yml**.

Pour nos besoins, puisque le rôle sera utilisé sur des hôtes basés sur **Debian** et **RHEL**, nous pouvons créer des fichiers **Debian.yml** et **RedHat.yml** dans les dossiers **defaults** et **vars** de notre rôle, et y placer des variables spécifiques à la distribution.

2. Pour les tâches, nous incluons les fichiers de tâches dans le répertoire **tasks** du rôle, par exemple **setup-Debian.yml** ou **setup-RedHat.yml**.

Après avoir configuré les choses de cette manière, l'on peut placer les tâches spécifiques à **RHEL** (comme les tâches **dnf**) dans **tasks/setup-RedHat.yml**, et les tâches spécifiques à **Debian** et **Ubuntu** (comme les tâches **apt**) dans **tasks/setup-Debian.yml**.
# Les bases : variables d'environnement

Ansible nous permet de travailler avec des variables d'environnement de différentes manières. 

- Ajoutons une variable d'environnement au shell de l'utilisateur distant

```
---
  - name: Add an environment variable to the remote user's shell.
    lineinfile:
      dest: ~/.bash_profile
      regexp: '^ENV_VAR='
      line: "ENV_VAR=value"
```

Toutes les tâches suivantes auront alors accès à cette variable d'environnement. 

```
---
  - name: Add an environment variable to the remote user's shell.
    lineinfile:
      dest: ~/.bash_profile
      regexp: '^ENV_VAR='
      line: "ENV_VAR=value"

  - name: Get the value of the environment variable we just added.  
    shell: 'source ~/.bash_profile && echo $ENV_VAR'  
```

Pour utiliser une variable d'environnement dans d'autres tâches, il est recommandé d'utiliser l'option **register** d'une tâche pour stocker la variable d'environnement dans une variable qu'Ansible pourra utiliser ultérieurement.

```
---
  - name: Add an environment variable to the remote user's shell.
    lineinfile:
      dest: ~/.bash_profile
      regexp: '^ENV_VAR='
      line: "ENV_VAR=value"

  - name: Get the value of the environment variable we just added.  
    shell: 'source ~/.bash_profile && echo $ENV_VAR' 
    register: foo

  - name: Print the value of the environment variable.
    debug:
      msg: "The variable is {{ foo.stdout }}"   
```

Linux peut également lire les variables d'environnement globales ajoutées à **/etc/environment** :

```
---
  - name: Add a global environment variable
    lineinfile:
      dest: /etc/environment
      regexp: '^ENV_VAR='
      line: "ENV_VAR=value"
    become: yes  
```

Si notre application nécessite de nombreuses variables d'environnement, nous pouvons envisager d'utiliser **copy** ou **template** avec un fichier local au lieu d'utiliser **lineinfile** avec une longue liste d'éléments.

Nous pouvons également définir une variable d'environnement pour une seule tâche, en utilisant l'option **environment** pour cette tâche (par exemple défini une variable d'environnement **http_proxy** avec le module **get_url**).

```
---
  - name: Download a file, using example-proxy as a proxy.
    get_url:
      url: https://get.docker.com
      dest: ~/Downloads/
    environment:
      http_proxy: http://example-proxy:80/
```

Si nous avons de nombreuses tâches qui nécessitent un proxy ou une autre variable d'environnement. Dans ce cas, nous pouvons transmettre à l'option **environment** une variable dans la section **vars** de notre playbook (ou via un fichier de variables inclus) :

```
---
  vars:
    proxy_vars:
      http_proxy: http://example-proxy:80/
      https_proxy: https://example-proxy:443/

  tasks:
  - name: Download a file, using example-proxy as a proxy.
    get_url:
      url: https://get.docker.com
      dest: ~/Downloads/
    environment: proxy_vars
```

Si un proxy doit être défini à l'échelle du système (comme c'est le cas derrière de nombreux pare-feu d'entreprise), nous pouvons utiliser le fichier global **/etc/environment** :

```
---
  vars:
    proxy_state: present
  
  tasks:
  - name: Configure the proxy
    lineinfile:
      dest: /etc/environment
      regexp: "{{ item.regexp }}"
      line: "{{ item.line }}"
      state: "{{ proxy_state }}"
    with_items:
    - regexp: "^http_proxy="
      line: "http_proxy=http://example-proxy:80/"
    - regexp: "^https_proxy="
      line: "https_proxy=https://example-proxy:443/"
    - regexp: "^ftp_proxy="
      line: "ftp_proxy=http://example-proxy:80/"
```

Nous pouvons tester les variables d'environnement distantes à l'aide de la commande ansible :

```
ansible multi -m shell -a 'echo $ENV_VAR'
```
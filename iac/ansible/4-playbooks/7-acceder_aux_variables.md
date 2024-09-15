# Accéder aux variables

- Des variables simples (définies avec Ansible, définies dans des fichiers d'inventaire ou définies dans des fichiers de playbook ou de variables) peuvent être utilisées dans le cadre d'une tâche à l'aide d'une syntaxe telle que **{{ variable }}** .

```
---
- hosts: multi
  become: no

  tasks:
  - name: Download docker script installation
    get_url:
      url: https://get.docker.com 
      dest: /home/vagrant/get-docker.sh
  - name: set docker script permission
    file:
      path: /home/vagrant/get-docker.sh
      mode: '0755'
  - name: get docker script permission
    command: "ls -lh /home/vagrant/get-docker.sh"
    register: file_detail
  - name: print docker script permission
    debug:
      msg: "/home/vagrant/get-docker.sh : {{ file_detail.stdout }}"
```

- Certaines variables sont structurées sous forme de tableaux (ou « listes »), et l’accès au tableau ne nous donnerait pas suffisamment d’informations pour être utile (sauf lors du passage du tableau dans un contexte où Ansible utilisera l’intégralité du tableau, comme lors de l’utilisation de **with_items**).

```
---
- hosts: multi
  become: no

  vars:
    log_system:
    - /var/log/syslog
    - /var/log/messages

  tasks: 
  - name: display log system file
    debug:
      msg: "Redhat : {{ log_system[1] }} et Ubuntu : {{ log_system|first }}"
```

La syntaxe **log_system[1]** utilise la syntaxe d'accès aux tableaux **Python** standard. Le premier index est **zéro**. <br>
La syntaxe **log_system|first** utilise un filtre pratique fourni par **Jinja**.

- On peut aussi accéder à certaines parties d'une variable tableau à l'aide de leur clé.

```
---
- hosts: multi
  become: no

  vars:
    log_system:
      rocky_log_system: /var/log/messages
      ubuntu_log_system: /var/log/syslog

  tasks:
  - name: display log system file
    debug:
      msg: "Redhat : {{ log_system.rocky_log_system }} et Ubuntu : {{ log_system['ubuntu_log_system'] }}"   
```

Nous pouvons par exemple d'abord consulter le contenu d'une variable avant de l'utiliser. Par exemple la variable **ansible_enp0s8** où **enp0s8** représente le nom d'une interface réseau sur nos serveurs vagrant Rocky.

```
---
- hosts: multi
  become: no

  tasks:
  - debug:
      var: ansible_enp0s8
```

Ensuite nous pouvons accéder à l'adresse IP de chaque serveur.

```
---
- hosts: multi
  become: no

  tasks:
  - name: display servers ipv4 and network addresses
    debug:
      msg: "Ipv4 : {{ ansible_enp0s8.ipv4.address }} - Network : {{ ansible_enp0s8['ipv4']['network'] }}" 
```
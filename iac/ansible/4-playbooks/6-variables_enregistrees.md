# Variables enregistrées

Il arrive souvent que nous souhaitons exécuter une commande, puis utiliser son code de retour, **stderr** ou **stdout** pour déterminer si nous souhaitons exécuter une tâche ultérieure. Pour ces situations, Ansible nous permet d'utiliser **register** pour stocker la sortie d'une commande particulière dans une variable au moment de l'exécution.

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
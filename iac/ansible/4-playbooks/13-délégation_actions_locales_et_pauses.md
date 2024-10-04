# Délégation, actions locales et pauses

Certaines tâches, comme l'envoi d'une notification, la communication avec les équilibreurs de charge ou la modification des serveurs DNS, réseau ou de surveillance, nécessitent qu'Ansible exécute la tâche sur la machine hôte (exécutant le playbook) ou sur un autre hôte en plus de celui(s) géré(s) par le playbook. Ansible permet de déléguer n'importe quelle tâche à un hôte particulier à l'aide de **delegate_to**. Si nous déléguons une tâche à **localhost**, nous pouvons utiliser **local_action**, au lieu de **delegate_to**.

- Playbook pour tester la connectivité internet depuis une machine spécifique de notre inventaire

```
---
- hosts: multi

  tasks:
  - name: test internet connectivity from the specific server db
    command: ping -c 4 google.com
    delegate_to: 192.168.56.7
```

- Playbook pour tester la connectivité internet depuis la machine locale

```
---
- hosts: multi

  tasks:
  - name: test internet connectivity from the local server
    local_action:
      module: command
      cmd: ping -c 4 google.com
```

### Suspendre l'exécution du playbook avec wait_for

```
---
- hosts: app
  become: yes
    
  tasks:
  - name: Install Nginx
    yum:
      name: nginx
      state: present

  - name: Start and enable Nginx
    service:
      name: nginx
      state: started
      enabled: yes
  
  - name: Wait for port 80 to be opened
    wait_for:
      port: 80
      host: 127.0.0.1
      timeout: 30
      state: started
    register: nginx_port_check

  - name: Show message when port 80 is open
    debug:
      msg: "Nginx is installed and listening on port 80"
    when: nginx_port_check.state == "started"
```

Le module **wait_for** renvoie plusieurs informations dans la variable enregistrée (**nginx_port_check**), dont l'état du port (**nginx_port_check.state**).

**wait_for** peut être utilisé pour mettre en pause l’exécution de notre playbook afin d’attendre de diverses conditions :
- en utilisant **host** et **port**, l'on attends un maximum de timeout secondes pour que le port soit disponible (ou non)
- en utilisant **path** (ou **search_regex**), l'on attends un maximum de timeout secondes pour que le fichier soit présent (ou absent)
- en utilisant **host** et **port** et **drained** pour le paramètre **state**, l'on vérifie si un port donné a vidé toutes ses connexions actives
- en utilisant **delay**, nous pouvons simplement suspendre l'exécution du playbook pendant une durée donnée (en secondes)

### Exécution d'un playbook complet localement

Lors de l'exécution de playbooks sur le serveur ou le poste de travail où les tâches doivent être exécutées (par exemple, l'auto-approvisionnement), ou lorsqu'un playbook doit être exécuté sur le même hôte que la commande **ansible-playbook**, nous pouvons utiliser **--connection=local** pour accélérer l'exécution du playbook en évitant la surcharge de connexion SSH.

```
vi current-system-date-playbook.yml
```

```
---
- hosts: 127.0.0.1
  gather_facts: no

  tasks:
  - name: Check the current system date.
    command: date
    register: date

  - name: Print the current system date.
    debug:
      var: date.stdout
```

```
ansible-playbook --connection=local current-system-date-playbook.yml
```

L'exécution d'un playbook avec **--connection=local** est également utile lorsque nous exécutons un playbook avec le mode **--check** pour vérifier la configuration, ou lorsque nous testons des playbooks sur une infrastructure de test (Jenkins, Gitlab CI, Github action,...).
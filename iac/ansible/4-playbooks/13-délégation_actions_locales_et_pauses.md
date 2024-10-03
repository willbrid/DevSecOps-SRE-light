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
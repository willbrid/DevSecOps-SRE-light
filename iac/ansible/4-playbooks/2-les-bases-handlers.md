# Les bases : Handlers

Quelques autres considérations à prendre en compte avec des **handlers** :

- Les **handlers** ne seront exécutés que si une tâche notifie le **handler** ; si une tâche qui aurait notifié les **handlers** est ignorée en raison d'une condition **when** ou quelque chose de similaire, le **handler** ne sera pas exécuté.

- Les handlers vont séxécuter une fois, et une seule fois, à la fin d'une tâche. Si nous avons absolument besoin de remplacer ce comportement et d'exécuter des **handlers** au milieu d'un playbook, nous pouvons utiliser le module **meta** pour le faire (par exemple - **meta: flush_handlers** ).

- Si une tâche échoue sur un hôte particulier (ou sur tous les hôtes) avant que les **handlers** ne soient notifiés, les **handlers** ne seront jamais exécutés. S'il est souhaitable de toujours exécuter les **handlers**, même après l'échec du playbook, nous pouvons utiliser le module **meta** en tant que tâche distincte dans le playbook, ou nous utilisons l'indicateur de ligne de commande **--force-handlers** lors de l'exécution de notre playbook. Les **handlers** ne s'exécuteront sur aucun hôte devenu inaccessible pendant l'exécution du playbook.

Exemple de tâche avec un handler : Redémarrer apache après une configuration qui lui est appliquée

```
---
  handlers:
  - name: restart apache
    service: name=apache2 state=restarted

  tasks:
  - name: Enable Apache rewrite module.
    apache2_module: name=rewrite state=present
    notify: restart apache
```

Exemple de tâche avec plusieurs handlers 

```
---
  handlers:
  - name: restart apache
    service: name=apache2 state=restarted

  - name: restart memcached
    service: name=memcached state=restarted  

  tasks:
  - name: Rebuild application configuration.
    command: /opt/app/rebuild.sh
    notify: 
    - restart apache
    - restart memcached
```

Pour notifier plusieurs handlers d'une tâche, utilisons une liste pour l'option **notify**.

Exemple d'un handler qui en notifie un autre

```
---
  handlers:
  - name: restart apache
    service: name=apache2 state=restarted
    notify: restart memcached

  - name: restart memcached
    service: name=memcached state=restarted
```

Pour qu'un **handler** en notifie un autre, il faudrait ajouter une option de notification (**notify**) au **handler**. Les **handlers** sont essentiellement des tâches glorifiées qui peuvent être appelées par l'option de notification (**notify**).
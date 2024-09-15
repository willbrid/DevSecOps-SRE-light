# Variables d'inventaire

Les variables peuvent également être ajoutées via des fichiers d'inventaire Ansible, soit en ligne avec une définition d'hôte, soit après un groupe.

```
[app]
192.168.56.4 proxy_state=present
192.168.56.5 proxy_state=absent

[db]
192.168.56.7

[multi:children]
app
db

[app:vars]
api_version=v1
```

**La documentation d’Ansible recommande de ne pas stocker de variables dans l’inventaire**. À la place, nous pouvons utiliser les fichiers de variables YAML **group_vars** et **host_vars** dans un chemin spécifique, et Ansible les affectera aux hôtes et groupes individuels définis dans notre inventaire :

- par exemple, pour appliquer un ensemble de variables à l'hôte **192.168.56.4** , l'on peut créer un fichier nommé **192.168.56.4** à l'emplacement **/etc/ansible/host_vars/192.168.56.4** et ajouter des variables

```
---
app_log_dir: /var/log/app
app_version: 0.0.1
```

- par exemple, pour appliquer un ensemble de variables à l'ensemble du groupe **multi**,  l'on peut créer un fichier nommé **multi** à l'emplacement **/etc/ansible/group_vars/multi** et ajouter des variables

```
---
log_system: /var/log/messages
```

Nous pouvons également placer ces fichiers dans les répertoires **host_vars** ou **group_vars** du répertoire de notre playbook. Ansible utilisera d’abord les variables définies dans le répertoire d’inventaire **/etc/ansible/[host|group]_vars** (si les fichiers appropriés existent), puis il utilisera les variables définies dans les répertoires du playbook.
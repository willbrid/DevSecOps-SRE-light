# Inventaires

### Définition d'inventaire

Supposons que nous avons notre repertoire de projet **$HOME/ansible**. <br>
Supposons aussi que nous avons notre fichier d'inventaires **hosts.ini** :

```
[myapp]
www.myapp.com
```

Si nous souhaitons exécuter un playbook Ansible sur tous les serveurs **myapp** de cet inventaire, nous pouvons configurer le playbook comme suit :

```
---
- hosts: myapp
  
  tasks:
    [...]
```

Si nous souhaitons exécuter une commande **adhoc** sur tous les serveurs **myapp** de l'inventaire, nous pouvons exécuter une commande comme suit :

```
ansible -i hosts.ini myapp -a "free -m"
```

Nous pouvons aussi définir nos inventaires par environement (**prod**, **preprod**, **dev**). Ainsi supposons notre repertoire **servercheck** de notre playbook. Un exemple de structure de notre projet ansible serait d'avoir :

```
servercheck/
  inventories/
    inventory-prod
    inventory-prepaod
    inventory-dev
  playbook.yml
```

Maintenant, lors de l'exécution du fichier **playbook.yml** pour configurer l'infrastructure de développement, nous transmettons le chemin vers l'inventaire de développement.

```
ansible-playbook playbook.yml -i inventories/inventory-dev
```

### Variables d'inventaire

Ansible fournit un moyen plus flexible de déclarer des variables d’**hôte** et de **groupe**.

- **host_vars**

La manière la plus simple de dire à Ansible de remplacer une variable par défaut dans notre playbook Ansible est d'utiliser un répertoire **host_vars** (qui peut être placé soit au même endroit que notre fichier d'inventaire, soit dans le répertoire racine d'un playbook), et de placer un fichier YAML nommé d'après l'hôte qui a besoin de la variable remplacée. <br>
Pour illustrer l'utilisation de **host_vars**, nous supposerons que nous avons la disposition de répertoire suivante :

```
app/
  host_vars/
    server-app1.yml
    server-app2.yml
  inventory/
    hosts
  main.yml
```

Le fichier **app/inventory/hosts** contient une définition simple de tous les serveurs par groupe :

```
[app]
server-app1
server-app2
server-app3
...

[log]
server-log
```

Ansible recherchera un fichier à l'un des endroits suivants : **app/host_vars/server-app1.yml**, **app/inventory/host_vars/server-app1.yml**. <br>
S'il y a des variables définies dans le fichier (au format YAML), ces variables remplaceront toutes les autres variables du playbook et du rôle et les facts collectés, uniquement pour l'hôte unique.

```
# app/host_vars/server-app1.yml
app_name: "cookbook"
```

Le remplacement des variables d'hôte avec **host_vars** est beaucoup plus facile à gérer que de le faire directement dans des fichiers d'inventaire statiques, et offre également une meilleure visibilité sur les hôtes qui obtiennent les remplacements.

- **group_vars**

Ansible charge automatiquement tous les fichiers nommés d’après les groupes d’inventaire dans un répertoire **group_vars** placé à l’intérieur du playbook ou de l’emplacement du fichier d’inventaire.

```
app/
  group_vars/
    app.yml
    log.yml
  host_vars/
    server-app1.yml
    server-app2.yml
  inventory/
    hosts
  main.yml
```

Ensuite, dans **group_vars/app.yml**, on utilise le format yaml pour définir une liste de variables qui seront appliquées aux serveurs du groupe **app** de l'inventaire **app/inventory/hosts** :

```
---
do_something_amazing: true
foo: bar
```
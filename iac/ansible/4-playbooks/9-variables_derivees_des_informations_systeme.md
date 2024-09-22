# Variables dérivées des informations système

Par défaut, chaque fois que nous exécutons un playbook Ansible, Ansible collecte d'abord des informations (**faits**) sur chaque hôte de l'inventaire. Avec les **faits**, nous pouvons utiliser les informations collectées telles que les adresses IP des hôtes, le type de processeur, l'espace disque, les informations sur le système d'exploitation et les informations sur l'interface réseau. 
Pour obtenir une liste de tous les faits collectés disponibles, nous pouvons utiliser la commande ansible avec le module **setup**.

```
ansible multi -m setup
```

Si nous n’avons pas besoin d’utiliser des faits et que nous souhaitons économiser quelques secondes par hôte lors de l’exécution de playbooks (cela peut être particulièrement utile lors de l’exécution d’un playbook Ansible sur des dizaines ou des centaines de serveurs), nous pouvons définir "**gather_facts: no**" dans notre playbook.

```
- hosts: multi
  gather_facts: no
  become: no

  tasks:
  - name: display groups variable
    debug:
      msg: "groups : {{ groups }}"
```

Une autre façon de définir des faits spécifiques à l'hôte consiste à placer un fichier "**.fact**" dans un répertoire spécial sur les hôtes distants, **/etc/ansible/facts.d/**. Ces fichiers peuvent être des fichiers JSON ou INI, 
Par exemple nous pouvons créer le fichier **/etc/ansible/facts.d/settings.fact** sur le serveur de base de données.

Nous nous connectons sur le serveur de base de données, puis nous créons le fichier **/etc/ansible/facts.d/settings.fact**

```
vagrant ssh db
```

```
sudo mkdir -p /etc/ansible/facts.d
```

```
sudo vi /etc/ansible/facts.d/settings.fact
```

```
[users]
admin=vagrant
```

Depuis la machine hôte où Ansible est installé et dans le répertoire contenant nos fichiers d'inventaire, nous exécutons la commande

```
ansible db -m setup -a "filter=ansible_local"
```

Si nous utilisons un playbook pour provisionner un nouveau serveur et qu'une partie de ce playbook ajoute un fichier "**.fact**" local qui génère des faits locaux qui sont utilisés ultérieurement, nous pouvons indiquer explicitement à Ansible de recharger les faits locaux à l'aide d'une tâche comme celle-ci :

```
- hosts: multi
  
  tasks:
  - name: Reload local facts
    setup: filter=ansible_local
```
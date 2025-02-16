# Ansible-Galaxy

Les rôles **Ansible** sont puissants et flexibles ; ils nous permettent d'encapsuler des ensembles de configuration et des unités déployables de playbooks, de variables, de modèles et d'autres fichiers, afin que nous puissions facilement les réutiliser sur différents serveurs.

**Ansible Galaxy** est un référentiel de contenu **Ansible** fourni par la communauté. Il existe des milliers de rôles disponibles qui peuvent configurer et déployer des applications courantes, et ils sont tous disponibles via la commande **ansible-galaxy**.

**Galaxy** offre la possibilité d'ajouter, de télécharger et d'évaluer des rôles. Avec un compte, nous pouvons contribuer à nos propres rôles ou évaluer ceux des autres. Cependant nous n'avons pas besoin d'un compte pour utiliser les rôles.

### Obtenir des rôles de Galaxy

Ajoutons un rôle ansible

```
ansible-galaxy role install geerlingguy.apache
```

Ajoutons plusieurs rôles ansible

```
ansible-galaxy role install geerlingguy.apache geerlingguy.mysql geerlingguy.php
```

La dernière version d'un rôle sera téléchargée si aucune version n'est spécifiée. Pour spécifier une version, on ajoute après le nom du rôle séparé d'une virgule.

```
ansible-galaxy role install geerlingguy.apache,4.0.0
```

Les rôles ansible téléchargés sont stockés dans le repertoire **$HOME/.ansible/roles**.

### Utilisation des fichiers d'exigences de rôle pour gérer les dépendances

Les rôles de dépendances peuvent être définis dans un fichier d'exigence au format **yaml**, qui nous permet d'installer des rôles depuis **Ansible Galaxy**, **GitHub**, un **téléchargement HTTP**, **BitBucket** ou notre **propre référentiel**. Il nous permet également de spécifier le chemin dans lequel les rôles doivent être téléchargés.


```
vi requirements.yml
```

```
---
roles:
  - name: geerlingguy.firewall
  
  - name: geerlingguy.php
    version: 6.0.0
  
  - src: https://github.com/geerlingguy/ansible-role-passenger
    name: passenger
    version: 2.0.0
  
  - src: https://www.example.com/ansible/roles/my-role-name.tar.gz
    name: my-role  
```

Pour installer les rôles définis dans un fichier d'exigences, utiliser la commande :

```
ansible-galaxy install -r requirements.yml
```

Pour installer les rôles définis dans un fichier d'exigences dans un repertoire **roles** (en supposant que **$HOME/installation** est notre repertoire de playbooks), utiliser la commande :

```
ansible-galaxy install -r requirements.yml --roles-path $HOME/installation/roles
```

### Commandes Galaxy utiles

- Commande pour afficher une liste des rôles installés, avec les numéros de version

```
ansible-galaxy role list
```

- Commande pour supprimer un rôle installé

```
ansible-galaxy role remove [rolename]
```

- Commande pour créer un modèle de rôle adapté à la soumission à **Ansible Galaxy**

```
ansible-galaxy role init [rolename]
```

Nous pouvons configurer le chemin par défaut où les rôles Ansible seront téléchargés en modifiant notre fichier de configuration **ansible.cfg** et en définissant un **roles_path** dans la section **[defaults]**.

Il est récommandé de nommer les rôles Galaxy de la forme **ansible-role-[rolename]**.
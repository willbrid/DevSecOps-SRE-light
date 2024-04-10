# Introduction

Les playbooks sont écrits en YAML, une syntaxe simple et lisible pour définir la configuration. Les playbooks peuvent être inclus dans d'autres playbooks, et certaines métadonnées et options entraînent l'exécution de différentes playbooks dans différents scénarios sur différents serveurs.

Exemple :

```
vi playbook.yml
```

```
---
- hosts: all
  become: yes

  tasks:
  - name: Install Apache.
    yum:
      name:
      - httpd
      - httpd-devel
      state: present

  - name: Copy configuration files.
    copy:
      src: "{{ item.src }}"
      dest: "{{ item.dest }}"
      owner: root
      group: root
      mode: 0644
    with_items:
    - src: httpd.conf
      dest: /etc/httpd/conf/httpd.conf
    - src: httpd-vhosts.conf
      dest: /etc/httpd/conf/httpd-vhosts.conf      
```

Pour exécuter ce fichier Playbook, nous devons l'appeler à l'aide de la commande **ansible-playbook** :

```
ansible-playbook playbook.yml
```

Parlons de cet exemple de playbook.

- La première ligne, **---** , indique que nous utilisons la syntaxe YAML.

- La deuxième ligne, **- hosts: all** définit la première tâche et indique à Ansible d'exécuter la tâche sur tous les hôtes qu'il connaît.

- La troisième ligne **become : yes** indique à Ansible d'exécuter toutes les commandes via **sudo** afin que les commandes soient exécutées en tant qu'utilisateur root.

- La cinquième ligne **task :** indique à Ansible que ce qui suit est une liste de tâches à exécuter dans le cadre de ce processus. <br>

--- La première tâche commence par le **name : Install Apache**. **name** c'est une façon de donner une description, mais si nous supprimons complètement la ligne de **name**, cela ne posera aucun problème.<br>

--- La deuxième tâche commence à nouveau avec un **name**. <br>

• Nous utilisons le module **copy** pour copier des fichiers d'une source (sur notre poste de travail local) vers une destination (le serveur distant). Nous pourrions également transmettre davantage de variables, telles que les métadonnées de fichier, y compris la propriété et les autorisations ( **owner** , **group** et **mode** ). <br>
• Ansible permet de passer des listes de variables dans des tâches en utilisant **with_items** : définissant une liste d'éléments et chacun sera transmis au jeu, référencé à l'aide de la variable d'élément (par exemple **{{ élément }}** ). Dans ce cas, nous utilisons une liste d'éléments contenant des dicts (dictionnaires) utilisés pour la substitution de variables ; pour définir chaque élément dans une liste de dicts avec chaque élément de liste au format :

```
- var1 : valeur
  var2 : valeur
```

## Limiter les playbooks à des hôtes et groupes particuliers

Nous pouvons limiter un playbook à des groupes spécifiques ou à des hôtes individuels en modifiant la définition de l'option **hosts:**. La valeur peut être définie sur tous les hôtes, un groupe d'hôtes défini dans notre inventaire, plusieurs groupes d'hôtes (par exemple, des serveurs Web, des serveurs de base de données), des hôtes individuels ou un mélange d'hôtes. Nous pouvons même faire des correspondances avec des caractères génériques, comme ***.example.com** , pour faire correspondre tous les sous-domaines d'un domaine de premier niveau. Nous pouvons également limiter les hôtes sur lesquels le playbook est exécuté via la commande **ansible-playbook**.

```
ansible-playbook playbook.yml --limit webservers
```

Dans ce cas (en supposant que notre fichier d'inventaire contient un groupe de serveurs Web appelé **webservers**), même si le playbook est défini sur **hosts: all** , ou inclut des hôtes en plus de ce qui est défini dans le groupe de serveurs Web, il ne sera exécuté que sur les hôtes définis dans le groupe de serveurs Web . <br>

Nous pouvons également limiter le playbook à un hôte particulier :

```
ansible-playbook playbook.yml --limit xyz.example.com
```

Si nous voulons voir une liste des hôtes qui seraient affectés par notre playbook avant de l'exécuter, utilisons **--list-hosts** :

```
ansible-playbook playbook.yml --list-hosts
```

## Définir des options utilisateur et sudo avec ansible-playbook

Si aucun **remote_user** n'est défini à côté des hôtes dans un playbook, Ansible suppose que nous nous connecterons en tant qu'utilisateur défini dans notre fichier d'inventaire pour un hôte particulier, puis reviendra à notre nom de compte d'utilisateur local. 
<br>

Nous pouvons explicitement définir un utilisateur distant à utiliser pour les tâches à distance à l'aide de l'option **--user ( -u )** :

```
ansible-playbook playbook.yml --user=johndoe
```

Dans certaines situations, nous devons transmettre notre **mot de passe sudo** au serveur distant pour exécuter des commandes via **sudo** . Dans ces situations, nous devons utiliser :

```
--ask-become-pass ( -K )
```

Nous pouvez également forcer explicitement toutes les tâches d'un playbook à utiliser sudo avec 

```
--become ( -b )
```

Enfin, nous pouvons définir l'utilisateur **sudo** pour les tâches exécutées via sudo (la valeur par défaut est **root**) avec l'option 

```
--become-user
```

Par exemple, la commande suivante exécutera notre exemple de playbook avec **sudo**, en effectuant les tâches en tant qu'utilisateur **sudo janedoe** , et Ansible nous demandera le mot de passe **sudo** :

```
ansible-playbook playbook.yml --become --become-user=janedoe --ask-become-pass
```

Si nous n'utilisons pas l'authentification par clé pour nous connecter à nos serveurs, nous pouvons utiliser 

```
--ask-pass
```

## Autres options pour ansible-playbook

La commande **ansible-playbook** permet également d'autres options courantes : <br>

- **--inventory=PATH ( -i PATH )** : définir un fichier d'inventaire personnalisé (par défaut, le fichier d'inventaire Ansible par défaut, généralement situé dans /etc/ansible/hosts ).

- **--verbose ( -v )** : mode verbeux (affiche toute la sortie, y compris la sortie des options réussies). Nous pouvons passer **-vvvv** pour donner chaque détail.

- **--extra-vars=VARS ( -e VARS )** : définir les variables à utiliser dans le playbook, au format "clé=valeur, clé=valeur".

- **--forks=NUM ( -f NUM )** : nombre de processus (entier). Définissons-le sur un nombre supérieur à 5 pour augmenter le nombre de serveurs sur lesquels Ansible exécutera des tâches simultanément.

- **--connection=TYPE ( -c TYPE )** : le type de connexion qui sera utilisé (par défaut, c'est **ssh** ; vous voudrez peut-être parfois utiliser local pour exécuter un playbook sur notre machine locale ou sur un serveur distant via cron) .

- **--check** : Exécuter le playbook en mode de vérification ("Dry Run") ; toutes les tâches définies dans le playbook seront vérifiées par rapport à tous les hôtes, mais aucune ne sera réellement exécutée.
# Introduction aux commandes adhoc

Nous pouvons nous assurer que Vagrant a configuré les machines virtuelles avec les bons noms d'hôte. Utilisons ansible avec l'argument **-a 'hostname'** pour exécuter la commande **hostname** sur tous les serveurs.

```
ansible multi -a "hostname"
```

ou alors 

```
ansible multi -m command -a "hostname"
```

1- **multi** est le nom du groupe de serveurs défini dans le fichier **hosts.ini** <br>
2- L'option **-a** permet de préciser le nom de la commande à exécuter <br>
3- L'option **-m** permet de préciser le module ansible à utiliser. Par défaut s'il n'est pas précisé alors c'est le module **command** <br>

Si Ansible signale aucun hôte correspondant ou renvoie une autre erreur liée à l'inventaire, il se peut que le fichier **ansible.cfg** ne se trouve pas dans le bon répertoire ou que la syntaxe ne soit pas correcte. Nous pouvons également essayer de remplacer le chemin du fichier d'inventaire en définissant explicitement la variable d'environnement **ANSIBLE_INVENTORY**.

```
export ANSIBLE_INVENTORY=hosts.ini
```
En supposant que nous avons omis la ligne **host_key_checking = false** dans notre fichier **ansible.cfg**, si nous obtenons une erreur telle que l'authenticité de l'hôte **'192.168.56.4'** ne peut pas être établie, cela est dû au fait que SSH dispose d'une fonction de sécurité qui nous oblige à confirmer la « clé d'hôte » du serveur la première fois que nous nous connectons. Nous pouvons taper **yes** sur la ligne de commande (dans ce cas 3 fois pour les 3 serveurs) pour ignorer l'avertissement et accepter la clé d'hôte, ou nous pouvons également définir la variable d'environnement **ANSIBLE_HOST_KEY_CHECKING=False**, ou nous pouvons ajouter la ligne **host_key_checking = false** dans notre fichier **ansible.cfg**. Le comportement d'acceptation de la clé d'hôte peut également être configuré dans notre fichier de configuration SSH.
<br>

Par défaut, Ansible exécutera nos commandes en parallèle, en utilisant plusieurs forks de processus, afin que la commande se termine plus rapidement. Nous pouvons exécuter à nouveau la même commande, mais cette fois en ajoutant l'argument **-f 1** pour indiquer à Ansible de n'utiliser qu'un seul fork (essentiellement, pour exécuter la commande sur chaque serveur de manière séquentielle).

```
ansible multi -a "hostname" -f 1
```

- Assurons-nous que les serveurs ont de l'espace disque disponible pour notre application.

```
ansible multi -a "df -h"
```

- Assurons-nous également qu'il y a suffisamment de mémoire sur nos serveurs.

```
ansible multi -a "free -m"
```

- Assurons-nous que la date et l'heure de chaque serveur sont synchronisées

```
ansible multi -a "date"
```

- Pour obtenir une liste exhaustive de tous les détails de l'environnement pour un serveur particulier (ou pour un groupe de serveurs), utilisons la commande **ansible [host-or-group] -m setup** . Cela fournira une liste de chaque minute de détail sur le serveur (y compris les systèmes de fichiers, la mémoire, le système d'exploitation, les interfaces réseau…).

```
ansible multi -m setup
```

- Nous voulons installer le démon **chrony** sur le serveur pour synchroniser l'heure. Au lieu d'exécuter la commande **yum install -y chrony** sur chacun des serveurs, nous utiliserons le module **yum** d'ansible pour faire de même.

```
ansible multi -b -m yum -a "name=chrony state=present"
```

Nous devrions voir trois messages "CHANGED" et la sortie de la commande d'installation. Si nous exécutons à nouveau la commande, nous verrons trois messages "SUCCESS", car le package est déjà installé.
L'option **-b** (alias pour **--become** ) indique à Ansible d'exécuter la commande avec **Become** (signifiant exécuter les commandes avec 'sudo'). Cela fonctionnera bien avec nos machines virtuelles Vagrant, mais si nous exécutons des commandes sur un serveur où notre compte utilisateur nécessite un mot de passe pour l'élévation des privilèges, nous devons également transmettre l'option **-K** (alias pour **--ask-become-pass**), donc nous pouvons saisir notre mot de passe lorsqu'ansible en a besoin.

- Assurons-nous que le démon **chrony** est démarré et configuré pour s'exécuter au démarrage en utilisant le module **service**

```
ansible multi -b -m service -a "name=chronyd state=started enabled=yes"
```

- Assurons-nous que nos serveurs sont étroitement synchronisés avec l'heure officielle sur un serveur de temps

```
ansible multi -b -a "chronyc tracking"
```
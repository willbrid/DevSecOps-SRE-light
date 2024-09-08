# Fichier d'inventaire pour plusieurs serveurs

Il existe de nombreuses façons d'informer Ansible des serveurs que nous gérons, mais la plus standard et la plus simple consiste à les ajouter à un fichier d'inventaire que nous stockons avec notre projet Ansible.

Nous pouvons spécifier le chemin d'accès au fichier d'inventaire sur la ligne de commande en utilisant **-i hosts.ini** . Mais nous pouvons éviter d'avoir à spécifier ce chemin à chaque fois que nous exécutons des commandes ansible en spécifiant le chemin vers le fichier d'inventaire dans un fichier **ansible.cfg** qui est également stocké dans le répertoire racine (**ansible-test**) de notre projet.

- Définissons notre fichier **ansible.cfg**

```
vi ansible.cfg
```

```
[defaults]
inventory = hosts.ini
host_key_checking = false
```

- Définissions notre fichier **hosts.ini**

```
vi hosts.ini
```

```
# Serveurs d'application
[app]
192.168.56.4
192.168.56.5

# Serveur de base de données
[db]
192.168.56.7

# Groupe 'multi' avec tous les serveurs
[multi:children]
app
db

# Variables qui seront appliquées à tous les serveurs
[multi:vars]
ansible_user=vagrant
ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key
```

1. Le premier bloc place nos deux serveurs d'applications dans un groupe "app". <br>
2. Le deuxième bloc place le serveur de base de données dans un groupe "db". <br>
3. Le troisième bloc indique à ansible de définir un nouveau groupe "multi", avec le sous-groupe "children", et nous ajoutons à la fois les groupes "app" et "db". <br>
4. Le quatrième bloc ajoute des variables au groupe "multi" qui seront appliquées à tous les serveurs du groupe "multi" et à tous ses sous-groupes.
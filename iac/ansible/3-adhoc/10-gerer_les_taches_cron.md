# Gérer les tâches cron

Ansible facilite la gestion des tâches cron avec son module **cron**. Si nous souhaitons exécuter un script shell sur tous les serveurs qui s'exécute à chaque minute, ajoutons une tâche cron.

Créeons un fichier **minute-script.sh** qui enregistre la date courante dans un fichier **current_date** du répertoire **/tmp**

```
vi /tmp/minute-script.sh
```

```
#!/bin/bash

date > /tmp/current_date
```

copions ce script via ansible dans nos serveurs au niveau du repertoire **/opt**

```
ansible multi -b -m copy -a "src=/tmp/minute-script.sh dest=/opt/minute-script.sh"
```

créons notre cronjob

```
ansible multi -b -m cron -a "name='minute-cron-all-servers' minute=* job='sh /opt/minute-script.sh'"
```

Ansible assumera * pour toutes les valeurs que nous ne spécifions pas (les valeurs valides sont **day** , **hour** , **minute** , **month** et **weekday** ). Nous pouvons également spécifier des valeurs de temps spéciales telles que **reboot** , **yearly** ou **month** en utilisant **special_time=[value]** . Nous pouvons également définir l'utilisateur sous lequel le job sera exécuté via **user=[user]** , et créer une sauvegarde de la crontab actuelle en passant **backup=yes** . <br>
Et si nous voulons supprimer la tâche cron, utilisons le même module **cron** et transmettons le nom de la tâche cron que nous souhaitons supprimer, et **state=absent** :

```
ansible multi -b -m cron -a "name='minute-cron-all-servers' state=absent"
```

Nous pouvons également utiliser Ansible pour gérer les fichiers **crontab** personnalisés ; utilisons la même syntaxe que précédemment, mais spécifions l'emplacement du fichier cron avec : **cron_file=cron_file_name** (où cron_file_name est un fichier cron situé dans **/etc/cron.d** ).
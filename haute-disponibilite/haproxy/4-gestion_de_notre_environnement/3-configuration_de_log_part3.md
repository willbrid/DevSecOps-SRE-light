# Configuration de logs [part3]

Nous allons configurer la rotation des logs sous HAProxy.

- Créons le fichier **/etc/logrotate.d/haproxy** pour la configuration de la rotation de log HAProxy pour tous les fichiers de log de haproxy dans le repertoire **/var/log**

```
sudo vi /etc/logrotate.d/haproxy
```

```
/var/log/haproxy*.log {
    daily
    rotate 365
    missingok
    notifempty
    compress
    size 300M
    delaycompress
    sharedscripts
    postrotate
        systemctl reload rsyslog.service > /dev/null 2>&1 || true
    endscript
}
```

--- **daily** : indique que la rotation des journaux doit se produire une fois par jour. Cela signifie que chaque jour, un nouveau fichier journal est créé et l'ancien fichier est renommé avec une extension de date. <br>

--- **rotate 365** indique que jusqu'à 365 fichiers journaux peuvent être conservés, au-delà de cela, les fichiers les plus anciens seront supprimés. <br>

--- **missingok** signifie que si le fichier journal n'existe pas, il ne doit pas y avoir d'erreur et la rotation du journal doit continuer. <br>

--- **notifempty** signifie que si le journal est vide après la rotation, aucune action ne doit être prise. <br>

--- **compress** indique que les fichiers journaux doivent être compressés à l'aide de gzip. <br>

--- **size 300M** signifie que chaque fichier de log ne doit pas dépasser une taille de 300 mégaoctets (Mo). Lorsque la limite de taille est atteinte, logrotate archive le fichier en cours et crée un nouveau fichier de journal pour continuer l'enregistrement des données. Cela permet d'éviter que les fichiers logs ne deviennent trop volumineux et ne surchargent le système de stockage. <br>

--- **delaycompress** indique que la compression du journal ne doit pas se produire immédiatement après la rotation, mais plutôt lors de la prochaine rotation. <br>

--- **sharedscripts** indique que les scripts postrotation et prerotation ne doivent être exécutés qu'une seule fois pour l'ensemble des fichiers journaux concernés. <br>

--- **postrotate** contient les commandes à exécuter après la rotation des journaux. Dans ce cas, la commande "systemctl reload rsyslog.service" est utilisée pour recharger le service rsyslog afin qu'il commence à écrire dans le nouveau fichier journal. <br>

--- **endscript** indique la fin du script de postrotation.

- Après avoir modifié le fichier de configuration de logrotate, nous pouvons tester si la rotation des journaux fonctionne correctement en utilisant la commande suivante :

```
sudo logrotate -d -v /etc/logrotate.d/haproxy
```

- Redémarrons **Rsyslog** pour activer les changements et vérifions son statut

```
sudo systemctl restart rsyslog
sudo systemctl status rsyslog
```
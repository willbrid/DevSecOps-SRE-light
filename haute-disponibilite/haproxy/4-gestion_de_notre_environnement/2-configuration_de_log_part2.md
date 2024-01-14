# Configuration de logs [part2]

La configuration des logs de haproxy fera l'objet de plusieurs étapes.

- Configuration de haproxy pour rsyslog

```
sudo vi /etc/rsyslog.d/99-haproxy.conf
```

```
# Listen for log data on 127.0.0.1, port 514, using UDP
$ModLoad imudp
$UDPServerAddress 127.0.0.1
$UDPServerRUN 514

# Create two log files, based on severity
local0.* /var/log/haproxy-traffic.log
local0.notice /var/log/haproxy-admin.log
```

--- **$ModLoad imudp** : cette ligne permet de charger le module de logiciel côté serveur qui permet à **rsyslog** de recevoir les messages envoyés via UDP. <br>
--- **$UDPServerAddress 127.0.0.1** : cette ligne permet de définir l'adresse IP sur laquelle le serveur **rsyslog** doit être en écoute pour les messages UDP entrants, dans ce cas-ci, le serveur syslog est configuré pour écouter seulement sur l'interface de loopback (localhost). <br>
--- **$UDPServerRUN 514** : cette ligne permet d'indiquer le port sur lequel le serveur **rsyslog** doit écouter les messages UDP entrants. Dans ce cas-ci, le port choisi est le standard 514. <br>
--- **local0.\* /var/log/haproxy-traffic.log** : cette ligne permet de rediriger tous les messages "local0" (niveau de priorité "notice" ou plus bas) vers le fichier "/var/log/haproxy-traffic.log". Les messages relatifs au trafic traité par HAProxy seront écrits dans ce fichier. <br>
--- **local0.notice /var/log/haproxy-admin.log** : cette ligne permet de rediriger tous les messages "local0.notice" vers le fichier "/var/log/haproxy-admin.log". Les messages d'administration et de suivi de HAProxy seront écrits dans ce fichier. <br>

Nous redemarrons notre service rsyslog et nous vérifions son statut

```
sudo systemctl restart rsyslog
sudo systemctl status rsyslog
```

- Configuration de haproxy pour envoyer les logs vers notre serveur rsyslog

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
global
  ...
  # Configuration de rsyslog
  log 127.0.0.1:514 local0 # La ligne *log stderr local0 info* a été remplacée
  ...
```

Nous redemarrons notre service haproxy et nous vérifions son statut

```
sudo systemctl restart haproxy
```

Si nous listons les fichiers de log haproxy dans le répertoire **/var/log/**, nous verrons nos deux fichiers **haproxy-traffic.log** et **haproxy-admin.log**.

```
ls -la /var/log/haproxy*
```

Nous pouvons générer du trafic http sur notre serveur **client** sur les deux sites et du trafic ssh.

```
wget --no-check-certificate -O - https://www.site1.com/test.txt
wget --no-check-certificate -O - https://www.site2.com/test.txt
sshpass -p "vagrant" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P 2225 vagrant@192.168.56.8:/home/vagrant/sshfiles/ssh-test.txt .
```

Nous observerons nos requêtes dans le fichier **/var/log/haproxy-traffic.log**

```
sudo tail -n 50 /var/log/haproxy-traffic.log
```

- Configuration améliorée des logs haproxy

Nous mettons à jour notre fichier **/etc/rsyslog.d/99-haproxy.conf** pour **rsyslog** afin de : <br>
--- configurer le fichier de logs admin **/var/log/haproxy-admin.log** pour tout recevoir <br>
--- configurer le fichier de logs info **/var/log/haproxy-combined-traffic.log** pour recevoir le trafic tcp et http combiné <br>
--- configurer le fichier de logs info **/var/log/haproxy-http-traffic.log** pour recevoir uniquement le trafic http <br>
--- configurer le fichier de logs info **/var/log/haproxy-tcp-traffic.log** pour recevoir uniquement le trafic tcp

```
sudo vi /etc/rsyslog.d/99-haproxy.conf
```

```
...
# Create four log files, based on severity
local0.info /var/log/haproxy-combined-traffic.log
local0.* /var/log/haproxy-admin.log
local1.info /var/log/haproxy-http-traffic.log
local2.info /var/log/haproxy-tcp-traffic.log
```

Nous configurons sur haproxy les logs http pour le frontend **http-https-in** et les logs tcp pour le frontend **ssh-in**.

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
...
frontend http-https-in
  log 127.0.0.1:514 local1
  ...

frontend ssh-in
  log 127.0.0.1:514 local2
  ...
...  
```

Nous stoppons le service **rsyslog**, nous supprimons les anciens fichiers de log, puis nous demarrons à nouveau **rsyslog**

```
sudo systemctl stop rsyslog
sudo rm /var/log/haproxy*
sudo systemctl start rsyslog
```

Nous redemarrons le service haproxy et vérifions son statut

```
sudo systemctl restart haproxy
sudo systemctl status haproxy
```

Nous générons encore du trafic à nouveau

```
wget --no-check-certificate -O - https://www.site1.com/test.txt
wget --no-check-certificate -O - https://www.site2.com/test.txt
sshpass -p "vagrant" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P 2225 vagrant@192.168.56.8:/home/vagrant/sshfiles/ssh-test.txt .
```

Nous vérifions la présence de nos 4 fichiers de log

```
ls -al /var/log/haproxy*
```

Nous pouvons afficher le contenu de ces fichiers afin de vérifier effectivement qu'il sauvegarde les trafics spécifiques.

```
sudo tail /var/log/haproxy-admin.log
sudo tail /var/log/haproxy-combined-traffic.log
sudo tail /var/log/haproxy-http-traffic.log
sudo tail /var/log/haproxy-tcp-traffic.log
```

Nous pouvons aussi stopper un conteneur et vérifier que les logs précisant l'indisponibilité d'un backend sont bien générés uniquement dans le fichier **/var/log/haproxy-admin.log**.

```
podman container stop site1_server2
sudo tail /var/log/haproxy-admin.log
```
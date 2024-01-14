# Utilisation de HAProxy pour protéger le service SSH

SSH est l'un des services qui fait l'objet d'attaques constantes. Nous allons ajouter quelques lignes à notre configuration HAProxy et mettre notre service SSH de notre serveur **server** sous sa protection.

- Exposons d'abord notre service SSH via HAProxy sous le port **2225**

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
# Frontend for SSH
frontend ssh-in
  bind *:2225
  mode tcp
  option tcplog
  default_backend sshd-server

# Backend for SSH
backend sshd-server
  mode tcp
  server sshd-server 127.0.0.1:22 check
```

La ligne **option tcplog** au niveau du bloc frontend active la journalisation des requêtes TCP. Cela signifie que chaque requête entrante sera enregistrée dans les fichiers de logs afin de pouvoir être consultée ultérieurement à des fins de diagnostic ou d'analyse. <br>
Le paramètre **check** du backend permet de vérifier l'état de santé du serveur ssh. <br>

- Redemarrons le service haproxy

```
sudo systemctl restart haproxy
```

- Créons le repertoire **sshfiles** et son fichier **ssh-test.txt** sur notre serveur **server**

```
mkdir ~/sshfiles
figlet -f big SSH - TEST > ~/sshfiles/ssh-test.txt
```

- Autorisons le port 2225 sur le parefeu de notre serveur **server**

```
sudo firewall-cmd --permanent --add-port=2225/tcp
sudo firewall-cmd --reload
```

- Faisons un test de copie du fichier **ssh-test.txt** depuis notre serveur **client** sur le port **2225**

```
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P 2225 vagrant@192.168.56.8:/home/vagrant/sshfiles/ssh-test.txt .
```

Si tout se passe bien, le fichier **ssh-test.txt** sera copié sur notre serveur **client**.

- Installons sshpass sur notre serveur **client** et créons un script permettant de faire 1000 requêtes de cette action de copier depuis notre serveur **client**

```
sudo dnf install sshpass
```

```
vi copyFile.sh
```

```
#!/bin/bash

for conn in `seq 1000`
do
  bash -c 'sshpass -p "vagrant" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P 2225 vagrant@192.168.56.8:/home/vagrant/sshfiles/ssh-test.txt . &'
done
```

```
chmod +x copyFile.sh
```

Nous pouvons à présent exécuter notre script

```
./copyFile.sh
```

- Mettons à jour notre configuration HAProxy sur notre serveur **server** afin de protéger notre service SSH

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
# Frontend for SSH
frontend ssh-in
  bind *:2225
  mode tcp
  option tcplog
  timeout client 1m
  tcp-request content track-sc0 src table ssh_per_ip_connections
  tcp-request content reject if { sc_conn_cur(0) gt 2 } || { sc_conn_rate(0) gt 10 }
  default_backend sshd-server

# Backend for ssh_per_ip_connections
backend ssh_per_ip_connections
  stick-table type ip size 1m expire 1m store conn_cur,conn_rate(1m)
```

La ligne **timeout client 1m** au niveau du bloc frontend définit la durée maximale pendant laquelle HAProxy attend une réponse du client. Plus précisément, cela signifie que si le client n'envoie pas de données au serveur dans un délai d'une minute, HAProxy mettra fin à la connexion. 

<br>

La ligne **tcp-request content track-sc0 src table ssh_per_ip_connections** au niveau du bloc frontend configure un suivi des sessions TCP pour les connexions SSH entrantes. Plus précisément, cette ligne configure HAProxy pour suivre chaque session TCP pour les connexions SSH entrantes à l'aide de la clé "src" (l'adresse IP source de la connexion). Les informations relatives à chaque session sont stockées dans une table nommée "ssh_per_ip_connections".

<br>

La ligne **tcp-request content reject if { sc_conn_cur(0) gt 2 } || { sc_conn_rate(0) gt 10 }** au niveau du bloc frontend configure une règle qui permet de refuser les connexions TCP si le nombre de connexions actives ou le taux de connexions pour l'adresse IP source dépasse un certain seuil. Plus précisément, cette ligne configure HAProxy pour refuser les connexions TCP et renvoyer un message de rejet si le nombre de connexions actives ("sc_conn_cur(0)") pour l'adresse IP source est supérieur à 2 OU si le taux de connexions ("sc_conn_rate(0)") pour l'adresse IP source est supérieur à 10 connexions sur un certain nombre de secondes (dans notre cas sur 60 secondes = 1 minute). Cette règle utilise la fonction "||" pour indiquer que l'une ou l'autre des conditions doit être vraie pour que la connexion soit refusée.

<br>

La ligne **stick-table type ip size 1m expire 1m store conn_cur,conn_rate(1m)** au niveau du bloc backend définit une table de persistence qui est utilisée pour suivre les connexions des clients. Plus précisément, cette ligne configure la table de persistence en utilisant l'adresse IP du client comme clé, avec une taille maximale de 1 million d'enregistrements et une durée d'expiration de 1 minute pour chaque enregistrement. La table stocke également deux valeurs pour chaque adresse IP : "conn_cur" qui représente le nombre actuel de connexions ouvertes pour cette adresse IP et "conn_rate(1m)" qui représente le taux de connexion pour cette adresse IP au cours de la dernière minute. 

<br><br>

Si nous exécutons à nouveau notre script **copyFile.sh** depuis notre serveur **client**, nous allons constater les connexions tcp ssh qui seront fermés par le serveur **server**. En plus sur l'interface web **http://192.168.56.8:8050/**, nous constaterons au niveau de l'interface **ssh-in** un nombre de connexions refusées.
# Haute disponibilité d'Alertmanager

Alertmanager est un outil utile pour gérer les alertes Prometheus, mais que se passe-t-il si notre instance Alertmanager tombe en panne ? Dans un tel scénario, nous pourrions manquer des alertes critiques qui doivent être traitées. Heureusement, Alertmanager peut s'exécuter dans un cluster multi-instance, ce qui le rend plus hautement disponible.

**Alertmanager** est déjà installé sur le serveur **monitoring** de la sandbox. Il convient de reproduire la même procédure d’installation sur les serveurs **server1** et **server2** de la sandbox. Une fois cette étape achevée, nous pourrons poursuivre avec les étapes suivantes.

- Autorions le port de communication du cluster alertmanager sur tous les serveurs : **monitoring**, **server1**, **server2**

```
sudo firewall-cmd --permanent --add-port=9094/tcp
sudo firewall-cmd --reload
```

- Sur le serveur de l'instance **monitoring**, nous modifions le service alertmanager

```
sudo vi /etc/systemd/system/alertmanager.service
```

```
[Unit]
Description=Prometheus Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/bin/sh -c '/usr/local/bin/alertmanager --config.file /etc/alertmanager/alertmanager.yml --storage.path="/var/lib/alertmanager" --cluster.peer=192.168.56.231:9094 --cluster.peer=192.168.56.232:9094'

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl restart alertmanager
```

- Sur le serveur de l'instance **server1** nous modifions le service alertmanager

```
sudo vi /etc/systemd/system/alertmanager.service
```

```
[Unit]
Description=Prometheus Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/bin/sh -c '/usr/local/bin/alertmanager --config.file /etc/alertmanager/alertmanager.yml --storage.path="/var/lib/alertmanager" --cluster.peer=192.168.56.230:9094 --cluster.peer=192.168.56.232:9094'

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl restart alertmanager
```

- Sur le serveur de l'instance **server2** nous modifions le service alertmanager

```
sudo vi /etc/systemd/system/alertmanager.service
```

```
[Unit]
Description=Prometheus Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/bin/sh -c '/usr/local/bin/alertmanager --config.file /etc/alertmanager/alertmanager.yml --storage.path="/var/lib/alertmanager" --cluster.peer=192.168.56.230:9094 --cluster.peer=192.168.56.231:9094'

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl restart alertmanager
```

- Vérifions le bon fonctionnement de notre cluster Alertmanager

Pour vérifier que notre cluster fonctionne, accédons aux 3 instances dans un navigateur avec les adresses : **http://192.168.56.230:9093**, **http://192.168.56.231:9093**, **http://192.168.56.232:9093** .


Sur l'interface web d'une instance, cliquons sur le menu **Silences** et créeons un nouveau **silence**. <br>
Cliquons sur le menu **Silences** sur l'autre instance et vérifions que le **silence** que nous avez créé apparaît.

- Configurons Prometheus pour se connecter aux deux instances d'Alertmanager

Nous éditons le fichier de configuration de prometheus :

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
alerting:
 alertmanagers:
 - static_configs:
   - targets: ["localhost:9093", "192.168.56.231:9093", "192.168.56.232:9093"]
... 
```

```
sudo systemctl restart prometheus
```

Vérifions que Prometheus est en mesure d'atteindre les deux instances d'Alertmanager. Accédons à Prometheus dans un navigateur Web à l'adresse : **http://192.168.56.230:9090** .

Cliquons sur le menu **Status > Alertmanager-discovery** et vérifions que les 3 instances d'Alertmanager apparaîssent.
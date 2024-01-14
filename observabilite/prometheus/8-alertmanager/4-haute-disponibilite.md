# Haute disponibilité d'Alertmanager

Alertmanager est un outil utile pour gérer les alertes Prometheus, mais que se passe-t-il si notre instance Alertmanager tombe en panne ? Dans un tel scénario, nous pourrions manquer des alertes critiques qui doivent être traitées. Heureusement, Alertmanager peut s'exécuter dans un cluster multi-instance, ce qui le rend plus hautement disponible.

Nous supposons que nous avons déjà installé une instance d'Alertmanager (ALERTMANAGER_1) sur notre serveur Rocky linux où est installé notre service prometheus.<br>
Nous supposons aussi que nous avons déjà installé une autre instance d'Alertmanager (ALERTMANAGER_2) sur un autre serveur Rocky linux.<br>
Pour configurer un cluster contenant les deux instances d'Alertmanager, nous procédons comme suit.

- Sur le serveur de l'instance **ALERTMANAGER_1** nous modifions le service alertmanager
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
ExecStart=/usr/local/bin/alertmanager \
 --config.file /etc/alertmanager/alertmanager.yml \
 --storage.path /var/lib/alertmanager/ \
 --cluster.peer=<IP_SERVEUR_ALERTMANAGER_2>:9094    <-------

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl restart alertmanager
```

- Sur le serveur de l'instance **ALERTMANAGER_2** nous modifions le service alertmanager
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
ExecStart=/usr/local/bin/alertmanager \
 --config.file /etc/alertmanager/alertmanager.yml \
 --storage.path /var/lib/alertmanager/ \
 --cluster.peer=<IP_SERVEUR_ALERTMANAGER_1>:9094    <-------

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl restart alertmanager
```

- Vérifions le bon fonctionnement de notre cluster Alertmanager

Pour vérifier que notre cluster fonctionne, accédons aux deux instances dans un navigateur avec les adresses

```
http://<IP_SERVEUR_ALERTMANAGER_1>:9093
http://<IP_SERVEUR_ALERTMANAGER_2>:9093
```

Sur l'interface web d'une instance, cliquons sur le menu **Silences** et créeons un nouveau **silence**.<br>
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
   - targets: ["localhost:9093", "<IP_SERVEUR_ALERTMANAGER_2>:9093"]
... 
```

```
sudo systemctl restart prometheus
```

Vérifions que Prometheus est en mesure d'atteindre les deux instances d'Alertmanager. Accédons à Prometheus dans un navigateur Web à l'adresse :
```
http://<IP_SERVEUR_PROMETHEUS>:9090.
```

Cliquons sur le menu **Status > Runtime & Build Information** et vérifions que les deux instances d'Alertmanager apparaîssent dans la section *Alertmanagers*.
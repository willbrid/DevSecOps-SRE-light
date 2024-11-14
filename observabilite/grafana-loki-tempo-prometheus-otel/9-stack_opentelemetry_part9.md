# Mise en place du monitoring système avec telegraf

Ici nous allons monitorer notre serveur **server-app** avec **telegraf** afin qu'il puisse téléverser les **données de métriques** vers
notre **collecteur opentelemetry**.

- Installation de **telegraph 1.32.2**

```
cat <<EOF | sudo tee /etc/yum.repos.d/influxdata.repo
[influxdata]
name = InfluxData Repository - Stable
baseurl = https://repos.influxdata.com/stable/x86_64/main
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdata-archive_compat.key
EOF
```

```
sudo yum install telegraf-1.32.2
```

- Verification du statut de **telegraf**

```
systemctl status telegraf
```

Ici nous constatons que le service **telegraf** n'est pas encore démarré.

- Configuration de **telegraf**

```
sudo mv /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.backup
```

```
sudo vi /etc/telegraf/telegraf.conf
```

```
[global_tags]

[agent]
  interval = "10s"
  debug = false
  hostname = "server-app"
  round_interval = true
  flush_interval = "10s"
  flush_jitter = "0s"
  collection_jitter = "0s"
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  quiet = false
  logfile = ""
  omit_hostname = false

[[outputs.opentelemetry]]
  service_address = "192.168.56.21:4317"
  timeout = "5s"

  [outputs.opentelemetry.attributes]
    "service.name" = "server-app"

[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false
[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]
[[inputs.diskio]]
[[inputs.mem]]
[[inputs.net]]
[[inputs.system]]
[[inputs.swap]]
[[inputs.netstat]]
[[inputs.processes]]
[[inputs.kernel]]
```

Ajoutons les droits nécessaires à l'utilisateur **telegraf** afin que le service **telegraf** puisse s'exécuter.

```
sudo usermod -aG wheel telegraf
```

- Démarrage et activation du service **telegraf**

```
sudo systemctl enable --now telegraf
```

- Verification du statut de **telegraf**

```
systemctl status telegraf
```

Ici nous constatons que le service **telegraf** est bien démarré.

- Visualisation des métriques sur grafana

Nous accédons à grafana via l'url **http://192.168.56.21:3000/** puis nous suivons les étapes :

--- clic sur le bouton **Toggle menu** <br>
--- sélection du menu **Explore** <br>
--- choix de la datasource **Thanos-Query-Frontend** <br>
--- au niveau de **Metric** on sélectionne par exemple **cpu_usage_idle**, puis au niveau de **Label filters** on sélectionne le label **host** et sa valeur **server-app**.

L'on pourra ainsi visualiser la consommation du **cpu** sur une période précise.
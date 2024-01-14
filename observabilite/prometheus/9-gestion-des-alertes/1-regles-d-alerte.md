# Règles d'alerte
Les règles d'alerte permettent de définir les conditions et le contenu des alertes prometheus. Ils nous permettent d'utiliser des expressions prometheus pour définir des conditions qui déclencheront une alerte en fonction de nos données métriques.
<br>
Configuration des règles d'alerte : les règles d'alerte sont créées et paramétrées de la même manière que les règles d'enregistrement. L'on spécifie un ou plusieurs emplacements pour les fichiers de règles dans **prometheus.yml** sous **rule_files**. L'on crée des règles en les définissant dans des fichiers yaml à l'emplacement approprié.

Exemple :
```
groups:
- name: example
  rules:
  - alert: HighRequestLatency
    expr: job.request_latency_seconds:mean5m{job="myjob"} > 0.5
    for: 10m
    labels: 
      severity: page
    annotations:
      summary: High request latency  
```

Nous pouvons voir l'état actuel de nos alertes dans notre navigateur à l'adresse :
```
http://<Prometheus Address>:9090/alerts
```

## Création d'une alerte
Modifions le fichier de configuration Prometheus en ajoutant un chemin pour les fichiers de règles à la configuration Prometheus :
```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
rule_files:
- "/etc/prometheus/rules/*.yml"
...
```

Créeons le répertoire des règles :
```
sudo mkdir -p /etc/prometheus/rules/
```

Créeons un nouveau fichier de règles qui implémente une règle d'alerte pour émettre une alerte lorsque le serveur Linux tombe en panne :
```
sudo vi /etc/prometheus/rules/linux-server-alerts.yml
```

```
groups:
- name: linux-server
  rules:
  - alert: LinuxServerDown
    expr: up{job="Linux Server"} == 0
    labels:
      severity: critical
    annotations:
      summary: Linux Server Down
```

```
sudo systemctl restart prometheus
```

Accédons à Prometheus dans un navigateur à l'adresse :
```
http://<IP_SERVEUR_PROMETHEUS>:9090
```

Cliquons sur **Alerts**. Nous devrions voir notre alerte **LinuxServerDown** répertoriée.

## Test de l'alerte
Connectons-nous à notre serveur Linux qui est surveillé par Prometheus et arrêtons le service **node_exporter** pour simuler la panne du serveur (alternativement, nous pouvons simplement arrêter le serveur lui-même, mais cela peut prendre plus de temps).
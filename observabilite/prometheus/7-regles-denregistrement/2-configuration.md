# Configuration des règles d'enregistrement

Les règles d'enregistrement sont un outil utile pour pré-calculer et stocker les résultats des expressions PromQL personnalisables. Ils nous permettent d'utiliser Prometheus plus efficacement en créant de nouvelles métriques de séries chronologiques pour stocker les données calculées plutôt que de recalculer chaque fois qu'une requête est exécutée.

- Créons un répertoire pour stocker les fichiers de règles

```
sudo mkdir -p /etc/prometheus/rules
```

- Modifions la configuration de Prometheus en localisant la section **rule_files** et en ajoutant le répertoire **rules** en tant que nouvelle entrée

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
rule_files:
- "/etc/prometheus/rules/*"
...
```

- Créeons un nouveau fichier de règles qui implémente une règle pour calculer et stocker les données d'utilisation du processeur

```
sudo vi /etc/prometheus/rules/linux_server_rules.yml
```

```
groups:
- name: linux_server
  interval: 15s
  rules:
    - record: linux_server:cpu_usage
      expr: sum(rate(node_cpu_seconds_total{job="node_exporter_monitoring",mode!='idle'}[5m])) * 100 / 2
```

```
sudo chown -R prometheus:prometheus /etc/prometheus/rules/
```

- Redémarrons Prometheus pour charger les modifications de configuration

```
sudo systemctl restart prometheus
```

Accédons au navigateur d'expressions à l'adresse : **http://192.168.56.230:9090** et éxécutons une requête pour afficher les données calculées par notre règle d'enregistrement.

```
linux_server:cpu_usage
```
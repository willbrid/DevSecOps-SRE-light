# Configuration des règles d'enregistrement
Les règles d'enregistrement sont un outil utile pour pré-calculer et stocker les résultats des expressions PromQL personnalisables. Ils nous permettent d'utiliser Prometheus plus efficacement en créant de nouvelles métriques de séries chronologiques pour stocker les données calculées plutôt que de recalculer chaque fois qu'une requête est exécutée.

- Nous nous connectons sur notre serveur prometheus
- Nous créeons un répertoire pour stocker les fichiers de règles
```
sudo mkdir -p /etc/prometheus/rules
```

- Nous modifions la configuration de Prometheus en localisant la section **rule_files** et en ajoutant le répertoire **rules** en tant que nouvelle entrée
```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
rule_files:
- "/etc/prometheus/rules/*"
...
```

- Nous créeons un nouveau fichier de règles qui implémente une règle pour calculer et stocker les données d'utilisation du processeur
```
sudo vi /etc/prometheus/rules/linux_server_rules.yml
```

```
groups:
- name: linux_server
  interval: 15s
  rules:
  - record: linux_server:cpu_usage
    expr: sum(rate(node_cpu_seconds_total{job="Linux Server",mode!='idle'}[5m])) * 100 / 2
```

- Nous redémarrons Prometheus pour charger les modifications de configuration
```
sudo systemctl restart prometheus
```

Nous accédons au navigateur d'expressions à l'adresse 
```
http://<IP_SERVEUR_PROMETHEUS>:9090/graph
```

Et nous éxécutons une requête pour afficher les données calculées par notre règle d'enregistrement.
```
linux_server:cpu_usage
```
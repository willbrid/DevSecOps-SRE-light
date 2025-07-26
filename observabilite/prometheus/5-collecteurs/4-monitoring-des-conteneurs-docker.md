# Monitoring des conteneurs Docker

### Installation et configuration de cAdvisor sur le serveur server2 de la sandbox pour exposer les métriques des conteneurs

**cAdvisor** (abréviation de **container Advisor**) analyse et expose l'utilisation des ressources et des données de performances des conteneurs en cours d'exécution. **cAdvisor** expose les métriques prometheus prêtes à l'emploi.

- Exécutons cadvisor v0.52.1 dans un conteneur docker

```
sudo docker run -d --restart always --name cadvisor -p 9080:8080 --volume=/:/rootfs:ro --volume=/var/run/:/var/run:ro --volume=/sys/:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --volume=/dev/disk/:/dev/disk:ro --privileged=true --device=/dev/kmsg gcr.io/cadvisor/cadvisor:v0.52.1
```

- Vérifions que nous pouvons interroger cAdvisor pour les métriques

```
curl http://localhost:9080/metrics
```

Pour permettre à prometheus de récupérer les métriques des conteneurs **docker**, nous devons d'abord autoriser le port 9080 au niveau du pare-feu

```
sudo firewall-cmd --permanent --add-port=9080/tcp
sudo firewall-cmd --reload
```

### Exécution d'un conteneur busybox version 1.37.0 sur le serveur server2 à monitorer par cadvisor

```
sudo docker run -d --name busybox --restart always library/busybox:1.37.0 /bin/sh -c "while true; do ping -c 1 127.0.0.1; sleep 5; done"
```

### Configuration de Prometheus sur le serveur monitoring de la sandbox pour récupérer les données métriques de tous les conteneurs Docker du serveur server2

Nous éditons le fichier de configuration de prometheus.

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
scrape_configs:
...
  - job_name: 'cadvisor_server2'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.56.232:9080']
...
```

```
sudo systemctl restart prometheus
```

Nous utilisons le navigateur d'expressions pour vérifier que nous pouvons voir les métriques de conteneurs docker du serveur **server2** dans prometheus en accédant au lien : **http://192.168.56.230:9090** .

Et en saisissant cette requête pour afficher quelques données métriques de conteneurs docker (dont le nom contient par exemple **busybox**) :

```
container_fs_usage_bytes{name="busybox"}
```
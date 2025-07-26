# Monitoring des conteneurs Podman

### Installation et configuration de cAdvisor sur le serveur server1 de la sandbox pour exposer les métriques des conteneurs

**cAdvisor** (abréviation de **container Advisor**) analyse et expose l'utilisation des ressources et des données de performances des conteneurs en cours d'exécution. **cAdvisor** expose les métriques prometheus prêtes à l'emploi.

- Activons la socket podman systemd pour l'utilisateur vagrant

```
systemctl --user start podman.socket
```

```
systemctl --user enable podman.socket
```

```
sudo loginctl enable-linger vagrant
```

- Exécutons cadvisor v0.52.1 dans un conteneur podman

```
podman run -d --name cadvisor -p 9080:8080 --volume=/:/rootfs:ro --volume=/run/user/1000:/run/user/1000:ro --volume=/dev/disk/:/dev/disk:ro --volume=/home/vagrant/.local/share/containers:/var/lib/containers:ro --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro --volume=/etc/machine-id:/etc/machine-id:ro --privileged=true gcr.io/cadvisor/cadvisor:v0.52.1 --podman="unix:///run/user/1000/podman/podman.sock"
```

**NB:** 1000 est le uid de l'utilisateur vagrant.

- Vérifions que nous pouvons interroger cAdvisor pour les métriques

```
curl http://localhost:9080/metrics
```

Pour permettre à prometheus de récupérer les métriques des conteneurs **podman**, nous devons d'abord autoriser le port 9080 au niveau du pare-feu

```
sudo firewall-cmd --permanent --add-port=9080/tcp
sudo firewall-cmd --reload
```

NB: Dans une section précédente, nous avons déjà installé un conteneur podman mariadb.

### Configuration de Prometheus sur le serveur monitoring de la sandbox pour récupérer les données métriques de tous les conteneurs podman du serveur server1

Nous éditons le fichier de configuration de prometheus.

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
scrape_configs:
  ...
  - job_name: 'cadvisor_server1'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.56.231:9080']
...
```

```
sudo systemctl restart prometheus
```

Nous utilisons le navigateur d'expressions pour vérifier que nous pouvons voir les métriques de conteneurs podman du serveur **server1** dans prometheus en accédant au lien : **http://192.168.56.230:9090** .

Et en saisissant cette requête pour afficher quelques données métriques de conteneurs docker (dont le nom contient *srv-db*) :

```
container_memory_usage_bytes{name="srv-db"}
```
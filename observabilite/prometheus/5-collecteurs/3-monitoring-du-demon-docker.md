# Monitoring du démon Docker

### Installation de docker sur le serveur server2 de la sandbox

- Désinstallons toute installation préalable de **docker** et **podman**

```
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc
```

- Configurons le repo docker

```
sudo dnf -y install dnf-plugins-core

sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
```

- Installons docker

```
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

- Activons et démarrons le service docker

```
sudo systemctl enable --now docker
```

- Assurons-nous que le service docker est activé

```
sudo systemctl status docker
```

### Configurons le démon Docker sur le serveur server2 de la sandbox pour servir les métriques Prometheus

Sur une machine virtuelle où est installé le démon docker et dont nous souhaiterons monitorer, nous procédons comme suit.

- Editons le fichier de configuration Docker

```
sudo vi /etc/docker/daemon.json
```

```
{
  "metrics-addr": "0.0.0.0:9323"
}
```

- Redemarrons le service docker

```
sudo systemctl restart docker
```

- Vérifions que docker diffuse les métriques Prometheus

```
curl http://localhost:9323/metrics
```

Pour permettre à prometheus de récupérer les métriques du service **docker**, nous devons d'abord autoriser le port 9323 au niveau du pare-feu

```
sudo systemctl start firewalld.service && sudo systemctl enable firewalld.service

sudo firewall-cmd --permanent --add-port=9323/tcp
sudo firewall-cmd --reload
```

### Configurons Prometheus sur le serveur monitoring de la sandbox pour récupérer les données métriques Docker

Nous éditons le fichier de configuration de prometheus.

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
- job_name: 'docker_daemon_server2'
  scrape_interval: 5s
  static_configs:
  - targets: ['192.168.56.232:9323']
...
```

```
sudo systemctl restart prometheus
```

Nous utilisons le navigateur d'expressions pour vérifier que nous pouvons voir les métriques docker dans prometheus en accédant au lien : **http://192.168.56.230:9090** .

Et en saisissant cette requête pour afficher quelques données métriques de docker

```
engine_daemon_engine_info
```
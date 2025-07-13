# Monitoring du démon Docker
## Configurons le démon Docker pour servir les métriques Prometheus
Sur une machine virtuelle où est installé le démon docker et dont nous souhaiterons monitorer, nous procédons comme suit.

- Editons le fichier de configuration Docker
```
sudo vi /etc/docker/daemon.json
```

```
{
  "experimental": true,
  "metrics-addr": "<IP_SERVEUR_DU_DEMON_DOCKER>:9323"
}
```

- Redemarrons le service docker
```
sudo systemctl restart docker
```

- Vérifions que docker diffuse les métriques Prometheus 
```
curl <IP_SERVEUR_DU_DEMON_DOCKER>:9323/metrics
```

## Configurons Prometheus pour récupérer les données métriques Docker
Sur une machine virtuelle où est installé prometheus nous procédons comme suit.

Nous éditons le fichier de configuration de prometheus :
```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
- job_name: 'Docker'
  static_configs:
  - targets: ['<IP_SERVEUR_DU_DEMON_DOCKER>:9323']
...  
```

```
sudo systemctl restart prometheus
```

Nous utilisons le navigateur d'expressions pour vérifier que nous pouvons voir les métriques docker dans prometheus en accédant au lien 
```
http://<IP_SERVEUR_PROMETHEUS>:9090.
```

et en saisissant cette requête pour afficher quelques données métriques de docker :
```
engine_daemon_container_states_containers
```
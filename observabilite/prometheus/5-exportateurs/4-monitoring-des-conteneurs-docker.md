# Monitoring des conteneurs Docker
## Configurons cAdvisor pour exposer les métriques
**cAdvisor** (abréviation de container Advisor) analyse et expose l'utilisation des ressources et des données de performances des conteneurs en cours d'exécution. **cAdvisor** expose les métriques prometheus prêtes à l'emploi.
<br>
Sur une machine virtuelle où est installé le démon docker et dont nous souhaiterons monitorer ses conteneurs, nous procédons comme suit.

- Exécutons cadvisor dans un conteneur
```
docker run -d --restart always --name cadvisor -p 8080:8080 -v "/:/rootfs:ro" -v "/var/run:/var/run:rw" -v "/sys:/sys:ro" -v "/var/lib/docker/:/var/lib/docker:ro" google/cadvisor:latest
```

- Vérifions que nous pouvons interroger cAdvisor pour les métriques
```
curl localhost:8080/metrics
```

## Configurons Prometheus pour récupérer les données métriques du conteneur Docker de cAdvisor
Sur une machine virtuelle où est installé prometheus nous procédons comme suit.

Nous éditons le fichier de configuration de prometheus :
```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
- job_name: 'Docker Containers'
  static_configs:
  - targets: ['<IP_SERVEUR_DU_DEMON_DOCKER>:8080']
...  
```

```
sudo systemctl restart prometheus
```

Nous utilisons le navigateur d'expressions pour vérifier que nous pouvons voir les métriques de conteneurs docker dans prometheus en accédant au lien 
```
http://<IP_SERVEUR_PROMETHEUS>:9090.
```

et en saisissant cette requête pour afficher quelques données métriques de conteneurs docker (dont le nom contient *web*) :
```
container_memory_usage_bytes{name=~"web."}
```
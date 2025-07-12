# Concept

### Qu'est ce que la Découverte de services de prometheus

La **découverte de services** permet à Prometheus de découvrir automatiquement les endpoints à scrapper dans des environnements dynamiques. <br>
Quand un nouveau service (ou pod, ou VM) démarre, Prometheus le découvre tout seul et commence à collecter ses métriques. Quand ce service disparaît, Prometheus arrête automatiquement de le surveiller.

Prometheus intègre la prise en charge de plusieurs mécanismes de découverte de services :
- interroger AWS EC2 pour connaître les instances disponibles,
- interroger Azure ou Google Cloud (GCE) pour lister les VM,
- utiliser Consul pour savoir quels services tournent dans notre infra,
- ou encore lire les pods Kubernetes pour détecter ceux à surveiller.

### Découverte de services via des fichiers

Une liste de **tâches/cibles** (**jobs/targets**) peut être importée depuis un fichier. Cela permet l'intégration avec les systèmes de découverte de services non pris en charge par Prometheus. Ces fichiers peuvent être des fichiers **JSON** ou **YAML**.

```
# prometheus.yaml
scrape_configs:
  - job_name: file-example
    file_sd_configs:
      - files:
        - 'file-sd.json'
        - '*.json'
```

```
# file-sd.json
[
    {
        "targets": [ "node1:9100", "node2:9100" ],
        "labels": {
            "team": "dev";
            "job": "node"
        }
    },
    {
        "targets": [ "localhost:9090" ],
        "labels": {
            "team": "monitoring";
            "job": "prometheus"
        }
    },
    {
        "targets": [ "db1:9090" ],
        "labels": {
            "team": "db";
            "job": "database"
        }
    }
]
```

- **Exemple avec AWS ec2**

L'infrastructure cloud est très dynamique, surtout lorsque la mise à l'échelle automatique est activée. <br>
La découverte de service EC2 permet à Prometheus de disposer d'une liste de toutes les instances EC2 disponibles à explorer.

```
scrape_configs:
  - job_name: EC2
    ec2_sd_configs:
      - region: <region>
        access_key: <access key>
        secret_key: <secret key>
```

**NB**: Les identifiants doivent être configurés avec un utilisateur IAM et la politique d'accès **AmazonEC2ReadOnlyAccess**.

Exemple de métadonnées extraites pour chaque instance EC2 trouvée :

```
__meta_ec2_tag_Name="web"
__meta_ec2_instance_type="t2.micro"
__meta_ec2_vpc_id="vpc-294f5553"
__meta_ec2_private_ip="172.31.1.156"
``
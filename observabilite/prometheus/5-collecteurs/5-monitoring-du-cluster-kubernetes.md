# Monitoring de Kubernetes

### Configurons kube-state-metrics pour exposer les métriques de notre cluster Kubernetes

Nous supposons monitorer un cluster kubernetes **version 1.31**. <br>
Sur une machine virtuelle où est installé un noeud master de kubernetes et dont nous souhaiterons monitorer son cluster, nous procédons comme suit.

- Installons **kube-state-metrics** version v2.14.0

```
git clone https://github.com/kubernetes/kube-state-metrics.git
```

```
cd kube-state-metrics/
git checkout v2.14.0
```

- Accédons au répertoire *kube-state-metrics/examples/standard* et modifions le fichier service.yaml

```
cd examples/standard && vi service.yaml
```

```
...
spec:
  type: NodePort
...
```

```
kubectl apply -f ../standard
```

- Vérifions que nous pouvons interroger les métriques du cluster kubernetes

```
curl localhost:<NODEPORT_SERVICE_KUBE-STATE-METRIC>/metrics
```

### Configurons Prometheus sur le serveur monitoring de la sandbox pour récupérer les données métriques des conteneurs du cluster kubernetes

Nous éditons le fichier de configuration de prometheus

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
- job_name: 'Kubernetes'
  static_configs:
  - targets: ['<IP_NOEUD_MASTER>:<NODEPORT_SERVICE_KUBE-STATE-METRIC>']
...  
```

```
sudo systemctl restart prometheus
```

Nous utilisons le navigateur d'expressions pour vérifier que nous pouvons voir les métriques du cluster kubernetes dans prometheus en accédant au lien : **http://192.168.56.230:9090** .

Et en saisissant cette requête pour afficher quelques données métriques du cluster kubernetes

```
kube_pod_status_ready{namespace="default",condition="true"}
```
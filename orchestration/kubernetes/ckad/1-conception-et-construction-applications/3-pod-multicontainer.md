# Modèle de conception de pod multi-conteneur
Nous citerons 3 modèles de conception de pod multi-conteneur :
- Un conteneur sidecar effectue une tâche qui aide le conteneur principal.<br>
- Un conteneur ambassadeur assure le trafic réseau vers et/ou depuis le conteneur principal.<br>
- Un conteneur adaptateur transforme la sortie du conteneur principal.

## Modèle de conception sidecar
Nous créons un pod avec un conteneur side-car qui interagit avec le conteneur principal à l'aide d'un volume partagé.
```
vi sidecar-test.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-test
spec:
  containers:
  - name: writer
    image: busybox:stable
    command: ['sh', '-c', 'echo "The writer wrote this!" > /output/data.txt; while true; do sleep 5; done']
    volumeMounts:
    - name: shared
      mountPath: /output
  - name: sidecar
    image: busybox:stable
    command: ['sh', '-c', 'while true; do cat /input/data.txt; sleep 5; done']
    volumeMounts:
    - name: shared
      mountPath: /input
  volumes:
  - name: shared
    emptyDir: {}
```

```
kubectl apply -f sidecar-test.yml
```

Nous pouvons vérifier l'état du pod et attendre que les deux conteneurs soient prêts.
```
kubectl get pod sidecar-test
```

Nous pouvons vérifier les journaux du conteneur side-car et voir les données qui ont été écrites par le conteneur principal.
```
kubectl logs sidecar-test -c sidecar
```

## Modèle de conception ambassadeur
Nous créons un pod avec un conteneur ambassadeur qui interagit avec le conteneur principal via des ressources réseau partagées.<br>
- tout d'abord, nous créons un service avec lequel notre pod peut communiquer.
```
vi ambassador-test-setup.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: ambassador-test-webserver
  labels:
    app: ambassador-test
spec:
  containers:
  - name: nginx
    image: nginx:stable
    ports:
    - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: ambassador-test-svc
spec:
  selector:
    app: ambassador-test
  ports:
  - protocol: TCP
    port: 8081
    targetPort: 80    
```

```
kubectl apply -f ambassador-test-setup.yml
```

- nous créons le pod avec le conteneur ambassadeur.
```
vi ambassador-test.yml
```

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: haproxy-config
data:
  haproxy.cfg: |
    frontend ambassador
      bind *:8080
      default_backend ambassador_test_svc
    backend ambassador_test_svc
      server svc ambassador-test-svc:8081
---
apiVersion: v1
kind: Pod
metadata:
  name: ambassador-test
spec:
  containers:
  - name: main
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do curl localhost:8080; sleep 5; done']
  - name: ambassador
    image: haproxy:2.4
    volumeMounts:
    - name: config
      mountPath: /usr/local/etc/haproxy/
  volumes:
  - name: config
    configMap:
      name: haproxy-config      
```

```
kubectl apply -f ambassador-test.yml
```

Nous pouvons consulter les journaux du pod principal pour vérifier que la configuration fonctionne.
```
kubectl logs ambassador-test -c main
```

## Modèle de conception adaptateur
Nous créons un pod avec un conteneur adaptateur qui transforme chaque ligne de log du conteneur principal en format json à l'aide d'un volume partagé.

```
vi adapter-test.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: adapter-test
spec:
  containers:
  - name: writer
    image: busybox:stable
    command: ['sh', '-c', "while true; do echo $(date -u)'#This is log' >> /var/log/file.log; sleep 3; done"]
    volumeMounts:
    - name: var-logs
      mountPath: /var/log
  - name: adapter
    image: busybox:stable
    command: ['sh', '-c', 'while true; do datetime=`tail -n 1 /var/log/file.log | cut -d "#" -f 1`; message=`tail -n 1 /var/log/file.log | cut -d "#" -f 2`; echo "{datetime: $datetime, message: $message}"; sleep 3; done']
    volumeMounts:
    - name: var-logs
      mountPath: /var/log
  volumes:
  - name: var-logs
    emptyDir: {}
```

```
kubectl apply -f adapter-test.yml
```

Nous pouvons vérifier l'état du pod et attendre que les deux conteneurs soient prêts.
```
kubectl get pod adapter-test
```

Nous pouvons vérifier les journaux du conteneur adapter et voir les données sous format json.
```
kubectl logs adapter-test -c adapter
```
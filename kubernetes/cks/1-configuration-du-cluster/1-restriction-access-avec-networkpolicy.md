# Restreindre l'accès par défaut avec NetworkPolicies

Les NetworkPolicies nous permettent d'empêcher ou de restreindre la communication réseau vers et depuis les pods.<br>

On utilise une politique de refus de réseau par défaut pour bloquer tout le trafic réseau vers et/ou depuis les pods dans un espace de noms.<br>

On utilise un spec *podSelector: {}* vide pour que la stratégie s'applique à tous les pods de l'espace de noms.<br>

 On utilise le champ *policyTypes* pour bloquer le trafic entrant (ingress), le trafic sortant (egress) ou les deux.

 - Nous créons un exemple d'application pour tester la configuration de *NetworkPolicy*.<br>

Nous créons un espace de nom
```
kubectl create namespace nptest
```

Nous créons un simple server web nginx dans cet espace de nom
```
vi nginx-dep.yml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: nptest
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

```
kubectl create -f nginx-dep.yml
```

Nous affichons l'adresse IP du cluster du pod de serveur Nginx
```
kubectl get pods -n nptest -o wide
```

Nous créons un client de test qui tentera d'atteindre le serveur Web toutes les quelques secondes.
```
vi client-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: client
  namespace: nptest
  labels:
    app: client
spec:
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do curl -m 3 <Nginx Pod Cluster IP address>; sleep 5; done']
```

```
kubectl create -f client-pod.yml
```

Nous laissons le pod client s'exécuter pendant quelques secondes, puis consultons le journal pour vérifier qu'il peut atteindre le pod serveur avec succès.

```
kubectl logs -n nptest client
```

- Nous créons une stratégie de réseau de refus par défaut

En créeant une NetworkPolicy de refus par défaut, cela bloquera l'accès réseau au pod serveur.

```
vi default-deny-all-np.yml
```

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: nptest
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

```
kubectl create -f default-deny-all-np.yml
```

Nous vérifions à nouveau le journal du pod client. Nous devrions voir qu'il est désormais impossible d'accéder au serveur Pod.

```
kubectl logs -n nptest client
```
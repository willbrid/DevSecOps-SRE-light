# Utilisation de l'objet NetworkPolicies
Une NetworkPolicy K8s est un objet qui vous permet de contrôler le flux de communication réseau vers et depuis les pods.
Cela vous permet de créer un réseau de clusters plus sécurisé en maintenant les pods isolés du trafic dont ils n'ont pas besoin.
<br>
Par défaut, les Pods sont considérés comme non isolés et complètement ouverts à toutes les communications. Si une NetworkPolicy sélectionne un pod, le pod est considéré comme isolé et ne sera ouvert qu'au trafic autorisé par NetworkPolicies.
<br>

Nous présentons à présent un exemple d'utilisation de l'objet *NetworkPolicy* au sein du cluster k8s.<br>
Nous créons un espace de nom *np-test* :
```
kubectl create namespace np-test
```

Nous ajoutons un label à cet espace de nom :
```
kubectl label namespace np-test team=np-test
```

Nous créons un pod serveur web nginx :
```
vi np-nginx.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: np-nginx
  namespace: np-test
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx
```

```
kubectl create -f np-nginx.yml
```

Nous créons un pod serveur web busybox :
```
vi np-busybox.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: np-busybox
  namespace: np-test
  labels:
    app: client
spec:
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do sleep 5; done']
```

```
kubectl create -f np-busybox.yml
```

Nous obtenons l'adresse IP du pod serveur web nginx et nous enregistrons dans une variable d'environnement :
```
kubectl get pods -n np-test -o wide
NGINX_IP=<np-nginx Pod IP>
```

Nous vérifions que nous pouvons atteindre le pod serveur web nginx depuis le pod client :
```
kubectl exec -n np-test np-busybox -- curl $NGINX_IP
```

Nous créons un objet *NetworkPolicy* qui sélectionne le pod serveur web nginx :
```
vi test-networkpolicy.yml
```

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-networkpolicy
  namespace: np-test
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
  - Ingress
  - Egress
```

```
kubectl create -f test-networkpolicy.yml
```

Nous vérifions que nous ne pouvons plus atteindre le pod serveur web nginx depuis le pod client car le *NetworkPolicy* bloquera tout le trafic vers et depuis le pod serveur web Nginx :
```
kubectl exec -n np-test np-busybox -- curl $NGINX_IP
```

Nous modifions notre objet *NetworkPolicy* afin qu'il autorise le trafic entrant sur le port 80 pour tous les pods dans l'espace de noms np-test :
```
kubectl edit networkpolicy -n np-test my-networkpolicy
```

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-networkpolicy
  namespace: np-test
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          team: np-test
    ports:
    - port: 80
      protocol: TCP
```

Nous vérifions que nous pouvons à nouveau atteindre le pod serveur web nginx depuis le pod client :
```
kubectl exec -n np-test np-busybox -- curl $NGINX_IP
```
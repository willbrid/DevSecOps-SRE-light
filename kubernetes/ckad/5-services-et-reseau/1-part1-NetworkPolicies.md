# Partie 1 : contrôler l'accès au réseau avec NetworkPolicies
Si un pod n'est sélectionné par aucune stratégie réseau (*NetworkPolicy*), le pod n'est pas isolé et tout le trafic est autorisé.<br>
Si un pod est sélectionné par une stratégie réseau (*NetworkPolicy*), le trafic sera bloqué à moins qu'il ne soit autorisé par au moins une stratégie réseau (*NetworkPolicy*) qui sélectionne le pod.<br>
Si vous combinez un *namespaceSelector* et un *podSelector* dans la même règle, le trafic doit remplir à la fois les conditions liées au pod et à l'espace de noms pour être autorisé.<br>

- Commençons par créer une configuration avec un pod qui communique avec un autre pod via le réseau.<br>
créons 2 espaces de noms :
```
kubectl create namespace np-test-a
kubectl create namespace np-test-b
```

Attachons des étiquettes à ces espaces de noms.
```
kubectl label namespace np-test-a team=ateam
kubectl label namespace np-test-b team=bteam
```

créons un pod serveur
```
vi server-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: server-pod
  namespace: np-test-a
  labels:
    app: np-test-server
spec:
  containers:
  - name: nginx
    image: nginx:stable
    ports:
    - containerPort: 80
```

```
kubectl apply -f server-pod.yml
```

Obtenons l'adresse IP du cluster du serveur Pod. Nous devrions peut-être attendre quelques instants que le pod soit en cours d'exécution pour que l'adresse IP apparaisse.<br><br>

créons un pod client
```
vi client-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: client-pod
  namespace: np-test-b
  labels:
    app: np-test-client
spec:
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do curl -m 2 <server Pod IP address>; sleep 5; done']
```

```
kubectl apply -f client-pod.yml
```

NB: Dans la commande du conteneur, nous devrons indiquer l'adresse IP du cluster du serveur Pod.<br>

Vérifions le journal du pod client. Nous devrions voir qu'il est capable d'atteindre avec succès le serveur Pod.
```
kubectl logs client-pod -n np-test-b
```

- créons une stratégie réseau entrant de refus par défaut. Cela bloquera le trafic entrant pour tous les pods dans l'espace de noms np-test-a par défaut.
```
vi np-test-a-default-deny-ingress.yml
```

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-test-a-default-deny-ingress
  namespace: np-test-a
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

```
kubectl apply -f np-test-a-default-deny-ingress.yml
```

Vérifions à nouveau le journal du pod client. Le trafic devrait maintenant être bloqué, ce qui entraîne des messages d'erreur dans le journal
```
kubectl logs client-pod -n np-test-b
```
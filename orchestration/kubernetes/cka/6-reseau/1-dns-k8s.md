# Comprendre le DNS k8s
Le réseau virtuel K8s utilise un DNS (Domain Name System) pour permettre aux pods de localiser d'autres pods et services en utilisant des noms de domaine au lieu d'adresses IP.
Ce DNS s'exécute en tant que service au sein du cluster. Vous pouvez généralement le trouver dans l'espace de noms *kube-system*. Les clusters Kubeadm utilisent CoreDNS.<br>

Nous présentons à présent un exemple d'utilisation du dns pour les pods au sein du cluster k8s.<br>
Nous créons deux pods *busybox-dnstest* et *nginx-dnstest* :
```
vi dnstest-pods.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: busybox-dnstest
spec:
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do sleep 3600; done']
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-dnstest
spec:
  containers:
  - name: nginx
    image: nginx:1.19.2
    ports:
    - containerPort: 80
```

```
kubectl create -f dnstest-pods.yml
```

Nous obtenons l'adresse ip du pod *nginx-dnstest* :
```
kubectl get pods nginx-dnstest -o wide
```

Nous vérifions que nous pouvons atteindre le pod *nginx-dnstest* au sein du réseau du cluster via son adresse IP :
```
kubectl exec busybox-dnstest -- curl <@IP nginx-dnstest>
```

Nous vérifions que nous pouvons rechercher l'enregistrement DNS du pod nginx-dnstest :
```
kubectl exec busybox-dnstest -- nslookup <nginx-dnstest-ip>.default.pod.cluster.local
```
Ici nginx-dnstest-ip est l'adresse ip du pod nginx-dnstest où les points sont remplacés par les tirets. Par exemple si l'adresse ip du pod était 10.0.0.1 alors l'on aura son nom de domaine :
*10-0-0-1.default.pod.cluster.local* où *default* est l'espace de nom.
<br>

Nous vérifions que nous pouvons atteindre le pod *nginx-dnstest* via son nom de domaine :
```
kubectl exec busybox -- curl <nginx-dnstest-ip>.default.pod.cluster.local
```
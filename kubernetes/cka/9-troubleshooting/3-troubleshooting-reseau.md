# Troubleshooter le réseau du cluster k8s
En plus de vérifier notre plugin réseau K8s, il peut être judicieux de regarder kube-proxy et le DNS K8s si nous rencontrons des problèmes au sein du réseau de cluster k8s.<br>
Dans un cluster kubeadm, le DNS k8s et le kube-proxy s'exécutent en tant que pods dans l'espace de noms *kube-system*.
<br>

- Nous pouvons lister les pods de l'espace de noms *kube-system*
```
kubectl get pods -n kube-system
``` 

- Nous pouvons afficher les logs du composant kube-proxy
```
kubectl logs -n kube-system <kube-proxy_POD_NAME>
```

- Nous pouvons afficher les logs du composant dns (exemple *coreDns*)
```
kubectl logs -n kube-system <DNS_POD_NAME>
```

- Nous pouvons utiliser l'outil *netshoot* :
```
vi netshoot.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: netshoot
spec:
  containers:
  - name: netshoot
    image: nicolaka/netshoot
    command: ['sh', '-c', 'while true; do sleep 5; done']
```

```
kubectl create -f netshoot.yml
```

Nous ouvrons un shell interactif dans le conteneur netshoot :
```
kubectl exec netshoot --stdin --tty -- /bin/sh
```

Ensuite nous éxécutons quelques commandes de vérification réseau :
```
curl svc-miamiam

ping svc-miamiam

nslookup svc-miamiam
```

*svc-miamiam* est considéré comme un service qui expose les pods d'une application *miamiam*.
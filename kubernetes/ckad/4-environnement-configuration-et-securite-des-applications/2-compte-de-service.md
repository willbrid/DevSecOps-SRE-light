# Objet ServiceAccounts
Les objets *ServiceAccounts* permettent aux processus des conteneurs de s'authentifier auprès du serveur d'API Kubernetes.<br>
Nous pouvons définir le *ServiceAccount* du pod avec *serviceAccountName* dans la spécification du pod.<br>
Le jeton *ServiceAccount* du pod est automatiquement monté sur les conteneurs du pod.<br>

- créons un objet *ServiceAccount*
```
vi my-sa.yml
```

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-sa
automountServiceAccountToken: true
```

```
kubectl apply -f my-sa.yml
```

- créons un pod qui utilise notre objet *ServiceAccount*
```
vi sa-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: sa-pod
spec:
  serviceAccountName: my-sa
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do curl -s --header "Authorization: Bearer $(cat
/var/run/secrets/kubernetes.io/serviceaccount/token)" --cacert
/var/run/secrets/kubernetes.io/serviceaccount/ca.crt https://kubernetes/api/v1/namespaces/default/pods; sleep 5; done']
```

```
kubectl apply -f sa-pod.yml
```

Nous pouvons vérifier les journaux du conteneur :
```
kubectl logs sa-pod
```

À ce stade, le journal du pod doit afficher un message d'erreur indiquant que le compte de service ne dispose pas des autorisations appropriées pour effectuer l'appel d'API demandé.
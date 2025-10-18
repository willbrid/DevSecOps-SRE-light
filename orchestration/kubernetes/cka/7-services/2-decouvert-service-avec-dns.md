# Découvertes des services avec le DNS
Dans ce tutoriel, nous présentons comment accéder à un service depuis un espace de nom via son nom de domaine interne au cluster.<br>
Ce tutoriel dépend du tutoriel sur *l'utilisation des services.*

Nous obtenons l'adresse IP de notre service *svc-clusterip* :
```
kubectl get service svc-clusterip
```

Nous effectueons une recherche DNS sur le service à partir du pod busybox :
```
kubectl exec pod-svc-test -- nslookup <adresse IP du service>
```

Nous pouvons utiliser l'adresse ip du service pour éxécuter une requête depuis notre pod busybox :
```
kubectl exec pod-svc-test -- curl <adresse IP du service>
```

Nous pouvons éxécuter la même requête en utilisant le nom du service :
```
kubectl exec pod-svc-test -- curl svc-clusterip
```

La requête ci-dessous est possible parce que notre pod busybox se trouve dans le même espace de nom avec notre service.<br>

Nous pouvons utiliser le nom de domaine complet du service pour éxécuter la même requête :
```
kubectl exec pod-svc-test -- curl svc-clusterip.default.svc.cluster.local
```

*default* représente un espace de nom, *svc* le nom court de l'objet service sur k8s et *cluster.local* le nom de domaine racine du cluster.<br><br>

Nous créons un autre espace de nom :
```
kubectl create namespace test-namespace
```

Nous créons un pod de test dans cet espace de nom :
```
vi pod-svc-test-namespace.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-svc-test-namespace
  namespace: test-namespace
spec:
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do sleep 10; done']
```

```
kubectl create -f pod-svc-test-namespace.yml
```

Nous essayons de faire une requête au service à partir du pod busybox qui se trouve dans un autre espace de noms *pod-svc-test-namespace* :
```
kubectl exec -n test-namespace pod-svc-test-namespace -- curl svc-clusterip

kubectl exec -n test-namespace pod-svc-test-namespace -- curl svc-clusterip.default.svc.cluster.local
```

La requête utilisant uniquement le nom de service échouera, mais elle réussira si l'on utilise le nom de domaine complet.
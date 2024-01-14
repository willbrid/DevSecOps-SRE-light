# Exposer des applications avec Ingress
Un Ingress gère l'accès externe aux applications Kubernetes.<br>
Un Ingress achemine vers 1 ou plusieurs services Kubernetes.<br>
Nous avons besoin d'un contrôleur Ingress pour implémenter la fonctionnalité Ingress. Le contrôleur que nous utilisons détermine les spécificités du fonctionnement de l'Ingress.<br>

- créons un pod
```
vi ingress-test-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: ingress-test-pod
  labels:
    app: ingress-test
spec:
  containers:
  - name: nginx
    image: nginx:stable
    ports:
    - containerPort: 80
```

```
kubectl apply -f ingress-test-pod.yml
```

- créons un service de type clusterIP
```
vi ingress-test-service.yml
```

```
apiVersion: v1
kind: Service
metadata:
  name: ingress-test-service
spec:
  type: ClusterIP
  selector:
    app: ingress-test
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

```
kubectl apply -f ingress-test-service.yml
```

Obtenons l'adresse IP du cluster du service.
```
kubectl get service ingress-test-service
```

Utilisons l'adresse IP du cluster pour tester le service.
```
curl <Service cluster IP address>
```

- créons un ingress
```
vi ingress-test-ingress.yml
```

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-test-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: ingresstest.acloud.guru
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
          name: ingress-test-service
          port:
            number: 80
```

```
kubectl apply -f ingress-test-ingress.yml
```

Affichons une liste d'objets d'entrée.
```
kubectl get ingress
```

Obtenons plus de détails sur l'entrée. Nous devrions remarquer ingress-test-service répertorié comme l'un des backends.
```
kubectl describe ingress ingress-test-ingress
```

Si nous souhaitons essayer d'accéder à notre service via un contrôleur d'entrée, nous devons effectuer une configuration supplémentaire.<br>
Tout d'abord, utilisez Helm pour installer le contrôleur nginx Ingress.
```
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
kubectl create namespace nginx-ingress
helm install nginx-ingress nginx-stable/nginx-ingress -n nginx-ingress
```

Obtenons l'adresse IP du cluster du service du contrôleur d'entrée.
```
kubectl get svc nginx-ingress-nginx-ingress -n nginx-ingress
```

Maintenant, testons votre configuration.
```
curl ingresstest.acloud.guru
```

NB: Si besoin, l'on pourra ajouter une ligne dans le fichier */etc/hosts* pour mapper le nom * ingresstest.acloud.guru* à l'@IP du controller Nginx ingress .
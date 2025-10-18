# Implémentation de TLS avec Ingress
Un *ingress* est un objet Kubernetes qui gère l'accès aux services depuis l'extérieur du cluster.<br>
Les *ingress* peuvent fournir des fonctionnalités en plus des services, telles que l'équilibrage de charge et la terminaison TLS.<br>
Nous pouvons implémenter la terminaison TLS à l'aide d'un Ingress en stockant les certificats TLS à l'aide d'un secret et en transmettant le secret à Ingress en utilisant *spec.tls[].secretName* .<br>

- créons un espace de noms de test et un exemple de service sur un serveur Web NGINX de base.

```
kubectl create namespace ingresstest
```

créons un déploiement NGINX
```
vi ingresstest-nginx-dep.yml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingresstest-nginx
  namespace: ingresstest
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ingresstest-nginx
  template:
    metadata:
      labels:
        app: ingresstest-nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

```
kubectl create -f ingresstest-nginx-dep.yml
```

créons un service de type ClusterIP pour ce déploiement
```
vi ingresstest-nginx-svc.yml
```

```
apiVersion: v1
kind: Service
metadata:
  name: ingresstest-nginx-svc
  namespace: ingresstest
spec:
  selector:
    app: ingresstest-nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

```
kubectl create -f ingresstest-nginx-svc.yml
```

Testons notre configuration sur le nœud du plan de contrôle
```
kubectl get svc -n ingresstest
```

```
curl <Service ClusterIP>
```

*\<Service ClusterIP\>* est l'adresse IP actuelle du service.<br>

- créons notre secret tls et notre ingress<br>

créons notre certificat
```
openssl req -nodes -new -x509 -keyout tls-ingress.key -out tls-ingress.crt -subj "/CN=ingress.test"
```

Obtenons une chaîne encodée en base64 pour le certificat et la clé.
```
base64 tls-ingress.crt
base64 tls-ingress.key
```

créons un secret pour contenir les données du certificat. Incluons le certificat et la clé codés en base64 dans ce fichier, le cas échéant.
```
vi ingress-tls-secret.yml
```

```
apiVersion: v1
kind: Secret
type: kubernetes.io/tls
metadata:
  name: ingress-tls
  namespace: ingresstest
data:
  tls.crt: |
    $(base64-encoded cert data from tls-ingress.crt)
  tls.key: |
    $(base64-encoded key data from tls-ingress.key)
```

```
kubectl create -f ingress-tls-secret.yml
```

créons un ingress pour le service avec terminaison TLS.
```
vi tls-ingress.yml
```

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
  namespace: ingresstest
spec:
  tls:
  - hosts:
    - ingress.test
    secretName: ingress-tls
  rules:
  - host: ingress.test
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ingresstest-nginx-svc
            port:
              number: 80
```

```
kubectl create -f tls-ingress.yml
```

Vérifions l'Ingress pour nous assurer qu'il répertorie un backend valide.
```
kubectl describe ingress tls-ingress -n ingresstest
```
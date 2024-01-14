# Gérer les comptes de services

Dans ce tutoriel, nous allons créer un compte de service et utiliser un objet rolebinding pour relier ce compte de service à un objet role.

## créer un simple compte de service
Nous définissons un objet serviceaccount *payment-serviceaccount* :
```
vi payment-serviceaccount.yml
```

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: payment-serviceaccount
```

```
kubectl create -f payment-serviceaccount.yml
```

L'on peut aussi créer un compte de service via la méthode impérative :
```
kubectl create sa payment-serviceaccount -n default
```

L'on peut afficher le détail de ce compte de service :
```
kubectl describe sa payment-serviceaccount
```

L'on peut lister les comptes de service dans un espace de nom :
```
kubectl get sa -n default
```

NB: **sa** est le dimunitif de l'objet **serviceAccount**.<br>

## attacher un role à un compte de service
Nous utiliserons le role **role-reader** défini dans le tutoriel précédent.
Nous créons un objet rolebinding *sa-rolebinding-reader* de l'espace de nom *default*
```
vi sa-rolebinding-reader.yml
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sa-rolebinding-reader
  namespace: default
subjects:
- kind: ServiceAccount
  name: payment-serviceaccount
  namespace: default
roleRef:
  kind: Role
  name: role-reader
  apiGroup: rbac.authorization.k8s.io
```

```
kubectl create -f sa-rolebinding-reader.yml
```
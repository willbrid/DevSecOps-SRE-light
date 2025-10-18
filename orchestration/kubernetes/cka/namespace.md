# Gestion des espaces de nom dans un cluster k8s

NB: Toutes ces commandes ci-dessous doivent être exécutées sur le noeud master.

**- lister les espaces de nom du cluster**

```
kubectl get namespaces
```

**- Spécifiez un espace de noms lorsque vous répertoriez d'autres objets**

On prendra l'exemple de lister les pods de l'espace de nom **kube-system**.

```
kubectl get pods --namespace kube-system
```

ou alors

```
kubectl get pods -n kube-system
```

**- Spécifiez tous les espaces de noms lorsque vous répertoriez d'autres objets**

On prendra l'exemple de lister les pods de tous les espaces de nom.

```
kubectl get pods --all-namespaces
```

ou alors

```
kubectl get pods -A
```

**- créer un espace de nom**

Dans cet exemple, on crée un espace de nom appelé **digitalisation**.

```
kubectl create namespace digitalisation
```
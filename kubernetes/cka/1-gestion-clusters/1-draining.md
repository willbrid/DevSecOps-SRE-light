# Méthode d'évincement des noeuds d'un cluster k8s

NB: Toutes ces commandes ci-dessous doivent être exécutées sur le noeud master. 
Nous prendrons l'exemple avec notre cluster déployé sur 3 noeuds : un noeud master k8s-control, deux noeuds workers : k8s-worker1, k8s-worker2.
<br>

**- Evincer un noeud en supprimant ses pods**
```
kubectl drain k8s-control --ignore-daemonsets --force
```

Ici les pods du noeud k8s-control seront supprimés et le noeud k8s-control sera marqué **non planifiable** c'est à dire k8s ne pourra plus déployé de pod sur ce noeud.

**- Evincer un noeud sans supprimer ses pods**
```
kubectl cordon k8s-worker1
```

Ici le noeud k8s-worker1 sera marqué non planifiable mais ses pods ne seront pas supprimés.

**- Vérifier l'état des noeuds et des pods du cluster après évincement**
```
kubectl get nodes

kubectl get pods -o wide -A
```

**- Remettre un noeud à l'état planifiable**
```
kubectl uncordon k8s-control

kubectl uncordon k8s-worker1
```

Ici les noeuds k8s-control et k8s-worker1 seront encore marqués **planifiable**.
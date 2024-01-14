# Méthode d'upgrade de k8s avec kubeadm
Nous prendrons l'exemple avec notre cluster déployé sur 3 noeuds : un noeud master k8s-control, deux noeuds workers : k8s-worker1, k8s-worker2.

- Version courante de k8s : 1.22<br>
- Version de mise à jour de k8s : 1.22.2

## Mise à jour du noeud master
**- Evincement du noeud master**
```
kubectl drain k8s-control --ignore-daemonsets
```

**- Mise à jour du package kudeadm**
```
sudo apt-get update && sudo apt-get install -y --allow-change-held-packages kubeadm=1.22.2-00
```

**- Vérification des composants k8s à upgrade sur le noeud master**
```
sudo kubeadm upgrade plan v1.22.2
```

NB: Cela présentera aussi les composants qui doivent être mis à jour manuellement après avoir mis à jour le noeud master avec '**kubeadm upgrade apply**'

**- Mise à jour de k8s sur le noeud master**
```
sudo kubeadm upgrade apply v1.22.2
```

**- Mise à jour des packages kubelet et kubectl sur le noeud master**
```
sudo apt-get update && sudo apt-get install -y --allow-change-held-packages kubelet=1.22.2-00 kubectl=1.22.2-00
```

**- Redemarrage du kubelet**
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

**- Remettre le noeud master à l'état planifiable**
```
kubectl uncordon k8s-control
```

**- Vérifier que le noeud master fonctionne**
```
kubectl get nodes
```

## Mise à jour des noeuds worker
Nous prendrons l'exemple avec le noeud worker k8s-worker1 et ce qui sera exactement la même procédure sur tous les autres noeuds worker.

**- Evincement du noeud worker sur le noeud master**
```
kubectl drain k8s-worker1 --ignore-daemonsets --force
```

**- Connexion par ssh sur le noeud worker**
```
ssh k8s-worker1
```

**- Mise à jour du package kudeadm sur le noeud worker**
```
sudo apt-get update && sudo apt-get install -y --allow-change-held-packages kubeadm=1.22.2-00
```

**- Mise à jour de la configuration du kubelet sur le noeud worker**
```
sudo kubeadm upgrade node
```

**- Mise à jour des packages kubelet et kubectl sur le noeud worker**
```
sudo apt-get update && sudo apt-get install -y --allow-change-held-packages kubelet=1.22.2-00 kubectl=1.22.2-00
```

**- Redemarrage du kubelet sur le noeud worker**
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

**- Remettre le noeud worker à l'état planifiable sur le noeud master**
```
kubectl uncordon k8s-worker1 
```

**- Vérifier que le cluster a été mis à jour sur le noeud master**
```
kubectl get nodes
```

NB: La mise à jour doit se faire sur tous les noeuds worker.
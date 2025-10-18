# Troubleshooter le cluster k8s
Si le serveur d'API K8s ne fonctionne plus, vous ne pourrez pas utiliser kubectl pour interagir avec le cluster.<br>
En supposant que votre kubeconfig est configuré correctement, cela peut signifier que le serveur API est en panne. Nous nous assurons que les services docker et kubelet sont opérationnels sur nos nœuds master.
<br>

- Nous obtenons la liste de nœuds et affichons leurs statuts, puis examinons un seul nœud de plus près :
```
kubectl get nodes
```

```
kubectl describe node <NODE_NAME>
```

- Nous vérifions le statut de notre service kubelet
```
sudo systemctl status kubelet
```

Si le kubelet n'est pas démarré alors nous faisons :
```
sudo systemctl start kubelet
sudo systemctl enable kubelet
```

- Nous vérifions le statut de nos pods de l'espace de noms *kube-system*
```
kubectl get pods -n kube-system
```

- Nous affichons le détail d'un pod de l'espace de noms *kube-system*
```
kubectl describe pod podname -n kube-system
```

- Nous pouvons consulter les journaux du composant *kube-apiserver*
```
kubectl logs -n kube-system <KUBE-APISERVER_POD_NAME>
```

- Nous pouvons consulter les journaux des services liés à k8s sur chaque nœud à l'aide de *journalctl*

```
sudo journalctl -u kubelet
sudo journalctl -u docker
```

- Nous pouvons aussi consulter le journal système sur chaque nœud à l'aide de journalctl
```
sudo journalctl --since="2022-02-07 07:00" --until="2022-02-07 10:00"
```

Les options *--since* et *--until* permettent de filtrer en définissant un intervalle de date.<br><br>

NB: Les composants du cluster Kubernetes ont une sortie de journal redirigée vers /var/log. Par exemple :
```
/var/log/kube-apiserver.log
/var/log/kube-scheduler.log
/var/log/kube-controller-manager.log
```

Notez que ces fichiers journaux peuvent ne pas apparaître pour les clusters *kubeadm*, car certains composants s'exécutent dans des conteneurs. Dans ce cas, vous pouvez y accéder avec : *kubectl logs*.
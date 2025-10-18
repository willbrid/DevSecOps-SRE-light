# Résoudre les problèmes de sécurité détectés par un benchmark CIS
La sortie CIS Benchmark comprend des étapes de correction que nous pouvons utiliser pour résoudre les problèmes.<br>
Les clusters kubeadm utilisent un fichier de configuration kubelet situé dans */var/lib/kubelet/config.yaml* sur chaque nœud.<br>
Dans un cluster kubeadm, les fichiers manifestes des composants du plan de contrôle se trouvent dans */etc/kubernetes/manifests* sur le serveur du plan de contrôle.<br>

- Corrigeons un problème de sécurité du plan de contrôle<br>

Nous affichons les résultats de *kube-bench* pour le plan de contrôle (ces résultats ont été générés dans l'astuce précédente (3-cis-benchmark)).
```
cat kube-bench-results-control-plane.log
```

Nous localisons la sortie du test 1.3.2 . Nous pouvons trouver les étapes de correction pour la sortie dans la section inférieure des résultats.<br>
Pour remédier à cet avertissement, nous désactivons l'authentification de profilage du *kube-controller-manager* .<br>
Dans un cluster kubeadm, le *kube-controller-manager* s'exécute en tant que pod statique. Modifions le fichier manifeste du *kube-controller-manager*.
```
sudo vi /etc/kubernetes/manifests/kube-controller-manager.yaml
```

Sous *spec.containers[0].command* , nous trouvons une liste d'arguments transmis au *kube-controller-manager*. Ajoutons *--profiling=false* à la liste et enregistrons le fichier.
```
spec:
  containers:
  - command:
    - kube-controller-manager
    - --profiling=false
  ...
```

Les modifications apportées à ce ﬁchier seront récupérées automatiquement. Cela peut prendre quelques instants pour que le nouveau *kube-controller-manager* démarre. On pourra aussi redemarrer le composant *kubelet* sur le noeud master k8s-control.

<br><br>

- Corrigeons un problème de sécurité des noeuds worker<br>

créons un problème de sécurité sur les nœuds worker qui sera détecté par le benchmark CIS et vérifions comment les résultats du benchmark répondent.<br>
Connectons-nous à nos deux noeuds et procédons comme suit :
<br>
--- modifions le fichier de configuration de kubelet.
```
sudo vi /var/lib/kubelet/config.yaml
```

--- Définissons *authentication.webhook.enabled* sur *false* et *authorization.mode* sur *AlwaysAllow* .
```
authentication:
  webhook:
    enabled: false
...
authorization:
  mode: AlwaysAllow
```

--- Redémarrons le kubelet.
```
sudo systemctl restart kubelet
```

--- Revenons au serveur du plan de contrôle et réexécutons le test de référence du nœud.
```
kubectl delete job kube-bench-node
kubectl create -f kube-bench-node.yaml
```

--- Obtenons le nouveau nom de pod du travail et vérifions les nouveaux résultats de référence du nœud.
```
kubectl get pods
```

```
kubectl logs <Node Job Pod name>
```

Recherchons les résultats de la vérification 4.2.2 dans le rapport.

--- Sur les deux nœuds worker, inversons les modifications *authn/authz* précédentes. Modifions le fichier de configuration de kubelet.
```
sudo vi /var/lib/kubelet/config.yaml
```

Définissons *authentication.webhook.enabled* sur *true* et *authorization.mode* sur *Webhook* .
```
authentication:
  webhook:
    enabled: true
...
authorization:
  mode: Webhook
```

Redémarrons le kubelet.
```
sudo systemctl restart kubelet
```

- Revenons au nœud du plan de contrôle. Supprimons les Jobs existants et relancez *kube-bench* pour le plan de contrôle et le worker.<br>
```
kubectl delete job kube-bench-master
kubectl create -f kube-bench-control-plane.yaml
kubectl delete job kube-bench-node
kubectl create -f kube-bench-node.yaml
```

Attendons que les jobs passent à l'état Terminé et enregistrons les journaux des Job Pods.
```
kubectl get pods
```

```
kubectl logs <Control Plane Job Pod name> > kube-bench-results-control-plane-fixed.log
kubectl logs <Node Job Pod name> > kube-bench-results-node-fixed.log
```

Vérifions les résultats des tests kube-bench. Nous devrions constater les résultats des tests que nous avons abordés [PASS]!
```
cat kube-bench-results-control-plane-fixed.log | grep "1.3.2 "
cat kube-bench-results-node-fixed.log | grep "4.2.2 "
```
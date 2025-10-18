# Exécuter un Benchmark CIS avec kube-bench

Center for Internet Security (CIS) est une organisation à but non lucratif dédiée à la promotion de la sécurité numérique.<br>
Les Benchmarks CIS sont un ensemble de normes communautaires et de bonnes pratiques consensuelles pour la sécurisation des systèmes.<br>
Le CIS Kubernetes Benchmark fournit une ligne directrice pour la sécurisation des environnements Kubernetes.<br>
*kube-bench* est un outil qui vérifie votre cluster pour voir dans quelle mesure il est conforme au CIS Kubernetes Benchmark. Il vérifie automatiquement votre cluster pour voir s'il est conforme aux normes CIS Kubernetes Benchmark et génère un rapport.<br>

- Téléchargeons les fichiers YAML du job kube-bench
```
wget -O kube-bench-control-plane.yaml https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-master.yaml

wget -O kube-bench-node.yaml https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-node.yaml
```

Nous avons ainsi un fichier yaml du job pour vérifier les noeuds master et un autre pour vérifier les noeuds workers.<br>

Si nous le souhaitons, nous pouvons examiner les fichiers pour voir ce qu'ils font.
```
cat kube-bench-control-plane.yaml
cat kube-bench-node.yaml
```

- créons les Jobs pour exécuter les tests de benchmark
```
kubectl create -f kube-bench-control-plane.yaml
kubectl create -f kube-bench-node.yaml
```

Vérifions l'état des jobs et attendons qu'ils soient tous les deux terminés (les pods de job passeront à l'état Terminé).
```
kubectl get pods
```

- Enregistrons les journaux des Job Pods pour visualiser facilement les résultats. Assurons-nous de fournir les noms réels des pods :
```
kubectl logs <Control Plane Job Pod name> > kube-bench-results-control-plane.log
kubectl logs <Node Job Pod name> > kube-bench-results-node.log
```

Nous consultons les résultats des tests kube-bench.
```
cat kube-bench-results-control-plane.log
cat kube-bench-results-node.log
```
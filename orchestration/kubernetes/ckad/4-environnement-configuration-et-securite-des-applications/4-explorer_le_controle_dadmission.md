# Explorer le contrôle d'admission
Les contrôleurs d'admission interceptent les requêtes adressées à l'API Kubernetes et peuvent être utilisés pour les valider et/ou les modifier.<br>
Vous pouvez activer les contrôleurs d'admission à l'aide de l'indicateur *--enable-admission-plugins* pour kube-apiserver.<br>

- créons un Pod dans un namespace qui n'existe pas
```
vi new-namespace-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: new-namespace-pod
  namespace: new-namespace
spec:
  containers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'while true; do echo Running...; sleep 5; done']
```

```
kubectl apply -f new-namespace-pod.yml
```

Cela échouera car l'espace de noms spécifié, *new-namespace* , n'existe pas.

- Modifions la configuration du serveur API pour activer le contrôleur d'admission *NamespaceAutoProvision*
```
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

Localisons l'indicateur *--enable-admission-plugins* et ajoutez *NamespaceAutoProvision* à la liste :
```
- --enable-admission-plugins=NodeRestriction,NamespaceAutoProvision
```

Lorsque nous enregistrez les modifications apportées à ce fichier, le serveur API est automatiquement recréé avec les nouveaux paramètres. Il peut devenir indisponible pendant quelques instants au cours de ce processus. La plupart des commandes kubectl échoueront pendant cette période, jusqu'à ce que le nouveau serveur d'API soit disponible.<br>

- Essayons de créer à nouveau notre *new-namespace-pod*
```
kubectl apply -f new-namespace-pod.yml
```

Cela devrait réussir cette fois, car le contrôleur d'admission *NamespaceAutoProvision* gérera automatiquement le processus de création de l'espace de noms.<br>
Nous pouvons lister les espaces de noms pour voir le nouvel espace de noms.
```
kubectl get namespace
```
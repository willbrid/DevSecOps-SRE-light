# Vérification des fichiers binaires de la plate-forme Kubernetes
Les binaires sont les fichiers exécutables utilisés pour exécuter les composants Kubernetes. *kubectl*, *kubeadm* et *kubelet* fonctionnent tous sur nos serveurs à l'aide de binaires.<br>

Lors de l'installation manuelle de fichiers binaires, nous pouvons vérifier qu'ils n'ont pas été altérés avant de les exécuter !<br>

Kubernetes fournit des fichiers de somme de contrôle pour leurs binaires. La somme de contrôle contient un hachage cryptographique calculé à partir du contenu d'un binaire valide.
Si notre binaire a été trafiqué, il ne correspondra pas !<br>

Lors de l'installation manuelle des fichiers binaires Kubernetes, nous pouvons valider les fichiers binaires à l'aide de la somme de contrôle pour nous assurer que les fichiers binaires n'ont pas été modifiés.<br>

- Obtenons la version de notre client kubectl.
```
kubectl version --short --client
```

Puis copions le numéro de version du client, y compris le *v* au début.

- Téléchargeons la somme de contrôle pour *kubectl*. Fournissons le numéro de version du client à partir de la commande précédente (y compris le *v* ).
```
curl -LO "https://dl.k8s.io/<kubectl client version>/bin/linux/amd64/kubectl.sha256"
```

- Vérifions le binaire kubectl à l'aide de la somme de contrôle.
```
echo "$(<kubectl.sha256) /usr/bin/kubectl" | sha256sum --check
```

Si le binaire est valide, nous devrions voir une sortie indiquant *OK* .
# Analyse des fichiers YAML de ressources

Nous pouvons effectuer une analyse statique sur les ressources Kubernetes. Pour le faire, nous pouvons notamment examiner les fichiers manifestes YAML utilisés pour créer des ressources dans notre cluster.<br>

Quelques éléments à rechercher :

- **Espaces de noms d'hôte** : si possible, ne laissons pas les conteneurs utiliser des espaces de noms d'hôte. Autrement dit dans la mesure du possible, évitons d'utiliser des espaces de noms d'hôte dans nos configurations de pod (c'est-à-dire avec **hostNetwork : true**, **hostIPC : true** ou **hostPID : true**).

- **Mode privilégié** : évitons d'utiliser le mode privilégié (c'est à dire **securityContext.privileged: true**) pour les conteneurs, sauf en cas d'absolue nécessité.

- **Tag *:latest*** : utilisons des tag fixes spécifiques pour référencer les images au lieu de tag non fixes telles que le tag *:latest*. Cela évite de télécharger automatiquement de nouvelles images potentiellement non vérifiées.

- **Exécuter en tant que root** : évitons d'exécuter en tant qu'utilisateur *root* ou *0* (c'est à dire via **securityContext.runAsUser**).<br>

Exemple de fichier yaml potentiellement vulnérable de déploiment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: static-analysis-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: static-analysis-deployment
  template:
    metadata:
      labels:
        app: static-analysis-deployment
    spec:
      hostIPC: true
      hostNetwork: true
      hostPID: true
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        securityContext:
          privileged: true
```

Une correction de ce fichier yaml consistera à :
- supprimer *hostIPC : true* , *hostNetwork : true* et *hostPID : true* .
- supprimer le *securityContext.privileged: true* du conteneur.
- remplacer le nom de l'image *nginx:latest* par une tag de version spécifique, telle que *nginx:1.19.10* .

Au final, nous avons notre contenu yaml :

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: static-analysis-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: static-analysis-deployment
  template:
    metadata:
      labels:
        app: static-analysis-deployment
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.10
        ports:
        - containerPort: 80
```
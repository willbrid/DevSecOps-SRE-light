# Installation et utilisation de Helm
Helm est un outil de gestion de packages pour les applications Kubernetes.<br>
Les Helm Charts sont des packages qui contiennent toutes les définitions de ressources nécessaires pour qu'une application soit opérationnelle dans un cluster.<br>
Un référentiel Helm est une collection de Charts et une source pour les parcourir et les télécharger.<br>

## Installation de Helm
Nous configurons la clé Helm GPG et le référentiel de packages.
```
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
```

```
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
```

Nous mettons à jour la liste des packages et installons le package helm
```
sudo apt-get update
```

```
sudo apt-get install -y helm
```

Nous pouvons vérifier la version de helm installée !
```
helm version
```

## Utilisation de helm
Nous installerons le chart *dokuwiki*.<br>
Nous ajoutons un référentiel de chartes Helm appelé : *bitnami*.
```
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Nous mettons à jour notre réfentiel local helm :
```
helm repo update
```

Nous pouvons lister l'ensemble des charts disponible dans le référentiel *bitnami* :
```
helm search repo bitnami
```

Nous créons un namespace *dokuwiki* dans lequel nous installerons notre chart *dokuwiki*.
```
kubectl create namespace dokuwiki
```

Nous installons le chart *dokuwiki* dans le namepsace *dokuwiki* :
```
helm install --set persistence.enabled=false -n dokuwiki dokuwiki bitnami/dokuwiki
```

Nous pouvons afficher certains des objets créés par l'installation du chart dokuwiki .
```
kubectl get pods -n dokuwiki
kubectl get deployments -n dokuwiki
kubectl get svc -n dokuwiki
```

Nous pouvons installer et supprimer le chart installé *dokuwiki* et supprimer le namespace *dokuwiki* :
```
helm uninstall -n dokuwiki dokuwiki
kubectl delete namespace dokuwiki
```
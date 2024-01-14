# Configuration d'un scanner d'images

Afin de scanner les images entrantes à l'aide d'**ImagePolicyWebhook**, nous avons besoin d'une application capable de recevoir les demandes de webhook et d'effectuer le scan de l'image. <br>
Notre objectif sera d'installer et de configurer une telle application afin que notre cluster puisse l'utiliser.<br>

- Le contrôleur d'admission **ImagePolicyWebhook** envoie une requête JSON à un service externe pour déterminer si les images sont autorisées.
- Le service externe fournit une réponse JSON indiquant si les images sont autorisées ou non.

Il existe un exemple d'application de webhook dont nous pouvons trouver le code source sur https://github.com/linuxacademy/content-cks-trivy-k8s-webhook <br>
 
Téléchargeons et installons le manifeste de pod statique pour le backend Trivy **ImagePolicyWebhook** :

```
wget https://raw.githubusercontent.com/linuxacademy/content-cks-trivy-k8s-webhook/main/trivy-k8s-webhook.yml
```

```
sudo mv trivy-k8s-webhook.yml /etc/kubernetes/manifests
```

```
sudo chown root:root /etc/kubernetes/manifests/trivy-k8s-webhook.yml
```

```
sudo chmod 600 /etc/kubernetes/manifests/trivy-k8s-webhook.yml
```

Assurons-nous que le pod s'exécute :

```
kubectl get pod -n kube-system trivy-k8s-webhook-k8s-control
```

Ajoutons une entrée au fichier hosts pour le webhook sur notre noeud **control plan** :

```
sudo vi /etc/hosts
```

```
127.0.0.1 acg.trivy.k8s.webhook
```

Faisons une demande de test au webhook :

```
curl https://acg.trivy.k8s.webhook:8090/scan -X POST --header "Content-Type: application/json" -d '{"spec":{"containers":[{"image":"nginx:1.19.10"},{"image":"nginx:1.14.1"}]}}' -k
```
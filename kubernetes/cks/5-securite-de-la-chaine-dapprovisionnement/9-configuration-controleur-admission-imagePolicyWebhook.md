# Configuration du contrôleur d'admission ImagePolicyWebhook

Maintenant que nous avons une application webhook capable de scanner nos images, nous devons configurer le cluster pour communiquer avec lui.
Nous allons configurer le contrôleur d'admission **ImagePolicyWebhook** pour utiliser le webhook pour analyser les images entrantes et refuser celles qui présentent de graves vulnérabilités.

- Utilisons le paramètre **--enable-admission-plugins** dans le manifeste **kube-apiserver** pour activer le contrôleur d'admission **ImagePolicyWebhook**.
- Utilisons le paramètre **--admission-control-config-file** pour spécifier l'emplacement du fichier de configuration du contrôleur d'admission.
- Si les fichiers de configuration se trouvent sur le système de fichiers hôte, nous devons peut-être les monter sur le conteneur **kube-apiserver**.
- Dans la configuration du contrôleur d'admission, **kubeConfigFile** spécifie l'emplacement d'un fichier **kubeconfig**. Ce fichier indique à **ImagePolicyWebhook** comment atteindre le backend du webhook.
- Dans la configuration du contrôleur d'admission, **defaultAllow** contrôle si les charges de travail seront autorisées ou non si le webhook backend est inaccessible.<br>

Sur la master, créons un répertoire pour héberger les configurations de contrôle d'admission :

```
sudo mkdir /etc/kubernetes/admission-control
```

Téléchargeons les certificats CA et client, dont nous aurons besoin pour configurer **ImagePolicyWebhook** :

```
sudo wget -O /etc/kubernetes/admission-control/imagepolicywebhook-ca.crt https://raw.githubusercontent.com/linuxacademy/content-cks-trivy-k8s-webhook/main/certs/ca.crt
```

```
sudo wget -O /etc/kubernetes/admission-control/api-server-client.crt https://raw.githubusercontent.com/linuxacademy/content-cks-trivy-k8s-webhook/main/certs/api-server-client.crt
```

```
sudo wget -O /etc/kubernetes/admission-control/api-server-client.key https://raw.githubusercontent.com/linuxacademy/content-cks-trivy-k8s-webhook/main/certs/api-server-client.key
```

Créons un fichier de configuration du contrôleur d'admission :

```
sudo vi /etc/kubernetes/admission-control/admission-control.conf
```

```
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: ImagePolicyWebhook
  configuration:
    imagePolicy:
      kubeConfigFile: /etc/kubernetes/admission-control/imagepolicywebhook_backend.kubeconfig
      allowTTL: 50
      denyTTL: 50
      retryBackoff: 500
      defaultAllow: true
```

Créons un fichier **kubeconfig** avec les informations de connexion pour l'application webhook :

```
sudo vi /etc/kubernetes/admission-control/imagepolicywebhook_backend.kubeconfig
```

```
apiVersion: v1
kind: Config
clusters:
- name: trivy-k8s-webhook
  cluster:
    certificate-authority: /etc/kubernetes/admission-control/imagepolicywebhook-ca.crt
    server: https://acg.trivy.k8s.webhook:8090/scan
contexts:
- name: trivy-k8s-webhook
  context:
    cluster: trivy-k8s-webhook
    user: api-server
current-context: trivy-k8s-webhook
preferences: {}
users:
- name: api-server
  user:
    client-certificate: /etc/kubernetes/admission-control/api-server-client.crt
    client-key: /etc/kubernetes/admission-control/api-server-client.key
```

Activons le contrôleur d'admission **ImagePolicyWebhook** :

```
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

Recherchons la ligne qui commence par **--enable-admission-plugins** et ajoutons **ImagePolicyWebhook** à la liste :

```
- --enable-admission-plugins=NodeRestriction,ImagePolicyWebhook
```

Ajoutons une nouvelle ligne après **- kube-apiserver** pour référencer la configuration du contrôle d'admission :

```
- --admission-control-config-file=/etc/kubernetes/admission-control/admission-control.conf
```

Sous la section volumes, ajoutons un volume pour monter le répertoire de configuration du contrôle d'admission :

```
volumes:
- name: admission-control
  hostPath:
    path: /etc/kubernetes/admission-control
    type: DirectoryOrCreate
```

Sous **volumeMounts**, montons le volume sur le conteneur :

```
volumeMounts:
- name: admission-control
  mountPath: /etc/kubernetes/admission-control
  readOnly: true
```

Créons un premier pod de test :

```
vi imagepolicy-busybox-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: imagepolicy-busybox-pod
spec:
  restartPolicy: Never
  containers:
  - name: busybox
    image: busybox:1.33.1
```

```
kubectl create -f imagepolicy-busybox-pod.yml
```

Ce pod devrait réussir à s'éxécuter.
<br><br>
Créons un deuxième pod de test :
```
vi imagepolicy-nginx-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: imagepolicy-nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
```

```
kubectl create -f imagepolicy-nginx-pod.yml
```

Ce pod échouera.<br>

Pour désactiver le **ImagePolicyWebhook**, nous modifions le manifeste **kube-apiserver** :

```
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

Nous supprimons **ImagePolicyWebhook** de la liste **--enable-admission-plugins** :

```
- --enable-admission-plugins=NodeRestriction
```
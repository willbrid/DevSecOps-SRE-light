# Analyse des images pour les vulnérabilités connues

Une vulnérabilité logicielle est une faille ou une faiblesse dans un logiciel qui peut être utilisée par un attaquant.<br>
Les chercheurs en sécurité travaillent constamment pour découvrir et documenter les vulnérabilités.<br>

L'analyse des vulnérabilités consiste à utiliser des outils pour détecter les vulnérabilités connues de notre logiciel.<br>
Dans Kubernetes, l'analyse d'images signifie analyser les images de conteneurs pour voir si elles incluent des logiciels vulnérables.

## Trivy

**Trivy** est un outil en ligne de commande qui nous permet d'analyser les images de conteneurs à la recherche de vulnérabilités. **Trivy** est facile à utiliser. Par example :

```
trivy image nginx:1.14.1
```

**Trivy** génère un rapport qui répertorie les vulnérabilités connues trouvé dans l'image. Il présente son rapport sous forme de tableau dont certaines colonnes sont les suivantes :

- **LIBRARY** - quelle bibliothèque de logiciels est affectée.
- **VULNERABILITY ID** - un identifiant unique pour la vulnérabilité.
- **SEVERITY** - indique le niveau de risque de sécurité créé par la vulnérabilité.<br>

Installons **Trivy** sur notre nœud de plan de contrôle

- Sous **Ubuntu 20.04**

```
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
```

```
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
```

```
sudo apt-get update && sudo apt-get install -y trivy
```

- Sous **Rocky 8.x**

```
sudo vi /etc/yum.repos.d/trivy.repo
```

```
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/$releasever/$basearch/
gpgcheck=0
enabled=1
```

```
sudo yum -y update && sudo yum -y install trivy
```

Si nous avons besoin d'obtenir le nom et le tag de l'image d'un conteneur existant, nous pouvons le faire en utilisant **kubectl get pods**

```
kubectl get pods --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image"
```

Scannons une image avec Trivy

```
sudo crictl pull nginx:1.14.1
```

```
trivy image nginx:1.14.1
```

Nous pouvons effectuer un scan pour détecter uniquement les niveaux de risque de sécurité : **HIGH** ou **CRITICAL** 

```
trivy image -s HIGH,CRITICAL nginx:1.14.1
```
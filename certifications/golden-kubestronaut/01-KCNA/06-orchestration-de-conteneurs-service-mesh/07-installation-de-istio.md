# Installer Istio sur le cluster

Il y'a **trois approches différentes** pour installer Istio :
1. **istioctl** : l'utilitaire en ligne de commande d'Istio ;
2. **Helm** : le package manager de Kubernetes ;
3. **Istio operator** : un opérateur qui gère l'installation — ⚠️ **déprécié dans Istio 1.23 et supprimé dans Istio 1.24**. À ne plus utiliser pour de nouvelles installations ; les installations existantes basées sur l'opérateur doivent migrer vers **istioctl** ou **Helm**.

### Installer istioctl

Avant d'installer Istio, il faut télécharger Istio et disposer du binaire **istioctl**.

```bash
cd $HOME

# Télécharger la dernière version d'Istio
curl -L https://istio.io/downloadIstio | sh -

# (Optionnel) Télécharger une version précise, ex. Istio 1.31.0
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.31.0 sh -

# Se placer dans le répertoire téléchargé
cd istio-*

# Ajouter istioctl au PATH pour l'utiliser depuis n'importe où
export PATH=$PWD/bin:$PATH

# Vérifier que istioctl est disponible
istioctl version
```

### Installation avec istioctl

Pour installer Istio avec istioctl, on lance **`istioctl install`** en spécifiant un profil avec le champ d'option **profile** :
- on peut utiliser le **profile `demo`** ;
- Il existe aussi d'autres profiles pour la **production** et les **tests de performance** ;
- **Point important** : différents environnements nécessitent différents **profiles**.

```bash
# Installation avec le profile par défaut
istioctl install --set profile=default -y

# Ou avec le profile demo
istioctl install --set profile=demo -y

# Installation avec un fichier de configuration personnalisé
istioctl install -f my-istio-config.yaml -y
```

Exemple de fichier de configuration personnalisé (`my-istio-config.yaml`), basé sur l'API **IstioOperator** (cette **API** reste utilisée par istioctl même si l'opérateur in-cluster est supprimé) :

```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: istio-control-plane
  namespace: istio-system
spec:
  profile: demo
  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
```

### Ce que déploie l'installation

Lorsque la commande d'installation est exécutée, Istio est déployé dans le cluster sous la forme d'un **Deployment nommé `istiod`**, dans un nouveau **namespace appelé `istio-system`**.

Rappel : **`istiod`** contient les différents composants (anciennement **Citadel, Pilot et Galley**, désormais fusionnés). En plus de cela, l'installation déploie aussi **deux autres services** :
- **Istio Egress Gateway** ;
- **Istio Ingress Gateway** ;

ainsi que **plusieurs objets Service Kubernetes** pour exposer les services au cluster.

### Vérifier l'installation

Une fois installé, lancer la commande de **vérification** :

```bash
kubectl get pods -n istio-system

kubectl get svc -n istio-system
```

### Istio étend Kubernetes via des CRDs

Istio **étend Kubernetes** : on peut donc voir des **CRDs (Custom Resource Definitions)** ajoutées au cluster.

```bash
kubectl get crds | grep -i istio
```

### À retenir

- **Installer istioctl** d'abord : `curl -L https://istio.io/downloadIstio | sh -`, puis ajouter `bin/` au **PATH**.
- Installation via **`istioctl install --set profile=demo`** ; le profile **demo** sert aux démos, d'autres profiles existent pour la **production** et les **tests de perf**.
- **Helm** est une alternative supportée (base → istiod → gateway).
- L'**opérateur Istio in-cluster** est **déprécié (1.23) et supprimé (1.24)** → utiliser **istioctl** ou **Helm**.
- Istio se déploie comme un **Deployment `istiod`** dans le namespace **`istio-system`**, plus les **Istio Ingress/Egress Gateways** et des objets **Service**.
- Istio étend Kubernetes via des **CRDs** (`kubectl get crds`).

### Liens utiles

- Documentation officielle Istio – Installation : https://istio.io/latest/docs/setup/install/
- Télécharger Istio (getting started) : https://istio.io/latest/docs/setup/getting-started/
- Installation avec istioctl : https://istio.io/latest/docs/setup/install/istioctl/
- Installation avec Helm : https://istio.io/latest/docs/setup/install/helm/
- Profiles d'installation : https://istio.io/latest/docs/setup/additional-setup/config-profiles/

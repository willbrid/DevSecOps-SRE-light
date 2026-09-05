# Déploiement d'une application dans Istio

Pour déployer notre première application sur Istio, on utilise l'application d'exemple **Bookinfo** fournie dans le dossier **samples** téléchargé avec Istio.

```bash
kubectl create namespace bookinfo

# Déployer l'application Bookinfo
kubectl apply -f ~/istio-1.31.0/samples/bookinfo/platform/kube/bookinfo.yaml -n bookinfo
```

> Si les samples d'Istio sont ailleurs sur votre ordinateur, vous pouvez **changer de répertoire**. La sortie montre un certain nombre de **deployments** et de **services** créés.

### Vérifier le statut des pods

```bash
kubectl get pods -n bookinfo
```

On observe :
- **un pod** pour le microservice **productpage** ;
- des pods pour les microservices **details**, **ratings** ;
- **trois versions** du service **reviews** (v1, v2, v3).

Tout est déployé dans le **namespace `bookinfo`**.

### Le problème : pas de sidecar injecté

Maintenant qu'Istio est installé, on s'attendait à ce que **chaque pod ait le container Envoy proxy supplémentaire** dont on a parlé. **Pourtant, ce n'est pas le cas** !

Dans la colonne **READY**, on voit que chaque pod n'a qu'**un seul container** (ex. `1/1` au lieu de `2/2`). Pourquoi ?

#### Diagnostic avec istioctl analyze

```bash
istioctl analyze -n bookinfo
```

L'analyse indique qu'il y a un problème : **l'istio-injection n'est PAS activée** dans le namespace **bookinfo**.

### Comprendre l'istio-injection par namespace

**Que signifie qu'un namespace n'est pas activé pour l'istio-injection ?**

- Sur un cluster Kubernetes, il existe **plusieurs namespaces** :
  - certains, comme **`kube-system`**, font tourner les **applications core** ;
  - **`default`** est le namespace par défaut quand aucun n'est spécifié (c'est notre cas ici) ;
  - il peut y avoir d'autres applications dans d'autres namespaces, comme **HR** ou **payroll**, etc.
- Il faut donc **activer explicitement** l'injection de sidecar Istio **au niveau du namespace** si l'on veut qu'Istio injecte les proxies **en tant que sidecars** aux applications déployées dans ce namespace.

### Activer / désactiver l'injection de sidecar

L'injection se contrôle via un **label** sur le namespace, réglé sur **`istio-injection=enabled`** :

```bash
# Activer l'injection de sidecar sur un namespace
kubectl label namespace <namespace> istio-injection=enabled

# Désactiver explicitement l'injection
kubectl label namespace <namespace> istio-injection=disabled
```

### Appliquer et redéployer

**Étape 1** : supprimer ce qui a été déployé afin de pouvoir définir le label puis redéployer :
```bash
kubectl delete -f ~/istio-1.31.0/samples/bookinfo/platform/kube/bookinfo.yaml
```

**Étape 2** : activer l'istio-injection dans le namespace `default` :

```bash
kubectl label namespace bookinfo istio-injection=enabled
```

> **Point clé** : une fois cette commande exécutée, **chaque nouvelle app** déployée dans le namespace `bookinfo` recevra **automatiquement un sidecar**.

**Étape 3** : redéployer l'application, puis vérifier le mesh et la présence des sidecars Envoy :

```bash
kubectl apply -f ~/istio-1.31.0/samples/bookinfo/platform/kube/bookinfo.yaml -n bookinfo
kubectl get pods -n bookinfo
```

Cette fois, les sidecars **sont bien là** et l'application tourne : chaque pod affiche désormais **`2/2`** dans la colonne READY (le container applicatif **+** le sidecar Envoy).

> Istio a donc **injecté des sidecar proxies** dans chaque pod → Istio est désormais **configuré avec succès** sur le cluster.

### Récapitulatif du workflow

| Étape | Commande |
|-------|----------|
| Déployer l'app | `kubectl apply -f .../bookinfo.yaml -n bookinfo` |
| Vérifier les pods | `kubectl get pods -n bookinfo` |
| Diagnostiquer | `istioctl analyze -n bookinfo` |
| Activer l'injection | `kubectl label namespace bookinfo istio-injection=enabled` |
| Supprimer | `kubectl delete -f .../bookinfo.yaml -n bookinfo` |
| Redéployer | `kubectl apply -f .../bookinfo.yaml -n bookinfo` |

### À retenir

- On déploie l'app d'exemple **Bookinfo** depuis le dossier **samples** d'Istio (`kubectl apply -f .../bookinfo.yaml`).
- **Par défaut, les sidecars ne sont PAS injectés** → les pods affichent `1/1` au lieu de `2/2`.
- **`istioctl analyze`** diagnostique le problème (istio-injection non activée).
- L'injection de sidecar s'active **au niveau du namespace** via le label **`istio-injection=enabled`** (et `=disabled` pour la désactiver).
- Le label injecte **automatiquement** un sidecar Envoy dans **toute nouvelle app** déployée dans ce namespace.
- Après activation + redéploiement, chaque pod a **2 containers** (`2/2`) : l'application **+** le proxy Envoy.

### Liens utiles

- Documentation officielle Istio – Injection de sidecar : https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/
- Application d'exemple Bookinfo : https://istio.io/latest/docs/examples/bookinfo/
- Getting Started (déploiement de l'app) : https://istio.io/latest/docs/setup/getting-started/

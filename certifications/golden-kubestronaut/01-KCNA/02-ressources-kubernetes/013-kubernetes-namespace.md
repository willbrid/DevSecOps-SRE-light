# Kubernetes namespaces

Les **namespaces** permettent d'**isoler les ressources et les politiques** au sein d'un même cluster Kubernetes, ce qui est essentiel en environnement de production.

### L'analogie (pour comprendre)

Imaginez deux garçons nommés Mark : dans leur foyer respectif, on utilise le prénom seul ; les personnes extérieures utilisent le nom complet (Mark Smith, Mark Williams) pour éviter la confusion. De même, **chaque namespace agit comme un foyer distinct**, avec ses propres règles et ressources.

### Les namespaces par défaut et système

Kubernetes crée plusieurs namespaces au démarrage :
- **default** : namespace par défaut où sont créés les objets (Pods, Deployments, Services) sauf indication contraire.
- **kube-system** : contient les Pods et Services critiques (réseau, DNS…), isolés de l'utilisateur pour éviter les modifications accidentelles.
- **kube-public** : contient les ressources accessibles à tous les utilisateurs.

En environnement d'apprentissage, on peut rester dans `default`. En entreprise/production, les namespaces sont cruciaux : par exemple, isoler **dev** et **prod** sur un même cluster évite les interférences accidentelles. Chaque namespace peut imposer ses propres **politiques et quotas de ressources**.

### Découverte de services par DNS

- **Même namespace** : un Pod peut joindre un Service simplement par son **nom**.
- **Namespace différent** : il faut utiliser le **nom DNS complet (FQDN)** :

  ```
  db-service.dev.svc.cluster.local
  ```
  Décomposition :
  - `db-service` → nom du service ;
  - `dev` → namespace ;
  - `svc` → sous-domaine des services ;
  - `cluster.local` → domaine par défaut du cluster.

Exemple en Python :

```python
mysql.connect("db-service.dev.svc.cluster.local")
```

### Commandes kubectl et namespaces

#### Lister les Pods

```bash
kubectl get pods                          # namespace "default"
kubectl get pods --namespace=kube-system  # un namespace spécifique
kubectl get pods --all-namespaces         # tous les namespaces
```

#### Créer un Pod dans un namespace

```bash
kubectl create -f pod-definition.yml               # dans "default"
kubectl create -f pod-definition.yml --namespace=dev  # dans "dev"
```

Pour qu'un Pod soit **toujours** créé dans un namespace donné, l'inclure dans le fichier de définition sous `metadata` :

```yaml
metadata:
  name: myapp-pod
  namespace: dev
  ...
```

#### Créer un namespace

Via un fichier de définition :

```yaml
# namespace-dev.yml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

```bash
kubectl create -f namespace-dev.yml
```

Ou directement en ligne de commande :

```bash
kubectl create namespace dev
```

#### Changer le namespace actif (point essentiel)

Pour basculer **de façon permanente** vers un autre namespace dans le contexte courant :

```bash
kubectl config set-context $(kubectl config current-context) --namespace=dev
```

Ensuite, `kubectl get pods` listera les Pods de `dev`. Pour voir d'autres namespaces, réutiliser le flag `--namespace`.

### Quotas de ressources (ResourceQuota)

On limite les ressources d'un namespace via un objet **ResourceQuota** :

```yaml
# compute-quota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: dev
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 5Gi
    limits.cpu: "10"
    limits.memory: 10Gi
```

```bash
kubectl create -f compute-quota.yaml
```

Cela garantit que le namespace `dev` ne dépasse pas les limites définies.

### À retenir

- Les namespaces **isolent** ressources, politiques et quotas au sein d'un même cluster (idéal pour séparer dev/prod).
- 3 namespaces système au démarrage : **default**, **kube-system**, **kube-public**.
- DNS : nom simple dans le même namespace, **FQDN** (`service.namespace.svc.cluster.local`) entre namespaces différents.
- Cibler un namespace : flag `--namespace` (ponctuel), champ `namespace` dans le YAML (permanent pour l'objet), ou `set-context` (permanent pour le contexte).
- `--all-namespaces` pour tout voir ; **ResourceQuota** pour limiter les ressources.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Docker Hub : https://hub.docker.com/

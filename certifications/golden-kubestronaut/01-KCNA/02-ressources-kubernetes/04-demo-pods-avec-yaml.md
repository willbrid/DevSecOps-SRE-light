# Démo pods avec Yaml

Ce contenu montre comment créer un pod Kubernetes à partir d'un **fichier de définition YAML** plutôt qu'avec la commande `kubectl run`. Définir les spécifications en YAML offre un **meilleur contrôle de la configuration** et constitue une **bonne pratique** de gestion Kubernetes.

### Les étapes

#### Étape 1 : Créer le fichier YAML

```bash
vim pod.yaml
```

#### Étape 2 : Définir la structure du Pod

Spécifier les **4 propriétés racines essentielles** :
- **apiVersion** : `v1` pour les pods.
- **kind** : `Pod` (**sensible à la casse**).
- **metadata** : dictionnaire contenant le nom et les labels.
- **spec** : spécifications du pod, incluant la liste des conteneurs.

> **Point crucial** : toujours utiliser des **espaces pour l'indentation** (de préférence **2 espaces**) et **éviter les tabulations** pour garantir la validité du YAML.

#### Étape 3 : Configurer les conteneurs

Dans la section **spec**, ajouter la propriété **containers** (une **liste** d'objets conteneurs). Chaque conteneur doit avoir :
- un **nom** unique (ex. `nginx`) ;
- une **référence d'image** (ex. `nginx`).

Pour plusieurs conteneurs, ajouter d'autres objets à la liste.

### Configuration YAML complète

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
    tier: frontend
spec:
  containers:
  - name: nginx
    image: nginx
```

#### Étape 4 : Sauvegarder (sous Vim)

```bash
:wq
```

#### Étape 5 : Vérifier le contenu du fichier

```bash
cat pod.yaml
```

Bien vérifier l'**alignement (indentation)** de `metadata` et `spec` — une indentation correcte garantit un parsing correct par Kubernetes.

#### Étape 6 : Créer le Pod

On peut utiliser **`create`** ou **`apply`** avec l'option `-f` pointant vers le fichier YAML :

```bash
kubectl apply -f pod.yaml
```

Résultat : `pod/nginx created`.

#### Étape 7 : Vérifier le statut

```bash
kubectl get pods
```
Le pod affiche d'abord `ContainerCreating`, puis passe à `Running`.

Pour les détails complets (utiles pour le dépannage) :

```bash
kubectl describe pod nginx
```

### À retenir

- Définir un pod en YAML est une **bonne pratique** : reproductibilité et clarté accrues.
- Les **4 champs** obligatoires : `apiVersion`, `kind`, `metadata`, `spec`.
- **Indentation avec 2 espaces**, jamais de tabulations.
- `kind: Pod` est **sensible à la casse**.
- `containers` est une **liste** (chaque conteneur commence par un tiret `-`).
- Déployer avec `kubectl create -f` **ou** `kubectl apply -f`, puis vérifier avec `kubectl get pods` et `kubectl describe pod`.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/

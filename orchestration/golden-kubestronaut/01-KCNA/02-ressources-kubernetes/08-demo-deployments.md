# Démo Deployments

Ce contenu montre comment créer un **Deployment** Kubernetes à partir d'une définition très proche de celle d'un **ReplicaSet**, de la mise en place des fichiers jusqu'à la vérification dans le cluster.

### Les étapes

#### Étape 1 : Préparer le répertoire

Créer un dossier `deployments` et, à l'intérieur, un fichier `deployment.yaml`.

> Un éditeur en **vue partagée (split)** aide à comparer côte à côte le Deployment et la définition ReplicaSet existante.

#### Étape 2 : Baser le Deployment sur le ReplicaSet

Même `apiVersion` (`apps/v1`), mais changer le `kind` en `Deployment` (**seule différence majeure**) :

```yaml
apiVersion: apps/v1
kind: Deployment
```

#### Étape 3 : Définir les metadata

```yaml
metadata:
  name: myapp-deployment
  labels:
    tier: frontend
    app: nginx
```

#### Étape 4 : Configurer la section spec

La section `spec` est **très similaire** à celle du ReplicaSet (on peut la copier et l'adapter) :

```yaml
spec:
  selector:
    matchLabels:
      app: myapp
  replicas: 3
  template:
    metadata:
      name: nginx-2
      labels:
        app: myapp
    spec:
      containers:
        - name: nginx
          image: nginx
```

> Rappel : les labels du `selector` (`matchLabels`) et du `template` doivent **correspondre exactement**.

#### Étape 5 : Déployer

```bash
kubectl create -f deployment.yaml
kubectl get deployments
```

```
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
myapp-deployment    3/3     3            3           10s
```

Colonnes clés : **READY** (ex. `3/3`), **UP-TO-DATE** (à jour), **AVAILABLE** (disponibles).

#### Étape 6 : Vérifier les Pods et les détails

```bash
kubectl get pods
```

Point à noter : les pods portent le nom du **ReplicaSet** (`myapp-replicaset-xxxx`), pas directement celui du Deployment — car le Deployment crée un ReplicaSet qui, lui, crée les pods.

```bash
kubectl describe deployment myapp-deployment
```

Fournit des informations complètes : nom, namespace, labels, détails du template de pod et événements de scaling.

#### Étape 7 : Lister tous les objets

```bash
kubectl get all
```
Affiche le **Deployment**, son **ReplicaSet** associé et les **trois Pods** gérés — illustrant la hiérarchie automatique.

### À retenir

- Créer un Deployment est quasi identique à créer un ReplicaSet : il suffit de mettre **`kind: Deployment`**.
- Le Deployment crée automatiquement un **ReplicaSet**, qui crée et gère les **Pods** (d'où les noms de pods préfixés par le nom du ReplicaSet).
- Les **labels du selector et du template doivent correspondre**.
- Commandes clés : `kubectl create -f`, `kubectl get deployments`, `kubectl get pods`, `kubectl describe deployment`, `kubectl get all`.
- `kubectl get all` reste le meilleur moyen de visualiser la hiérarchie **Deployment → ReplicaSet → Pods**.

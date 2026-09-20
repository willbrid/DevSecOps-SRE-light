# Introduction ArgoCD

### Dépôt Git

Le pipeline de continuous deployment est piloté par un dépôt Git dédié contenant tous les manifests Kubernetes et fichiers YAML nécessaires. <br>
Dans le dépôt (nommé **CDPipeline**), on trouve un dossier **nginx-deployment** contenant un unique fichier **deployment.yaml**. <br>
Le fichier **deployment.yaml** fournit une configuration minimaliste déployant une instance NGINX (1 replica) :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

### Interface ArgoCD

> **Prérequis** : Argo CD doit être **installé** et vous devez être **connecté à l'UI**.

Étapes pour configurer une nouvelle application dans Argo CD :

1. Ouvrir le dialogue "`New Application`"

Cliquer sur le bouton **New App** (coin supérieur gauche de l'interface).

2. Renseigner les détails de l'application

Une pop-up demande les informations suivantes :
- **Application Name** et **Project Name** : saisir les noms souhaités ;
- **Source Section** :
  - Spécifier l'**URL du dépôt** contenant les manifests Kubernetes (établit la connexion dépôt ↔ Argo CD) ;
  - Optionnellement, définir une **révision** spécifique (par défaut, Argo CD surveille la révision **HEAD**) ;
  - Définir le **path** vers le dossier contenant les fichiers YAML dans le dépôt.

3. Configurer la Destination

Indiquer **où** le déploiement sera appliqué :
- **Cluster URL** : l'URL du cluster Kubernetes cible ;
- **Target Namespace** : le namespace où l'application sera déployée.

4. Paramètres additionnels (optionnels)

- Le bouton **Edit as YAML** permet de voir/modifier les options de configuration avancées ;
- Activer la fonctionnalité **Self-Heal** (la mettre à `true`) : cela permet à Argo CD d'**appliquer automatiquement** les changements du dépôt GitOps vers le cluster → assure un **continuous deployment automatisé**.

5. Vérifier et créer

Après avoir fourni l'**URL du dépôt Git**, sélectionné le **cluster** (typiquement `kubernetes.default.svc`) et spécifié le **namespace** (ex. `default`), vérifier tous les détails, puis cliquer sur **Create** pour finaliser.

### Vérification du déploiement

- Vérifier le namespace default (avant)

D'abord, vérifier qu'**aucun pod** ne tourne dans le namespace `default` :
```bash
% kubectl get pods
No resources found in default namespace.
```

Le namespace est initialement **vide**.

- Provisioning automatique par ArgoCD

Après une **brève attente**, relancer la commande : un pod est en cours de création :
```bash
% kubectl get po
NAME                                READY   STATUS              RESTARTS   AGE
nginx-deployment-6b7f675859-hx95j   0/1     ContainerCreating   0          18s
```

→ Cela indique que le **fichier deployment.yaml a été appliqué automatiquement par Argo CD**.

Une fois le pod opérationnel :
```bash
% kubectl get po
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-6b76765859-hx95j   1/1     Running   0          55s
```

> Argo CD **surveille le dépôt Git** et, dès qu'il détecte de **nouvelles définitions de ressources**, il les **provisionne automatiquement** dans le namespace `default` — **sans aucune commande `kubectl apply` manuelle**.

- Mettre à jour le manifest (le cœur de GitOps)

Étape suivante : **augmenter le nombre de replicas de 1 à 3**.

Fichier YAML original :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1        # ← passer cette valeur à 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

**Le workflow GitOps** : après avoir mis `replicas: 3`, on **sauvegarde** et on **commit** les changements dans le **dépôt Git** hébergeant le manifest. Argo CD **détecte la mise à jour** et **provisionne les pods supplémentaires** en conséquence.

> **Point essentiel** : on ne modifie **jamais** le cluster directement — on modifie **Git**, et Argo CD réconcilie l'état du cluster pour correspondre à l'état désiré.

- Observer les changements dans l'UI Argo CD

On peut vérifier ces changements dans l'**UI Argo CD** : le dashboard offre une **représentation visuelle** de l'état de l'application, incluant le nouveau nombre de replicas. En cliquant sur l'instance de l'application, on observe que le nombre de replicas est **passé de 1 à 3**.

### Le cycle GitOps complet illustré

```
[Partie 1] Dépôt Git avec manifest (deployment.yaml, 1 replica)
        │
[Partie 2] Création de l'Application dans l'UI Argo CD (Source + Destination + Self-Heal)
        │
[Partie 3] Argo CD détecte → provisionne automatiquement le pod (Running)
        │
        ▼
   Modification de Git (replicas 1 → 3) → commit
        │
        ▼
   Argo CD détecte → synchronise → 3 pods (visible dans l'UI)
```

### Liens utiles

- Cours GitOps avec ArgoCD (KodeKloud) : https://learn.kodekloud.com/user/courses/gitops-with-argocd
- Documentation officielle Argo CD : https://argo-cd.readthedocs.io/

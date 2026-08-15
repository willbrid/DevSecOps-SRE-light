# Etiquettes et sélecteurs

Les **étiquettes** (**labels**) et **sélecteurs** (**selectors**) offrent une méthode standard pour **grouper et filtrer** les objets selon divers critères — indispensable pour gérer un cluster contenant des centaines ou milliers d'objets (Pods, Services, ReplicaSets, Deployments).

### L'analogie (pour comprendre)

C'est comme trier des espèces animales par attributs (classe : mammifère/oiseau, statut, couleur…). On peut lister « tous les animaux verts » ou « tous les oiseaux verts ». Ce mécanisme est partout : tags de vidéos YouTube, catégories d'articles de blog, filtres produits sur une boutique en ligne.

### Le principe

- Les **labels** : paires **clé-valeur** attachées à chaque objet (ex. `app: App1`, `function: Front-end`) pour le caractériser.
- Les **selectors** : requêtes qui **récupèrent les objets** répondant à un critère de label.

Exemple de selector filtrant les objets où `app = App1` :

```text
app = App1
```

### Définir des labels dans un Pod

Les labels se définissent sous la section **`metadata`** :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp
  labels:
    app: App1
    function: Front-end
spec:
  containers:
    - name: simple-webapp
      image: simple-webapp
      ports:
        - containerPort: 8080
```

Filtrer les Pods avec un selector :


```bash
kubectl get pods --selector app=App1
```

### Labels et Selectors avec les ReplicaSets

On labellise le **template du Pod**, puis on spécifie un **selector** dans le ReplicaSet pour grouper les Pods voulus. Le selector du ReplicaSet doit **correspondre exactement** aux labels des Pods.

> **Point crucial** : seuls les labels du **template du Pod** sont utilisés pour la sélection ; les labels du **ReplicaSet lui-même** (dans son `metadata` de premier niveau) **ne sont PAS pris en compte**.

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: simple-webapp
  labels:
    app: App1
    function: Front-end
spec:
  replicas: 3
  selector:
    matchLabels:
      app: App1
  template:
    metadata:
      labels:
        app: App1
        function: Front-end
    spec:
      containers:
      - name: simple-webapp
        image: simple-webapp
```

> **Bonne pratique** : un **seul label** correspondant suffit techniquement, mais si d'autres Pods risquent de partager un label commun, **ajoutez des labels supplémentaires** dans le selector pour garantir que seuls les Pods voulus sont sélectionnés.

Ce principe s'applique aussi aux **Services** : le selector défini dans la spec du Service cible les labels des Pods (ou ReplicaSets) concernés.

### Les Annotations (à distinguer des labels)

Contrairement aux labels/selectors (groupement et filtrage), les **annotations** attachent des **métadonnées non identifiantes**, à but **informatif** : version de build, coordonnées de contact, données d'intégration d'outils, etc.

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: simple-webapp
  labels:
    app: App1
    function: Front-end
  annotations:
    buildversion: "1.34"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: App1
  template:
    metadata:
      labels:
        app: App1
        function: Front-end
    spec:
      containers:
      - name: simple-webapp
        image: simple-webapp
```

Les annotations **n'affectent pas** la façon dont le système groupe ou sélectionne les objets.

### Labels vs Annotations (comparaison)

| Aspect | Labels | Annotations |
|--------|--------|-------------|
| But | Grouper et filtrer | Informer (métadonnées) |
| Utilisées par les selectors ? | ✅ Oui | ❌ Non |
| Exemples | `app: App1`, `function: Front-end` | `buildversion: "1.34"`, contact |

### À retenir

- **Labels** = paires clé-valeur pour caractériser les objets ; **selectors** = requêtes pour les filtrer.
- Le selector d'un ReplicaSet (`matchLabels`) doit correspondre aux labels du **template du Pod**, pas à ceux du ReplicaSet lui-même.
- Un seul label suffit, mais **plusieurs labels** fiabilisent la sélection en cas de labels partagés.
- Même mécanisme pour les **Services** (le selector cible les Pods).
- **Annotations** ≠ labels : purement informatives, jamais utilisées pour la sélection.

### Liens utiles

- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Documentation officielle Kubernetes : https://kubernetes.io/docs/

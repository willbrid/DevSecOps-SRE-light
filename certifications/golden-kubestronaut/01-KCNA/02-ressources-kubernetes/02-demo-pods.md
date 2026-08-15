# Démo pods

Ce contenu montre comment déployer un pod dans un cluster **Minikube** à l'aide de l'outil `kubectl`. Un pod est la **plus petite unité déployable** de Kubernetes, conçue pour contenir un ou plusieurs conteneurs applicatifs.

> On peut spécifier un **tag d'image** ou utiliser un **registre de conteneurs alternatif** si l'image souhaitée est hébergée ailleurs.

### Opérations sur les Pods

#### 1. Créer un pod

Créer un pod nommé « nginx » à partir de l'image Docker « nginx » (récupérée depuis Docker Hub) :

```bash
kubectl run nginx --image=nginx
```

Résultat : `pod/nginx created`.

#### 2. Vérifier le statut

```bash
kubectl get pods
```

```
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          3s
```

Signification des colonnes :
- **READY** : nombre de conteneurs en état prêt (ex. `1/1`).
- **STATUS** : état du pod (`Running`).
- **RESTARTS** : nombre de redémarrages du conteneur.
- **AGE** : durée d'activité du pod.

#### 3. Inspecter les détails d'un pod

```bash
kubectl describe pod nginx
```

Cette commande fournit des métadonnées et détails essentiels :
- **Nom, Namespace** (ex. `default`), **Labels** (ex. `run=nginx`).
- **Node** : nœud d'exécution (ex. `minikube/192.168.99.100`).
- **IP interne** du pod (ex. `172.17.0.3`).
- **Containers** : détails de chaque conteneur (Container ID, Image, Image ID). Si plusieurs conteneurs tournent dans le pod, chacun est listé ici.
- **Events** : suivi du cycle de vie du pod, très utile pour le débogage :
  - `Scheduled` → assignation au nœud (par le scheduler) ;
  - `Pulling` / `Pulled` → téléchargement de l'image (par le kubelet) ;
  - `Created` → création du conteneur ;
  - `Started` → démarrage du conteneur.

#### 4. Affichage au format large (wide)

Pour un résumé incluant le nœud et l'IP interne :

```bash
kubectl get pods -o wide
```

```
NAME    READY   STATUS    RESTARTS   AGE     IP           NODE       NOMINATED NODE
nginx   1/1     Running   0          2m28s   172.17.0.3   minikube   <none>
```

Chaque pod reçoit sa **propre adresse IP interne** (ex. `172.17.0.3`), qui permet les communications réseau au sein du cluster.

### À retenir

- Enchaînement des commandes clés : `kubectl run` (créer) → `kubectl get pods` (vérifier) → `kubectl describe pod` (inspecter) → `kubectl get pods -o wide` (vue détaillée).
- La section **Events** de `describe` est un outil précieux pour comprendre et déboguer le cycle de vie d'un pod.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/

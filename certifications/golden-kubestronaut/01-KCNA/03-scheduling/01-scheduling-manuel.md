# Scheduling manuel

Ce contenu explique comment **assigner manuellement des pods à des nœuds** sans recourir au **scheduler** intégré de Kubernetes, utile quand on a besoin d'un **contrôle accru** sur le placement des pods.

### Comprendre le scheduling des pods

- Le manifeste d'un pod contient un champ **`nodeName`**, **non défini par défaut**.
- Quand ce champ est vide, le **scheduler de Kubernetes** :
  1. détecte les pods sans `nodeName` ;
  2. détermine le nœud approprié selon son **algorithme de scheduling** ;
  3. crée un **objet Binding** pour assigner le pod à ce nœud.

> **Sans scheduler actif**, les pods restent bloqués à l'état **`Pending`** :

```bash
kubectl get pods
# NAME    READY   STATUS    RESTARTS   AGE
# nginx   0/1     Pending   0          3s
```

### Deux méthodes de scheduling manuel

#### Méthode 1 : Définir `nodeName` à la création (la plus simple)

Il suffit de renseigner explicitement le champ `nodeName` dans la spec du pod. Kubernetes l'assigne **immédiatement** au nœud désigné :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    name: nginx
spec:
  containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 8080
  nodeName: node02
```

> **Limite** : `nodeName` ne peut être défini qu'**à la création** du pod ; il ne peut pas être modifié sur un pod existant.

#### Méthode 2 : Utiliser un objet Binding (pour un pod existant)

Si le pod existe déjà et que son `nodeName` ne peut être modifié, il faut **simuler le comportement du scheduler** via un objet **Binding**, en deux étapes :

**a) Définir l'objet Binding** ciblant le nœud :

```yaml
apiVersion: v1
kind: Binding
metadata:
  name: nginx
target:
  apiVersion: v1
  kind: Node
  name: node02
```

**b) Envoyer le Binding via une requête POST** : convertir le YAML en **JSON** et l'envoyer à l'API de binding du pod avec `curl` :

```bash
curl --header "Content-Type: application/json" \
     --request POST \
     --data '{"apiVersion":"v1", "kind": "Binding", "metadata": {"name": "nginx"}, "target": {"apiVersion": "v1", "kind": "Node", "name": "node02"}}' \
     http://$SERVER/api/v1/namespaces/default/pods/$PODNAME/binding/
```

> Remplacer `$SERVER` et `$PODNAME` par l'adresse réelle du serveur et le nom du pod.

> NB : Le binding manuel ne fonctionne que sur un pod en attente d'assignation (état Pending, nodeName vide).

### À retenir

- Le champ **`nodeName`** contrôle l'assignation d'un pod à un nœud ; vide, il laisse le scheduler décider.
- Sans scheduler (ou sans assignation manuelle), les pods restent en état **`Pending`**.
- **Deux méthodes manuelles** :
  - **À la création** → définir `nodeName` dans le manifeste (simple et direct).
  - **Pour un pod existant** → créer un objet **Binding** et l'envoyer par **requête POST** (en JSON) à l'API, car `nodeName` n'est pas modifiable après coup.
- Le scheduler crée normalement lui-même un **objet Binding** ; le scheduling manuel reproduit ce mécanisme.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/

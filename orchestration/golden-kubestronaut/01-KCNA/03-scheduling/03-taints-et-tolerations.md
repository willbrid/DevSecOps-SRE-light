# Taints et tolerations

Les **taints** et **tolerations** permettent de **contrôler le placement des pods** sur les nœuds : ils **restreignent** quels pods peuvent être planifiés sur quels nœuds.

### L'analogie (pour comprendre)

Imaginez un insecte (bug) qui s'approche d'une personne aspergée de répulsif :
- Le **répulsif** = le **taint** appliqué sur un **nœud**.
- L'**insecte** = le **pod** qui décide de se poser ou non.
- La **résistance de l'insecte** au répulsif = la **toleration**.

→ Les pods **sans toleration** appropriée sont **repoussés** par les taints ; ceux avec une toleration correspondante peuvent être planifiés sur le nœud « tainté ».

### Traduction en Kubernetes (point essentiel)

- Les **nœuds** = la « personne » que l'on taint.
- Les **pods** = les « insectes » planifiés selon leurs tolerations.
- Les **taints** (sur les nœuds) **repoussent** les pods sans toleration correspondante.
- Les **tolerations** (dans les pods) permettent de **surmonter** le taint.

> **Important** : taints et tolerations servent **uniquement aux restrictions de scheduling**, **pas à la sécurité** du cluster.

### Scénario d'exemple

3 nœuds (1, 2, 3) et 4 pods (A, B, C, D). On applique un taint « blue » sur le nœud 1 pour le dédier à une application. On ajoute une toleration au seul pod D :
- Pods A, B, C → **repoussés** vers les nœuds 2 et 3 (pas de toleration) ;
- Pod D → **planifié** sur le nœud 1 (toleration correspondante).

### Appliquer un taint sur un nœud (commande)

Syntaxe générale :

- Ajouter une tainte sur un noeud

```bash
kubectl taint nodes node-name key=value:taint-effect
```

- Enlever une tainte sur un noeud

```bash
kubectl taint nodes node-name key=value:taint-effect-
```

Donc on ajouter le symbole `-` qui permet d'enlever la tainte sur le noeud.

Exemple :

```bash
kubectl taint nodes node1 app=blue:NoSchedule
```

### Les 3 effets de taint (point essentiel)

| Effet | Comportement |
|-------|-------------|
| **NoSchedule** | Les pods sans toleration **ne sont pas planifiés** sur le nœud. |
| **PreferNoSchedule** | Le scheduler **évite** de placer des pods sur le nœud, mais sans garantie stricte. |
| **NoExecute** | Les nouveaux pods sans toleration ne sont pas planifiés, **et** les pods existants sans toleration sont **expulsés (evicted)**. |

### Configurer une toleration dans un Pod

La toleration se définit dans la spec du pod :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  containers:
    - name: nginx-container
      image: nginx
  tolerations:
    - key: "app"
      operator: "Equal"
      value: "blue"
      effect: "NoSchedule"
```

> Toutes les valeurs (`key`, `value`, `effect`, `operator`) sont entre **guillemets**. Elles doivent **correspondre exactement** au taint du nœud.

### Cas particulier : l'effet NoExecute

Sur un nœud 1 « tainté » en **NoExecute**, où seul le pod D tolère le taint :
- tout pod déjà présent **sans** la toleration requise (ex. pod C) sera **expulsé** ;
- seul le pod D reste sur le nœud 1.

### Considérations importantes (point crucial)

> Taints et tolerations contrôlent **quels nœuds peuvent accepter** un pod, mais **ne forcent PAS** un pod à s'exécuter sur un nœud précis. Un pod avec la bonne toleration **peut quand même être placé ailleurs** si le scheduler ne choisit pas ce nœud.

→ Pour **cibler** un nœud spécifique, utiliser la **node affinity**.

#### Le taint par défaut des nœuds master

Les nœuds **master** peuvent exécuter des pods, mais sont **taintés par défaut** pour empêcher les charges de travail non liées à la gestion d'y être planifiées. Pour voir ce taint :

```bash
kubectl describe node <master-node-name>
```

### À retenir

- **Taint** (sur le nœud) = repousse ; **toleration** (dans le pod) = permet d'y résister.
- Taints/tolerations = **scheduling uniquement**, pas de sécurité.
- 3 effets : **NoSchedule**, **PreferNoSchedule**, **NoExecute** (ce dernier expulse aussi les pods existants).
- Ils **restreignent** mais ne **forcent pas** le placement → pour cibler un nœud, utiliser la **node affinity**.
- Les nœuds **master** sont taintés par défaut.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Docker Hub : https://hub.docker.com/

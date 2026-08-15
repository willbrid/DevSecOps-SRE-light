# Sélecteurs de nœuds

Les **node selectors** permettent de **restreindre le placement des pods** sur des nœuds spécifiques en fonction de leurs **labels**. Utile, par exemple, quand un cluster contient des nœuds de tailles différentes et qu'on veut faire tourner les tâches gourmandes en ressources sur le nœud le plus puissant.

### Le problème résolu

Par défaut, Kubernetes planifie les pods sur **n'importe quel nœud disponible**, ce qui pourrait assigner un pod exigeant à un petit nœud. Le node selector **garantit** que le pod atterrit sur un nœud répondant au critère de label requis.

### Utiliser un nodeSelector dans un Pod

On ajoute le champ **`nodeSelector`** à la spec du pod :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  containers:
  - name: data-processor
    image: data-processor
  nodeSelector:
    size: Large
```

Ici, le pod ne sera planifié **que** sur les nœuds portant le label `size: Large`.

### Labels et node selectors

La paire clé-valeur du `nodeSelector` (`size: Large`) doit **correspondre exactement** aux labels des nœuds. Il est donc **essentiel de labelliser les nœuds au préalable**, avant de déployer un pod utilisant un node selector.

### Labelliser un nœud (commande essentielle)

Syntaxe générale :

- Ajouter un label sur un noeud

```bash
kubectl label nodes <node-name> <label-key>=<label-value>
```

- Enlever un label sur un noeud

```bash
kubectl label nodes <node-name> <label-key>-
```

Donc on ajouter le symbole `-` qui permet d'enlever le label sur le noeud. Pas besoin de mentionner la valeur du label avant le symbole.

Exemple :

```bash
kubectl label nodes node-1 size=Large
```

Cela applique le label `size=Large` sur `node-1`.

### Déployer le Pod

Une fois le nœud labellisé et le `nodeSelector` défini :

```bash
kubectl create -f pod-definition.yml
```

Le pod `myapp-pod` sera planifié sur `node-1` grâce au label correspondant.

> Garder les labels des nœuds **à jour** au fur et à mesure de l'évolution du cluster, pour un scheduling cohérent et prévisible.

### Limites des node selectors

Les node selectors sont **simples et efficaces**, mais **limités à une correspondance de label unique**. Ils ne suffisent **pas** pour des scénarios complexes, par exemple :
- planifier sur un nœud « Large » **OU** « Medium » ;
- **exclure** les nœuds labellisés « Small ».

→ Pour ces cas avancés (logique OU, NON, opérateurs), utiliser la **node affinity / anti-affinity**.

### À retenir

- Le **`nodeSelector`** (dans la spec du pod) restreint le pod aux nœuds portant un **label** donné.
- La paire clé-valeur doit **correspondre exactement** au label du nœud.
- **Étapes** : labelliser le nœud (`kubectl label nodes`) → définir le `nodeSelector` → déployer le pod.
- **Limite** : une seule correspondance de label, pas de logique complexe (OU, exclusion) → passer à la **node affinity** pour ces besoins.
- Différence avec taints/tolerations : le node selector **attire** un pod vers un nœud précis, tandis que taints/tolerations **repoussent** les pods indésirables.

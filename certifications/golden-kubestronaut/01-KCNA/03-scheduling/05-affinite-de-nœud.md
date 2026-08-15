# Affinité de nœud

La **node affinity** permet de contrôler le placement des pods en spécifiant des **règles avancées** sur les nœuds éligibles. Là où les node selectors offrent un contrôle basique (une seule correspondance de label), la node affinity apporte des **opérateurs et expressions flexibles**.

### Utiliser la Node Affinity (point essentiel)

Même concept sous-jacent (labels), mais avec des expressions plus riches. Le bloc `affinity` se place sous la `spec` du pod :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  containers:
    - name: data-processor
      image: data-processor
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: size
                operator: In
                values:
                  - Large
```

Décomposition :
- **`affinity`** : bloc défini sous la `spec` du pod ;
- **`nodeAffinity`** : critères de scheduling sur les nœuds ;
- **`requiredDuringSchedulingIgnoredDuringExecution`** : exigence **obligatoire** ; si aucun nœud ne correspond, le pod **n'est pas planifié** ;
- **`nodeSelectorTerms`** → **`matchExpressions`** : tableau de conditions (clé, opérateur, valeurs).

### Les opérateurs (point essentiel)

| Opérateur | Rôle | Exemple |
|-----------|------|---------|
| **In** | La valeur du label doit être **dans** la liste | `size In [Large, Medium]` |
| **NotIn** | La valeur du label ne doit **pas** être dans la liste (exclusion) | `size NotIn [Small]` |
| **Exists** | Le label doit simplement **être présent** (sans comparer de valeur) | `size Exists` |

Exemples :

```yaml
# Large OU Medium
operator: In
values: [Large, Medium]
```

```yaml
# Exclure Small
operator: NotIn
values: [Small]
```

```yaml
# Tout nœud possédant le label "size"
operator: Exists
```

### Les types de node affinity (point crucial)

| Type | Comportement |
|------|-------------|
| **requiredDuringSchedulingIgnoredDuringExecution** | Le scheduler **impose** un nœud satisfaisant les règles. Si aucun ne correspond, le pod **reste non planifié**. Les changements de labels après exécution sont **ignorés**. |
| **preferredDuringSchedulingIgnoredDuringExecution** | Le scheduler **tente** de respecter les règles ; si aucun nœud ne correspond, le pod peut être placé **ailleurs**. Changements de labels ignorés après exécution. |
| **requiredDuringSchedulingRequiredDuringExecution** | Le scheduler **impose** un nœud satisfaisant les règles. Si aucun ne correspond, le pod **reste non planifié**. Les changements de labels après exécution ne sont pas **ignorés** et les pods sont évincés si les règles ne sont pas respectées. |

### Scheduling vs Execution (à bien comprendre)

Les règles s'appliquent en deux phases :
1. **Pendant le scheduling** (création) : le scheduler évalue les règles pour choisir un nœud. En mode `required`, si aucun nœud ne correspond (label manquant), le pod n'est pas planifié.
2. **Pendant l'exécution** : avec les types actuels (**IgnoredDuringExecution**), les changements de labels sont **ignorés** une fois le pod lancé.

**Scénario clé** : un pod est planifié sur un nœud `size=Large`. Si un admin **retire ce label plus tard**, le pod **continue de tourner** (comportement actuel). Avec les futurs types « RequiredDuringExecution », le pod pourrait être **expulsé**.

### Décoder les noms de types

Les noms se lisent en deux parties : `<Required/Preferred>DuringScheduling` + `<Required/Ignored>DuringExecution` :
- **DuringScheduling** : Required (obligatoire) ou Preferred (souhaité) → au moment de la planification.
- **DuringExecution** : Ignored (on ignore les changements) ou Required (on expulse si non-conforme, futur).

### À retenir

- La node affinity = version **avancée** du node selector, avec opérateurs **In / NotIn / Exists**.
- Structure : `affinity` → `nodeAffinity` → `requiredDuring...` → `nodeSelectorTerms` → `matchExpressions` (key, operator, values).
- **required** = obligatoire (pod non planifié sinon) ; **preferred** = souhaité (placé ailleurs si besoin).
- **IgnoredDuringExecution** (actuel) : les changements de labels après lancement n'affectent pas le pod.
- Complémentaire des **taints/tolerations** : la node affinity **attire** les pods vers des nœuds, les taints **repoussent** les pods des nœuds.

### Liens utiles

- Assignation de pods aux nœuds (opérateurs) : https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
- Documentation officielle Kubernetes : https://kubernetes.io/docs/

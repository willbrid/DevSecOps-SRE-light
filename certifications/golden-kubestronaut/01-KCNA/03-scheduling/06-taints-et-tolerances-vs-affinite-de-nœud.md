# Taints et tolérances vs Affinité de nœud

Ce contenu montre comment **combiner** **taints/tolerations** et **node affinity** pour **dédier des nœuds à des pods spécifiques** dans un cluster partagé entre plusieurs équipes.

### Le scénario

3 nœuds et 3 pods identifiés par couleur : **bleu, rouge, vert**. Objectif : planifier chaque pod sur le nœud de sa couleur (pod bleu → nœud bleu, etc.). Le cluster étant **partagé entre plusieurs équipes**, il faut garantir que :
- **aucun pod d'une autre équipe** n'atterrisse sur nos nœuds dédiés ;
- **nos pods** ne soient pas déployés sur les nœuds d'autres équipes.

### Approche 1 : Taints et Tolerations (et sa limite)

1. **Tainter chaque nœud** avec sa couleur → repousse les pods sans toleration correspondante.
2. **Ajouter la toleration** correspondante à chaque pod → seuls les pods tolérants sont planifiés sur le nœud taint.

> **Limite** : les taints/tolerations **autorisent** un pod à aller sur un nœud taint, mais ne le **forcent pas** à y aller. Un pod (ex. le pod rouge) pourrait donc être planifié sur **un autre nœud sans taint** si les critères de scheduling le permettent.

→ **Taints/tolerations = repoussent les indésirables, mais ne garantissent pas le bon placement.**

### Approche 2 : Node Affinity (et sa limite)

1. **Labelliser chaque nœud** avec sa couleur.
2. **Définir un node selector / node affinity** sur chaque pod correspondant au label du nœud → **force** les pods à atterrir sur les bons nœuds.

> **Limite** : la node affinity **attire** nos pods vers les bons nœuds, mais **n'empêche pas** les pods d'autres équipes d'y être planifiés.

→ **Node affinity = garantit le bon placement de nos pods, mais ne bloque pas les intrus.**

### La solution : Combiner les deux (point essentiel)

Pour une **dédicace complète** des nœuds :
1. **Empêcher les pods externes** → **taints** sur les nœuds + **tolerations** sur nos pods (bloque les intrus).
2. **Forcer le bon placement** → **node affinity** pour que nos pods aillent strictement sur les nœuds au bon label.

Ainsi, les nœuds sont **exclusivement dédiés** aux bons pods, **sans interférence externe**.

### Tableau récapitulatif

| Mécanisme | Ce qu'il fait | Ce qu'il ne fait pas |
|-----------|---------------|----------------------|
| **Taints / Tolerations** | Repousse les pods indésirables des nœuds | Ne force pas nos pods sur les bons nœuds |
| **Node Affinity** | Attire/force nos pods vers les bons nœuds | Ne bloque pas les pods d'autres équipes |
| **Combinaison des deux** | ✅ Nœuds exclusivement dédiés, sans intrusion | — |

### À retenir

- **Taints/tolerations** et **node affinity** sont **complémentaires** : l'un repousse, l'autre attire.
- Seuls, chacun a une **faille** : les taints laissent nos pods partir ailleurs ; l'affinity laisse les intrus entrer.
- **Combinés**, ils garantissent une **dédicace stricte** des nœuds (idéal en cluster multi-équipes).
- Moyen mnémotechnique : **Taints = videur** (empêche les indésirables d'entrer) ; **Affinity = GPS** (dirige nos pods au bon endroit).

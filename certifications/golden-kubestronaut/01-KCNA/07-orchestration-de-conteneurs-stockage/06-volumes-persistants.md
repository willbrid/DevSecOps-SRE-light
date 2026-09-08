# Volumes persistants

Ce contenu porte sur les **persistent volumes (PV)** dans Kubernetes et sur la façon dont ils **centralisent la gestion du stockage** pour un environnement **scalable et prêt pour la production**.

### Configuration de volume traditionnelle (le problème)

Auparavant, les détails de stockage étaient **intégrés directement** dans le fichier de spécification du pod :

```yaml
volumes:
- name: data-volume
  awsElasticBlockStore:
    volumeID: <volume-id>
    fsType: ext4
```

**Limites (point essentiel)** : cette approche fonctionne pour des déploiements simples, mais devient **lourde** dans les environnements **larges et multi-utilisateurs** :
- Chaque pod nécessite sa **propre configuration de stockage** ;
- Les **mises à jour globales** sont **difficiles et sujettes aux erreurs**.

### Stockage centralisé avec volumes persistants (la solution)

Les **volumes persistants** résolvent ce problème en **séparant la configuration du stockage** des définitions de pods :
- Les **administrateurs du cluster** créent un **pool de ressources de stockage** (les PV) ;
- Les **utilisateurs réclament** du stockage via des **Persistent Volume Claims (PVC)**.

Ce modèle **simplifie la gestion** et **réduit la redondance**.

En résumé :
- Les **administrateurs** gèrent le stockage de manière **centralisée** ;
- Les **utilisateurs** réclament du stockage **au besoin**, sans configuration répétitive ;
- Les **changements et mises à jour globales** deviennent plus faciles à mettre en œuvre.

### La relation PV ↔ PVC (concept clé)

| Objet | Créé par | Rôle |
|-------|----------|------|
| **PersistentVolume (PV)** | L'**administrateur** | Ressource de stockage disponible dans le pool |
| **PersistentVolumeClaim (PVC)** | L'**utilisateur** | Demande (réclamation) de stockage puisée dans le pool de PV |

### Créer un PV

Pour créer un PV via un template YAML, on définit dans la section `spec` :
- **Access Modes** : détermine **comment** le volume peut être monté :
  - **ReadOnlyMany** (lecture seule par plusieurs) ;
  - **ReadWriteOnce** (lecture-écriture par un seul) ;
  - **ReadWriteMany** (lecture-écriture par plusieurs) ;
- **Capacity** : taille de stockage allouée (ici `1Gi`) ;
- **Volume Type** : ici un **hostPath** (stockage local du nœud).

> **Point important** : le `hostPath` est utile pour la **démonstration**, mais **déconseillé en production** → toujours opter pour une solution de stockage **prête pour la production**.

Exemple de définition :
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-voll
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 1Gi
  hostPath:
    path: /tmp/data
```

### Déploiement du volume persistant (déployer et vérifier)

Créer le PV :
```bash
kubectl create -f pv-definition.yaml
```

Vérifier sa création :
```bash
kubectl get persistentvolume
```

Cette commande liste tous les persistent volumes disponibles, y compris celui qui vient d'être créé.

Les persistent volumes permettent une **gestion centralisée du stockage** qui rationalise les déploiements et simplifie la maintenance. En **externalisant** la configuration du stockage via les **PVC**, on assure une utilisation efficace des ressources et une **scalabilité** facilitée.

### À retenir

- **Problème** : intégrer le stockage dans chaque pod devient ingérable à grande échelle (config répétée, mises à jour difficiles).
- **Solution** : les **Persistent Volumes (PV)** séparent la config du stockage des pods → l'**admin** crée un **pool de PV**, l'**utilisateur** réclame via un **PVC**.
- Un PV se définit avec `kind: PersistentVolume` et une `spec` comprenant : **accessModes** (ReadOnlyMany, ReadWriteOnce, ReadWriteMany), **capacity** (ex. `1Gi`) et un **type de volume** (ici `hostPath`).
- **`hostPath`** = pour la démo uniquement ; en production, utiliser une solution externe/cloud.
- Commandes : **`kubectl create -f pv-definition.yaml`** puis **`kubectl get persistentvolume`**.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/

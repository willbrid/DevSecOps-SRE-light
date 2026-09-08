# Demandes de volumes persistants

Ce contenu explique la création et la gestion des **Persistent Volume Claims (PVC)**, leur relation avec les **Persistent Volumes (PV)**, et l'impact des **reclaim policies**.

**Répartition des rôles** :
- Les **administrateurs** créent les **PV** ;
- Les **utilisateurs** créent les **PVC** pour **demander et utiliser** ce stockage.

**Le processus de binding** :
- Une fois un PVC défini, Kubernetes le **lie automatiquement (bind)** à un PV disponible qui répond à certains critères : **capacité, access modes, volume modes, storage class**, et autres paramètres ;
- **Chaque PVC est lié exclusivement à UN SEUL PV** (relation 1-à-1) ;
- Si **aucun PV compatible** n'existe à la création, le PVC reste à l'état **`Pending`** jusqu'à ce qu'un PV compatible devienne disponible.

> **Points importants** :
- Si **plusieurs PV** correspondent aux critères, on peut utiliser des **labels et selectors** pour garantir le bon volume ;
- Même si le PVC demande **moins** que la capacité du PV (ex. 500Mi sur 1Gi), la **capacité excédentaire n'est PAS allouée** à d'autres claims (elle est « perdue »).

### Créer un PVC

Exemple de PVC nommé `myclaim`, demandant **500Mi** en mode **ReadWriteOnce** (`pvc-definition.yaml`) :
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

Déployer :
```bash
kubectl create -f pvc-definition.yaml
```

Vérifier le statut :
```bash
kubectl get persistentvolumeclaim
```

Sortie initiale (avant binding) :
```
NAME      STATUS    VOLUME   CAPACITY   ACCESS MODES
myclaim   Pending
```

> Même si un PVC demande une **portion** du stockage d'un PV (ex. 500Mi sur 1Gi), Kubernetes le **lie** à ce PV si l'**access mode** et les autres conditions correspondent.

Exemple de PV pouvant satisfaire ce PVC :
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-vol
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 1Gi
  awsElasticBlockStore:
    volumeID: <volume-id>
    fsType: ext4
```

Si **aucun PV compatible** n'existe à la création, le PVC reste en **`Pending`** jusqu'à provisionnement d'un PV adapté.

### Supprimer un PVC et les Reclaim Policies

Supprimer un PVC :
```bash
kubectl delete persistentvolumeclaim myclaim
# persistentvolumeclaim "myclaim" deleted
```

**Point crucial** : par défaut, supprimer un PVC **ne supprime PAS automatiquement** le PV associé. Le comportement du PV est déterminé par sa **reclaim policy**.

Les **trois reclaim policies** :

| Reclaim Policy | Description | YAML |
|----------------|-------------|------|
| **Retain** | Le PV est **conservé** même après suppression du PVC. **Nettoyage manuel** par un admin requis. | `persistentVolumeReclaimPolicy: Retain` |
| **Delete** | Le PV est **automatiquement supprimé** quand le PVC est retiré, libérant le stockage sous-jacent. | `persistentVolumeReclaimPolicy: Delete` |
| **Recycle** | Le PV est **nettoyé (scrubbed)** de ses données et rendu **disponible pour réutilisation** par d'autres PVC. | `persistentVolumeReclaimPolicy: Recycle` |

Choisir la bonne **reclaim policy** est essentiel pour gérer le **cycle de vie du stockage** : décider si la ressource doit **persister** après la suppression du PVC ou être **supprimée automatiquement**.

### À retenir

- **Répartition** : l'**admin** crée les **PV**, l'**utilisateur** crée les **PVC** pour réclamer du stockage.
- **Binding** : Kubernetes lie automatiquement un PVC à un PV compatible (capacité, access modes, volume modes, storage class) ; relation **1-à-1**.
- Un PVC sans PV compatible reste en **`Pending`** ; la capacité excédentaire d'un PV lié n'est **pas récupérable** par d'autres claims.
- Utiliser **labels et selectors** pour cibler un PV précis quand plusieurs correspondent.
- Un PVC se définit avec `kind: PersistentVolumeClaim`, `accessModes` et `resources.requests.storage`.
- **Reclaim policies** (comportement du PV à la suppression du PVC) : **Retain** (conservé, nettoyage manuel), **Delete** (supprimé auto), **Recycle** (nettoyé et réutilisable).

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/

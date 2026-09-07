# Volumes

Les conteneurs Docker sont **transitoires (transient)** : conçus pour s'exécuter temporairement, traiter des données, puis être détruits. **Par défaut, toute donnée générée dans un conteneur est perdue** à son arrêt. Pour y remédier, Docker permet d'**attacher un volume** à la création du conteneur, garantissant la **persistance des données** même après sa terminaison.

**Le parallèle avec Kubernetes** : les pods Kubernetes sont également **éphémères**. Quand un pod traite des données puis est supprimé, ses données sont **perdues** sauf si un **volume est attaché**. Les volumes garantissent que les données essentielles restent disponibles après la fin de vie du pod.

### Exemple simple de volume dans Kubernetes (hostPath)

**Scénario** : sur un cluster mono-nœud, un pod génère un nombre aléatoire entre 0 et 100 et l'écrit dans `/opt/number.out`. Sans volume, ce fichier serait perdu à la suppression du pod. On crée donc un volume pour **conserver** le nombre généré.

Ici, on utilise un **répertoire de l'hôte** comme support de stockage : le volume utilise le répertoire **`/data`** du nœud, monté vers **`/opt`** dans le conteneur.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: random-number-generator
spec:
  containers:
  - image: alpine
    name: alpine
    command: ["/bin/sh", "-c"]
    args: ["shuf -i 0-100 -n 1 >> /opt/number.out;"]
    volumeMounts:
    - mountPath: /opt
      name: data-volume
  volumes:
  - name: data-volume
    hostPath:
      path: /data
      type: Directory
```

**Décomposition (point essentiel)** :
- Le conteneur exécute une image **Alpine** qui lance la commande `shuf` pour générer un nombre aléatoire, ajouté à `/opt/number.out` ;
- **`volumeMounts`** : monte le `data-volume` à **`/opt`** dans le conteneur (où le fichier est écrit) ;
- **`volumes`** : définit le `data-volume` via le répertoire **`/data`** de l'hôte (`hostPath`).

> Même si le pod est supprimé, le fichier contenant le nombre aléatoire **reste stocké sur l'hôte** → les données sont préservées.

### Considérations pour les clusters multi-nœuds

Le volume **`hostPath`** fonctionne bien en environnement **mono-nœud**, mais **n'est PAS recommandé** pour les clusters **multi-nœuds** :
- Les pods planifiés sur **différents nœuds** référenceraient chacun leur **propre répertoire `/data` local** → **incohérence des données (data inconsistency)**.
- Pour un stockage **cohérent et partagé** entre nœuds, il faut utiliser une **solution de stockage externe et répliquée**.

> Utiliser `hostPath` en multi-nœuds mène à l'incohérence des données. Toujours privilégier une **solution de stockage externe** pour les environnements nécessitant un stockage partagé.

### Les options de stockage supportées

Kubernetes supporte de nombreuses options :
- **Solutions externes** : NFS (Network File System), GlusterFS, Flocker, Fibre Channel, CephFS, ScaleIO, OpenEBS ;
- **Stockage cloud public** : AWS EBS, Azure Disk/File storage, Google Persistent Disk.

#### Exemple avec AWS EBS

Pour utiliser un volume **AWS Elastic Block Store** au lieu de `hostPath` :
```yaml
volumes:
  - name: data-volume
    awsElasticBlockStore:
      volumeID: <volume-id>
      fsType: ext4
```

On spécifie le champ **`awsElasticBlockStore`** avec l'**ID du volume** et le **type de système de fichiers** (`ext4`). Cela permet à Kubernetes de gérer le stockage sur **AWS EBS**, une solution externe **scalable et fiable**.

### À retenir

- Les pods sont **éphémères** : sans volume, les données sont **perdues** à la suppression → le **volume** assure la **persistance** (même principe que Docker).
- Un volume se définit dans `spec.volumes` et se monte dans le conteneur via **`volumeMounts`** (`mountPath` + `name`).
- **`hostPath`** utilise un répertoire du **nœud** → OK en **mono-nœud**, mais **déconseillé en multi-nœuds** (incohérence des données entre nœuds).
- Pour du stockage **partagé et cohérent** en multi-nœuds : solutions **externes/répliquées** (NFS, GlusterFS, CephFS…) ou **cloud** (AWS EBS, Azure Disk, Google Persistent Disk).
- Exemple cloud : champ **`awsElasticBlockStore`** avec `volumeID` et `fsType`.

### Liens utiles

- Documentation officielle Kubernetes (options de stockage) : https://kubernetes.io/docs/

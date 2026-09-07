# Classe de stockage

Ce contenu explore les **classes de stockage** dans Kubernetes, en s'appuyant sur les concepts de **PV**, **PVC** et leur utilisation dans les pods. Comprendre le **provisioning statique** et **dynamique** est essentiel pour une gestion efficace du stockage.

> Les classes de stockage **simplifient la gestion du stockage** en **automatisant le provisioning**. Les concepts restent similaires entre statique et dynamique, mais le **provisioning dynamique** offre la **création automatique de PV**.

### Static Provisioning (provisioning statique) — le problème

Le provisioning statique exige une **configuration manuelle** :
1. Créer d'abord le **disque persistant** sur le cloud provider (ex. Google Cloud) ;
2. Créer **manuellement** la définition du **PV** en utilisant **exactement le même nom de disque**.

→ Chaque application nécessitant du stockage impose de **pré-provisionner le disque** et de créer la config PV correspondante.

Créer d'abord le disque sous-jacent (ex. sur GCP) :
```bash
gcloud beta compute disks create \
  --size 1GB \
  --region us-east1 \
  pd-disk
```

Les 3 fichiers (PV, PVC, Pod) en provisioning statique :
```yaml
# pv-definition.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-vol1
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 500Mi
  gcePersistentDisk:
    pdName: pd-disk
    fsType: ext4
```

```yaml
# pvc-definition.yaml
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
```yaml
# pod-definition.yaml
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
      persistentVolumeClaim:
        claimName: myclaim
```

> Le pod référence le PVC via `persistentVolumeClaim.claimName`.

### Dynamic Provisioning with classes de stockage (la solution)

Le provisioning dynamique **automatise** la création du stockage. Au lieu de créer les PV manuellement, on utilise une **storage class** qui définit un **provisioner** (ex. le provisioner de disque persistant de Google Cloud) pour **créer et attacher automatiquement** un disque à la demande.

**Workflow du provisioning dynamique** :
1. Créer un objet **StorageClass** (API `storage.k8s.io/v1`) en spécifiant le **provisioner** (ex. `kubernetes.io/gce-pd`) et d'éventuels paramètres ;
2. Dans le PVC, **référencer la classe de stockage** via le champ **`storageClassName`** ;
3. À la création du PVC, le provisioner de la classe de stockage **crée dynamiquement un disque**, **génère automatiquement le PV correspondant**, et **lie** le PVC à ce PV.

```yaml
# sc-definition.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: google-storage
provisioner: kubernetes.io/gce-pd
```

```yaml
# pvc-definition.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: google-storage   # référence la storage class
  resources:
    requests:
      storage: 500Mi
```

```yaml
# pod-definition.yaml
apiVersion: v1
kind: Pod
metadata:
  name: random-number-generator
spec:
  containers:
    - image: alpine
      name: alpine
      command: ["/bin/sh", "-c"]
      args: ["shuf -i 0-100 -n 1 >> /opt/data-volume/output.txt"]
      volumeMounts:
        - mountPath: /opt
          name: data-volume
  volumes:
    - name: data-volume
      persistentVolumeClaim:
        claimName: myclaim
```

> **Point clé** : avec le provisioning dynamique, **pas besoin de créer des PV à l'avance** → la classe de stockage s'occupe **automatiquement** de la création du PV quand le PVC est soumis.

### Static vs Dynamic (distinction clé)

| Aspect | Provisioning **statique** | Provisioning **dynamique** |
|--------|---------------------------|----------------------------|
| Création du disque | **Manuelle** (avant) | **Automatique** (par le provisioner) |
| Création du PV | **Manuelle** | **Automatique** |
| Outil | PV créé à la main | **StorageClass** + `storageClassName` |
| Effort | Élevé, répétitif | Faible, automatisé |

### Multiple classes de stockage (plusieurs niveaux de service)

Un avantage clé : définir différents **niveaux de service (service levels)** selon les besoins de performance et de réplication. Exemple :

| Storage Class | Description |
|---------------|-------------|
| **Silver** | Disques persistants **standard** |
| **Gold** | Disques persistants **SSD** |
| **Platinum** | Disques persistants **SSD** avec **réplication régionale** |

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: silver
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
  replication-type: none
```

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gold
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  replication-type: none
```

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: platinum
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  replication-type: regional-pd
```
Il suffit ensuite de **spécifier le nom de la storage class** voulue dans le PVC, et Kubernetes provisionne dynamiquement le volume avec les caractéristiques définies.

### À retenir

- **Provisioning statique** : disque **et** PV créés **manuellement** avant usage → lourd et répétitif.
- **Provisioning dynamique** : une **StorageClass** (avec un **provisioner**) crée **automatiquement** le disque **et** le PV quand un PVC est soumis → pas de PV pré-créés.
- Le PVC référence la storage class via **`storageClassName`**.
- Une StorageClass utilise `apiVersion: storage.k8s.io/v1`, un **`provisioner`** (ex. `kubernetes.io/gce-pd`) et des **`parameters`** (type de disque, réplication).
- **Plusieurs classes de stockage** = plusieurs **niveaux de service** (ex. Silver/standard, Gold/SSD, Platinum/SSD régional).

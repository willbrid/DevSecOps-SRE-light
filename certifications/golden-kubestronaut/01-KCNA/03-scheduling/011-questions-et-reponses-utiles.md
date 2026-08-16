# Questions et réponses utiles

Voici quelques points clés à retenir, organisés par thème.

### Unités de mesure

- **Différence entre Gigaoctet (GB) et Gibioctet (GiB)** : un **Gigaoctet (GB)** correspond à **1000 Mégaoctets**, tandis qu'un **Gibioctet (GiB)** correspond à **1024 Mébioctets**.

### Static Pods vs DaemonSets

- **Distinctions clés entre static pods et DaemonSets** :
  - les **static pods** sont créés par le **kubelet**, tandis que les **DaemonSets** utilisent le **kube-apiserver** ;
  - les deux (static pods et DaemonSets) sont **ignorés par le service de scheduling** (le scheduler) ;
  - les **static pods** servent à déployer les nœuds du **control plane**, tandis que les **DaemonSets** conviennent au déploiement d'agents de **monitoring ou de logging** sur chaque nœud.

### Ressources CPU et mémoire

- **Comment modifier les resource requests d'un pod** : spécifier les nouvelles valeurs dans le fichier de définition du pod ou du deployment, sous la section **`resources`**.

- **Définition d'1 unité de CPU (1 CPU) dans Kubernetes** :
  - elle correspond à **1 hyperthread** ;
  - elle correspond à **1 vCPU** dans AWS ;
  - elle correspond à **1 cœur (core)** dans GCP ou Azure.

- **Valeur minimale pour une resource request CPU** : **1m CPU** (un milli-CPU).

- **Hypothèse par défaut de Kubernetes concernant la resource request d'un conteneur** : **aucune resource request n'est définie** (No resource request is set).

### Node Affinity

- **Ce que définit le type de node affinity** : le **comportement du scheduler** vis-à-vis de la node affinity et des **étapes du cycle de vie du pod** (scheduling et execution).

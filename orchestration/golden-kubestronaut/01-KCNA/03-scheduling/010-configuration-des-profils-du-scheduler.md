# Configuration des profils du planificateur Kubernetes

Ce contenu explore les **profils de scheduler** et le **fonctionnement interne** du scheduler Kubernetes, à travers l'exemple d'un pod planifié sur l'un de quatre nœuds.

### Priorité des Pods (PriorityClass)

Les pods entrent dans une **file d'attente de scheduling**, où ils sont ordonnés selon leur **priorité**. On assigne une priorité via un objet **PriorityClass** :

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "This priority class should be used for XYZ service pods only."
```

Le pod référence ensuite cette classe via **`priorityClassName`** :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp-color
spec:
  priorityClassName: high-priority
  containers:
    - name: simple-webapp-color
      image: simple-webapp-color
      resources:
        requests:
          memory: "1Gi"
          cpu: 10
```

> Une priorité élevée place le pod **en tête** de la file d'attente.

### Les 3 phases du scheduling (point essentiel)

| Phase | Rôle |
|-------|------|
| **1. Filter (filtrage)** | Élimine les nœuds qui ne satisfont **pas** les besoins en ressources (ex. nœuds sans les 10 CPU requis). |
| **2. Scoring (notation)** | Attribue un **score** aux nœuds restants selon des facteurs comme le CPU restant après allocation (ex. un nœud avec 6 CPU libres marque plus qu'un avec 2). |
| **3. Binding (assignation)** | Assigne le pod au nœud ayant le **meilleur score**. |

### Les plugins clés du scheduling

Le scheduler s'appuie sur des **plugins** à chaque étape :

- **Priority Sort Plugin** : ordonne les pods dans la file selon leur priorité (phase file d'attente).
- **Node Resources Fit Plugin** : exclut les nœuds sans ressources suffisantes (filtre) et les réévalue selon les ressources libres (scoring).
- **Node Unschedulable Plugin** : empêche l'assignation de pods sur les nœuds marqués **`unschedulable`** (visible via un taint `node.kubernetes.io/unschedulable:NoSchedule`).
- **Image Locality Plugin** : préférence **douce** (scoring) favorisant les nœuds possédant déjà l'image du conteneur.
- **Default Binder Plugin** : finalise l'assignation pod → nœud (phase binding).

### Points d'extension personnalisables

L'architecture extensible de Kubernetes permet de personnaliser les plugins actifs à chaque **point d'extension** : pre-filter, filter, post-filter, pre-score, score, reserve, pre-bind, post-bind. On peut aussi intégrer des **plugins personnalisés**.

### Les profils multiples (Multiple Scheduling Profiles)

**Introduit dans Kubernetes 1.18**, cette fonctionnalité permet de définir **plusieurs profils de scheduler dans un SEUL binaire** :
- Simplifie la maintenance ;
- **Réduit les race conditions** en évitant d'avoir plusieurs binaires séparés (default-scheduler, my-scheduler, my-scheduler2…).

Chaque profil agit comme un **scheduler indépendant** au sein du même binaire, chacun avec son `schedulerName` :

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: default-scheduler
- schedulerName: my-scheduler
- schedulerName: my-scheduler-2
```

### Personnaliser les plugins par profil

On peut **activer ou désactiver** des plugins par nom (ou motif `*`) à des points d'extension précis :

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: my-scheduler-2
  plugins:
    score:
      disabled:
      - name: TaintToleration
      enabled:
      - name: MyCustomPluginA
      - name: MyCustomPluginB

- schedulerName: my-scheduler-3
  plugins:
    preScore:
      disabled:
      - name: "*"
    score:
      disabled:
      - name: "*"

- schedulerName: my-scheduler-4
```

### Profils multiples vs schedulers multiples (à retenir)

- **Schedulers multiples** (leçon précédente) : plusieurs **binaires/processus** séparés → maintenance lourde, risque de race conditions.
- **Profils multiples** (depuis 1.18) : **un seul binaire** contenant plusieurs profils → approche moderne, plus simple et plus sûre.

### À retenir

- **PriorityClass** + `priorityClassName` déterminent l'ordre des pods dans la file d'attente.
- Le scheduling suit **3 phases** : **Filter → Score → Bind**.
- Des **plugins** interviennent à chaque phase (Priority Sort, Node Resources Fit, Node Unschedulable, Image Locality, Default Binder).
- Depuis **Kubernetes 1.18**, les **profils multiples** remplacent avantageusement les binaires séparés (moins de race conditions).
- On peut **enabled/disabled** des plugins par profil et par point d'extension.

### Liens utiles

- Proposition d'amélioration KEP-1451 (multiple profiles) : https://github.com/kubernetes/enhancements/tree/master/keps/sig-scheduling/1451-kube-scheduler-multiple-profiles

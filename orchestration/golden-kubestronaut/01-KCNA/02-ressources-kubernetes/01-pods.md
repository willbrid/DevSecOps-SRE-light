# Pods

Avant de déployer une application dans Kubernetes, il faut :
1. Une application développée, construite en **images Docker** et publiée dans un dépôt (ex. Docker Hub) pour que Kubernetes puisse la récupérer.
2. Un **cluster Kubernetes opérationnel** (mono-nœud ou multi-nœuds).
3. Tous les **services additionnels** requis par l'application actifs.

### Définition

Un **pod** est la **plus petite unité déployable** dans Kubernetes. Il encapsule **un ou plusieurs conteneurs** et représente **une instance unique** de l'application s'exécutant sur un nœud de travail.

### Le rôle des pods et le scaling

- Pour un usage simple : une instance de l'application dans un conteneur, encapsulée dans un pod sur un cluster mono-nœud.
- **Règle de scaling** : quand la demande augmente, on **ne rajoute PAS de conteneurs dans un pod existant**. On crée de **nouveaux pods**, chacun contenant une instance de l'application.
- Les pods entretiennent **généralement** une **relation un-à-un avec les conteneurs**.
  - **Scale up** : créer de nouveaux pods.
  - **Scale down** : supprimer des pods existants.
- Ces pods peuvent être créés sur le même nœud ou sur des nœuds supplémentaires, assurant une répartition efficace des ressources.

### Les pods multi-conteneurs

Dans certains cas, plusieurs conteneurs cohabitent dans un même pod :
- Un **conteneur helper** (auxiliaire) peut accompagner le conteneur applicatif principal (ex. traitement de données, upload de fichiers).
- Ces conteneurs **démarrent et s'arrêtent ensemble**.
- Ils **partagent le même namespace réseau et les mêmes volumes de stockage**.
- Ils communiquent entre eux via **`localhost`**, car ils partagent le même contexte réseau.

### Avantages des pods vs commandes Docker directes

Avec Docker seul, la gestion manuelle devient rapidement complexe :

```bash
docker run python-app          # lancer plusieurs instances
docker run helper --link app1  # lier manuellement les helpers
```
La gestion manuelle de la connectivité réseau, du stockage partagé et des cycles de vie interconnectés est **complexe et source d'erreurs**. Les pods **encapsulent automatiquement** ces responsabilités (réseau partagé, stockage, gestion du cycle de vie) sans intervention manuelle.

### Déployer un pod avec kubectl (commandes essentielles)

Créer un pod exécutant l'image nginx :

```bash
kubectl run nginx --image nginx
```

Cette commande récupère l'image nginx depuis Docker Hub par défaut (des configurations supplémentaires sont nécessaires pour les dépôts privés).

Vérifier le statut du pod :

```bash
kubectl get pods
```

Exemple de sortie — le pod passe du statut `ContainerCreating` à `Running` :

```
NAME                   READY   STATUS              RESTARTS   AGE
nginx-8586cf59-whssr   0/1     ContainerCreating   0          3s
...
nginx-8586cf59-whssr   1/1     Running             0          8s
```

> **Note** : à ce stade, le serveur nginx n'est accessible qu'en **interne**. Pour l'exposer aux utilisateurs finaux, des **configurations réseau et de service supplémentaires** sont nécessaires.

### Conclusion

Les pods sont fondamentaux dans Kubernetes : ils encapsulent les conteneurs et simplifient le scaling, le déploiement et la gestion. Qu'il s'agisse d'un conteneur unique ou d'une configuration multi-conteneurs, l'abstraction du pod offre une base robuste pour des applications évolutives et résilientes.

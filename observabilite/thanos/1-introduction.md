# Introduction à Thanos

### Définition

**Thanos** fournit une vue globale des requêtes, une haute disponibilité, une sauvegarde des données avec un accès aux données historiques et bon marché comme fonctionnalités principales dans un seul binaire.
<br>
Ces fonctionnalités peuvent être déployées indépendamment les unes des autres. Cela nous permet de disposer d'un sous-ensemble de fonctionnalités de Thanos prêtes à être utilisées ou testées immédiatement, tout en le rendant flexible pour un déploiement progressif dans des environnements plus complexes.
<br>
**Thanos** peut être exécuté dans Kubernetes ou sur le bare metal.
<br>
**Thanos** vise un modèle de déploiement et de maintenance simple. Les seules dépendances sont :

- Une ou plusieurs installations **Prometheus v2.2.1+** avec disque persistant.
- Une dépendance optionnelle : **stockage d'objets**. **Thanos** est capable d'utiliser de nombreux fournisseurs de stockage différents, avec la possibilité d'en ajouter davantage si nécessaire.

### Composants de Thanos

Thanos est composé d'un ensemble de composants où chacun remplit un rôle spécifique.

- **Thanos sidecar**

**Thanos** s'intègre aux serveurs Prometheus existants en tant que processus **sidecar**, qui s'exécute sur la même machine ou dans le même pod que le serveur Prometheus.

Le but de **Thanos Sidecar** est de sauvegarder les données de Prometheus dans un compartiment de stockage d'objets et de permettre à d'autres composants Thanos d'accéder aux métriques Prometheus via une **API gRPC**.

**Thanos sidecar** utilise le endpoint de rechargement de Prometheus. Il doit activé avec l'indicateur **--web.enable-lifecycle**.

Exemple de configuration de **Thanos Sidecar** pour écrire les données de Prometheus dans un compartiment de stockage d'objets configuré :

```
thanos sidecar \
    --tsdb.path /var/prometheus \  # Répertoire de données de prometheus
    --prometheus.url "http://localhost:9090" \  # URL à laquelle accéder à l'API de Prometheus
    --objstore.config-file bucket_config.yaml \  # Configuration de stockage pour le téléchargement de données
```

Le format exact du fichier YAML dépend du fournisseur que nous choisissons (https://thanos.io/tip/thanos/storage.md).

- **Thanos store Gateway**

Comme **Thanos Sidecar** sauvegarde les données dans le compartiment de stockage d'objets de notre choix, nous pouvons réduire la rétention de Prometheus afin de stocker moins de données localement. Cependant, nous avons besoin d’un moyen d’interroger à nouveau toutes ces données historiques. C'est exactement ce que fait **Thanos store Gateway**, en implémentant la même API de données gRPC que **Sidecar**, mais en la sauvegardant avec les données qu'il peut trouver dans notre compartiment de stockage d'objets. Tout comme les **Sidecar** et les **nœuds de requête**, **Thanos store Gateway** expose une API Store et doit être découvert par **Thanos Querier**.

```
thanos store \
    --data-dir /var/thanos/store \  # Espace disque pour les caches locaux
    --objstore.config-file bucket_config.yaml \  # Compartiment à partir duquel récupérer les données
    --http-address 0.0.0.0:19191 \  # endpoint HTTP pour collecter des métriques sur Store Gateway
    --grpc-address 0.0.0.0:19090  # endpoint GRPC pour StoreAPI
```

- **Thanos Compactor**

Une installation locale de **Prometheus** compacte périodiquement les données plus anciennes pour améliorer l'efficacité des requêtes. Étant donné que **Sidecar** sauvegarde les données dans un compartiment de stockage d'objets dès que possible, nous avons besoin d'un moyen d'appliquer le même processus aux données du compartiment.

**Thanos Compactor** analyse simplement le compartiment de stockage d'objets et effectue le compactage si nécessaire. Dans le même temps, il est chargé de créer des copies sous-échantillonnées des données afin d’accélérer les requêtes.

```
thanos compact \
    --data-dir /var/thanos/compact \  # Espace de travail temporaire pour le traitement des données
    --objstore.config-file bucket_config.yaml \  # Compartiment où le compactage sera effectué
    --http-address 0.0.0.0:19191 # endpoint HTTP pour collecter des métriques sur le compacteur
```

**Thanos Compactor** ne se trouve pas dans le chemin critique des requêtes ou de la sauvegarde des données. Il peut être exécuté sous forme de job par lots périodique ou laissé en cours d'exécution pour toujours compacter les données dès que possible. Il est recommandé de fournir 100 à 300 Go d'espace disque local pour le traitement des données.

**Thanos Compactor** doit être exécuté en tant que singleton et ne doit pas s'exécuter lors de la modification manuelle des données dans le compartiment.

- **Thanos receiver**

La commande **Thanos receiver** implémente l'API **Prometheus Remote Write**. Il s'appuie sur la TSDB Prometheus existante et conserve son utilité tout en étendant ses fonctionnalités avec un stockage à long terme, une évolutivité horizontale et un sous-échantillonnage. Les instances Prometheus sont configurées pour y écrire en continu des métriques, puis **Thanos Receiver** télécharge les blocs TSDB dans un compartiment de stockage d'objets toutes les 2 heures par défaut. **Thanos Receiver** expose **StoreAPI** afin que les **Thanos Queriers** puissent interroger les métriques reçues en temps réel.

```
thanos receive \
    --tsdb.path "/path/to/receive/data/dir" \  # Répertoire de données de TSDB. 
    --grpc-address 0.0.0.0:10907 \  # endpoint GRPC pour StoreAPI
    --http-address 0.0.0.0:10909 \  # endpoint HTTP pour l'interrogation
    --receive.replication-factor 1 \  # Combien de fois répliquer les demandes d'écriture entrantes
    --label "receive_replica=\"0\"" \  # Etiquette d'annonce
    --label "receive_cluster=\"eu1\"" \
    --receive.local-endpoint 127.0.0.1:10907 \  # endpoint du nœud de réception local. Utilisé pour identifier le nœud local dans la configuration de hachage.
    --receive.hashrings-file ./data/hashring.json \  # Chemin d'accès au fichier contenant la configuration de hachage.
    --remote-write.address 0.0.0.0:10908 \  # Adresse sur laquelle écouter les demandes d’écriture à distance
    --objstore.config-file "bucket.yml"  # Configuration de stockage pour le téléchargement de données
```

- **Thanos Querier/Query**

Maintenant que nous avons configuré **Thanos sidecar** pour une ou plusieurs instances Prometheus, nous souhaitons utiliser la couche de requête globale de Thanos pour évaluer les requêtes PromQL sur toutes les instances à la fois.

Le composant **Querier** est sans état et évolutif horizontalement, et peut être déployé avec n'importe quel nombre de réplicas. Une fois connecté à **Thanos Sidecar**, il détecte automatiquement quels serveurs Prometheus doivent être contactés pour une requête PromQL donnée.

**Thanos Querier** implémente également l'API HTTP officielle de Prometheus et peut ainsi être utilisé avec des outils externes tels que Grafana. Il sert également de dérivé de l’interface utilisateur de Prometheus pour les requêtes **adhoc** et la vérification de l’état des magasins Thanos.

```
thanos query \
    --http-address 0.0.0.0:19192 \  # Endpoint pour Thanos Querier UI
    --endpoint 1.2.3.4:19090 \  # Adresse gRPC du StoreAPI pour pour le nœud de requête à interroger
    --endpoint 1.2.3.5:19090 \  # Également reproductible avec une autre adresse IP
    --endpoint dnssrv+_grpc._tcp.thanos-store.monitoring.svc  # Prend en charge les enregistrements DNS A et SRV
```

- **Thanos Ruler/Rule**

Dans le cas où Prometheus fonctionnant avec **Thanos Sidecar** n'a pas suffisamment de rétention, ou si nous souhaitons avoir des alertes ou des règles d'enregistrement qui nécessitent une vue globale, Thanos a juste le composant pour cela : **Ruler/Rule**, qui effectue une évaluation des règles et des alertes au-dessus d'une vue globale étant donné **Thanos Querier**.


- **Thanos query frontend**

**Thanos query frontend** implémente un service qui peut être placé devant **Thanos Queriers** pour améliorer le chemin de lecture. Il est basé sur le composant **Cortex Query Frontend** afin que nous puissions trouver certaines fonctionnalités communes telles que le fractionnement et la mise en cache des résultats.

**Thanos query frontend** est entièrement sans état et évolutif horizontalement.

<br>

**Référence :** https://thanos.io/tip/thanos/getting-started.md
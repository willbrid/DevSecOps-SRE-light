# Mise en place du composant Thanos querier

Nous installerons **thanos Querier** sur le serveur **srv-zoneAdmin** qui utilisera nos composants **thanos sidecars** et permettra d'interroger toutes les métriques à partir d'un seul endroit.

**NB: Version de thanos -> 0.36**

- Le composant **thanos Querier** est essentiellement un moteur **PromQL Prometheus** qui récupère les données de n'importe quel service qui implémente **thanos StoreAPI**. Cela signifie que **thanos Querier** expose l'API Prometheus HTTP v1 pour interroger les données dans un langage PromQL commun. Cela permet la compatibilité avec Grafana ou d'autres consommateurs de l'API de Prometheus.

- Le composant **thanos Querier** est capable de dédupliquer les données **StoreAPI** qui se trouvent dans le même groupe **HA**.

### Autorisation des ports des composants thanos sidecar sur les serveurs srv-clusterA et srv-clusterB

sur le serveur **srv-clusterA**

```
sudo firewall-cmd --permanent --add-port=19190/tcp
sudo firewall-cmd --reload
```

sur le serveur **srv-clusterB**

```
sudo firewall-cmd --permanent --add-port=19191/tcp --add-port=19192/tcp
sudo firewall-cmd --reload
```

Pour vérifier ces configurations, nous utilisons la commande

```
sudo firewall-cmd --list-all
```

### Installation du composant Thanos Querier

Sur le serveur **srv-zoneAdmin**

```
podman run -d --net=host \
    --name querier \
    quay.io/thanos/thanos:v0.36.0 \
    query \
    --http-address 0.0.0.0:29090 \
    --query.replica-label replica \
    --store 192.168.56.140:19190 \
    --store 192.168.56.141:19191 \
    --store 192.168.56.141:19192 && echo "Started Thanos Querier"
```

**Thanos Querier** expose une interface utilisateur très similaire à celle de Prometheus, mais en plus de nombreuses composant **StoreAPI** auxquelles nous souhaitons nous connecter.

Nous démarrons le parefeu **firewalld** et autorisons le port **29090** sur le serveur **srv-zoneAdmin**

```
sudo systemctl enable firewalld --now
sudo systemctl status firewalld
```

```
sudo firewall-cmd --permanent --add-port=29090/tcp
sudo firewall-cmd --reload
```

Au niveau de notre machine hôte ubuntu20.04, nous ajoutons un mappage dns statique dans le fichier **/etc/hosts**

```
sudo vi /etc/hosts
```

```
...
192.168.56.142  thanos-querier.local
```

Nous accédons à ce lien **http://thanos-querier.local:29090** via notre navigateur de la machinae hôte, puis nous saisissons les requêtes promQL

```
prometheus_tsdb_head_series
```

```
sum(prometheus_tsdb_head_series)
```

- Gestion de Prometheus hautement disponible

Nous avons configuré **Prometheus 0 B** et **Prometheus 1 B** pour scrapper les mêmes choses. Nous connectons également Querier aux deux, alors comment **Thanos Querier** sait-il ce qu'est un groupe HA ?

Si nous examinons à nouveau la configuration de **Thanos Querier**, nous pouvons voir que nous définissons également l'indicateur **query.replica-label**. C'est exactement l'étiquette par laquelle **Thanos Querier** tentera de dédupliquer les groupes **HA**. Cela signifie que toute métrique portant exactement les mêmes étiquettes, à l'exception de l'étiquette **réplica**, sera considérée comme la métrique du même groupe **HA** et dédupliquée en conséquence.

- Déploiement en production

Normalement, **Thanos Querier** s'exécute dans un emplacement central (par exemple à côté de Grafana) avec un accès à distance à tous les Prometheus (par exemple via une entrée, un VPN proxy ou un peering). <br>
Nous pouvons également fédérer des requêtes au-dessus d'autres requêtes, car les requêtes exposent également **StoreAPI** !
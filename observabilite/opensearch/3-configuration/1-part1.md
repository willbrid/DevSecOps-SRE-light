# Etape 1 : configuration de notre cluster

#### Configuration du nom de notre cluster

Spécifions un nom unique pour le cluster. Si nous ne spécifions pas de nom de cluster, il est défini sur opensearch par défaut. La définition d'un nom de cluster descriptif est importante, en particulier si nous souhaitons exécuter plusieurs clusters au sein d'un même réseau.
<br><br>

Sur chaque noeud de notre cluster il faut configurer le fichier comme suit :

```
vi /etc/opensearch/opensearch.yml
```

```
cluster.name: opensearch-cluster
plugins.security.disabled: false
cluster.initial_cluster_manager_nodes: ["opensearch-m"]
```

Nous précisons sur chaque noeud notre noeud gestionnaire **opensearch-m** pour permettre de définir le noeud master de notre cluster. <br>
Nous activons la sécurité via le paramètre **plugins.security.disabled**.

#### Configuration de chaque noeud

Nous allons définir les attributs de nœud pour chaque nœud de notre cluster.

- configuration du noeud gestionnaire **opensearch-m**


```
vi /etc/opensearch/opensearch.yml
```

```
node.name: opensearch-m
node.roles: [ cluster_manager ]
network.host: 192.168.56.70
discovery.seed_hosts: ["192.168.56.71", "192.168.56.72", "192.168.56.73", "192.168.56.74"]
```

Nous donnons le nom unique **opensearch-m** à notre noeud de coordination sur le cluster via le paramètre **node.name**. <br>
Nous spécifions explicitement que ce nœud est un nœud de gestionnaire de cluster via le paramètre **node.roles**. <br>
Nous précisons l'adresse IP du noeud **opensearch-m** via le paramètre **network.host** et les adresses IP des autres noeuds via le paramètre **discovery.seed_hosts**.

- configuration du noeud de coordination **opensearch-c**

```
vi /etc/opensearch/opensearch.yml
```

```
node.name: opensearch-c
node.roles: []
network.host: 192.168.56.71
discovery.seed_hosts: ["192.168.56.70", "192.168.56.72", "192.168.56.73", "192.168.56.74"]
```

Nous donnons le nom unique **opensearch-c** à notre noeud de coordination sur le cluster via le paramètre **node.name**. <br>
Nous spécifions explicitement que ce nœud est un nœud de coordination de notre cluster via le paramètre **node.roles** en renseignant un tableau vide. <br>
Nous précisons l'adresse IP du noeud **opensearch-c** via le paramètre **network.host** et les adresses IP des autres noeuds via le paramètre **discovery.seed_hosts**.

- configuration de nos noeuds de données

--- pour le noeud **opensearch-d1**, nous faisons comme suit :

```
vi /etc/opensearch/opensearch.yml
```

```
node.name: opensearch-d1
node.roles: [ data, ingest ]
node.attr.zone: zoneA
node.attr.temp: hot
network.host: 192.168.56.72
discovery.seed_hosts: ["192.168.56.70", "192.168.56.71", "192.168.56.73", "192.168.56.74"]
```

Nous donnons le nom unique **opensearch-d1** à notre noeud de données **opensearch-d1** sur le cluster via le paramètre **node.name**. <br>
Nous spécifions explicitement que ce nœud est un nœud de **données** (**data**) et d'**ingestion** (**ingest**) de notre cluster via le paramètre **node.roles**. <br>
Pour configurer la prise en compte de l'allocation de partition, nous ajoutons un attribut **zone** (valeur : **zoneA**) via le paramètre **node.attr.zone**. <br>
Pour configurer ce noeud en noeud **hot**, nous ajoutons un attribut **temp** (valeur : **hot**) via le paramètre **node.attr.temp**. <br>
Nous précisons l'adresse IP du noeud **opensearch-d1** via le paramètre **network.host** et les adresses IP des autres noeuds via le paramètre **discovery.seed_hosts**.
<br><br>
--- pour le noeud **opensearch-d2**, nous faisons comme suit :

```
vi /etc/opensearch/opensearch.yml
```

```
node.name: opensearch-d2
node.roles: [ data, ingest ]
node.attr.zone: zoneB
node.attr.temp: hot
network.host: 192.168.56.73
discovery.seed_hosts: ["192.168.56.70", "192.168.56.71", "192.168.56.72", "192.168.56.74"]
```

Nous donnons le nom unique **opensearch-d2** à notre noeud de données **opensearch-d2** sur le cluster via le paramètre **node.name**. <br>
Nous spécifions explicitement que ce nœud est un nœud de **données** (**data**) et d'**ingestion** (**ingest**) de notre cluster via le paramètre **node.roles**. <br>
Pour configurer la prise en compte de l'allocation de partition, nous ajoutons un attribut **zone** (valeur : **zoneB**) via le paramètre **node.attr.zone**. <br>
Pour configurer ce noeud en noeud **hot**, nous ajoutons un attribut **temp** (valeur : **hot**) via le paramètre **node.attr.temp**. <br>
Nous précisons l'adresse IP du noeud **opensearch-d2** via le paramètre **network.host** et les adresses IP des autres noeuds via le paramètre **discovery.seed_hosts**.
<br><br>
--- pour le noeud **opensearch-d3**, nous faisons comme suit :

```
vi /etc/opensearch/opensearch.yml
```

```
node.name: opensearch-d3
node.roles: [ data, ingest ]
node.attr.zone: zoneA
node.attr.temp: warm
network.host: 192.168.56.74
discovery.seed_hosts: ["192.168.56.70", "192.168.56.71", "192.168.56.72", "192.168.56.73"]
```

Nous donnons le nom unique **opensearch-d3** à notre noeud de données **opensearch-d3** sur le cluster via le paramètre **node.name**. <br>
Nous spécifions explicitement que ce nœud est un nœud de **données** (**data**) et d'**ingestion** (**ingest**) de notre cluster via le paramètre **node.roles**. <br>
Pour configurer la prise en compte de l'allocation de partition, nous ajoutons un attribut **zone** (valeur : **zoneA**) via le paramètre **node.attr.zone**. <br>
Pour configurer ce noeud en noeud **warm**, nous ajoutons un attribut **temp** (valeur : **warm**) via le paramètre **node.attr.temp**. <br>
Nous précisons l'adresse IP du noeud **opensearch-d3** via le paramètre **network.host** et les adresses IP des autres noeuds via le paramètre **discovery.seed_hosts**.

#### Démarrage du service sur nos noeuds

Nous démarrons le service opensearch sur nos 5 noeuds progressivement en commençant par notre noeud gestionnaire, puis notre noeud de coordination et enfin nos noeuds de données.

```
sudo systemctl start opensearch.service
```

Nous pouvons vérifier que tout se passe bien : <br>

--- en vérifiant le statut du service

```
sudo systemctl status opensearch.service
```

Nous devrions avoir le message **Started OpenSearch**.

--- en listant les ports (**9200**, **9300**) d'écoute sur nos 5 noeuds

```
ss -tupln
```

--- en consultant les logs **/var/log/opensearch/opensearch-cluster.log** de chaque noeud afin de se rassurer qu'ils sont disponible dans le cluster

```
sudo tail -f /var/log/opensearch/opensearch-cluster.log
```

--- en effectuant la requête **_cat** suivante sur chaque nœud pour voir tous les nœuds formés en tant que cluster :

```
curl -XGET https://<ADRESSE_IP_NOEUD>:9200/_cat/nodes?v -u 'admin:admin' --insecure
```

NB : **'admin:admin'** est l'utilisateur et le mot de passe par défaut.
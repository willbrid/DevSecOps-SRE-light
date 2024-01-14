# Configuration du service opensearch et son dashboard via docker

Dans cette partie, nous utiliserons nos images **opensearchproject/opensearch:2.7.0** et **opensearchproject/opensearch-dashboards:2.7.0** préalablement téléchargées dans notre serveur **opensearch-cluster**.

- Définition de notre fichier **docker-compose.yml**

```
vi docker-compose.yml
```

```
version: '3'
services:
  opensearch-m:
    image: opensearchproject/opensearch:2.7.0
    container_name: opensearch-m
    mem_limit: "2g"
    cpus: "2"
    environment:
      - cluster.name=opensearch-cluster 
      - node.name=opensearch-m
      - 'NODE.ROLES=["cluster_manager"]'
      - discovery.seed_hosts=opensearch-c,opensearch-d1,opensearch-d2,opensearch-d3
      - cluster.initial_cluster_manager_nodes=opensearch-m
      - bootstrap.memory_lock=true 
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"
      - "DISABLE_SECURITY_PLUGIN=false"
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - opensearch-m:/usr/share/opensearch/data
    ports:
      - 9200:9200 
      - 9600:9600 
    networks:
      - opensearch-net
  opensearch-c:
    image: opensearchproject/opensearch:2.7.0
    container_name: opensearch-c
    mem_limit: "2g"
    cpus: "2"
    depends_on:
      - opensearch-m
    environment:
      - cluster.name=opensearch-cluster
      - node.name=opensearch-c
      - 'NODE.ROLES=[]'
      - discovery.seed_hosts=opensearch-m,opensearch-d1,opensearch-d2,opensearch-d3
      - cluster.initial_cluster_manager_nodes=opensearch-m
      - bootstrap.memory_lock=true
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"
      - "DISABLE_SECURITY_PLUGIN=false"
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - opensearch-c:/usr/share/opensearch/data
    networks:
      - opensearch-net
  opensearch-d1:
    image: opensearchproject/opensearch:2.7.0
    container_name: opensearch-d1
    mem_limit: "4g"
    cpus: "1"
    depends_on:
      - opensearch-m
      - opensearch-c
    environment:
      - cluster.name=opensearch-cluster
      - node.name=opensearch-d1
      - 'NODE.ROLES=["data", "ingest"]'
      - node.attr.zone=zoneA
      - node.attr.temp=hot
      - discovery.seed_hosts=opensearch-m,opensearch-c,opensearch-d2,opensearch-d3
      - cluster.initial_cluster_manager_nodes=opensearch-m
      - bootstrap.memory_lock=true
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"
      - "DISABLE_SECURITY_PLUGIN=false"
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - opensearch-d1:/usr/share/opensearch/data
    networks:
      - opensearch-net
  opensearch-d2:
    image: opensearchproject/opensearch:2.7.0
    container_name: opensearch-d2
    mem_limit: "4g"
    cpus: "1"
    depends_on:
      - opensearch-m
      - opensearch-c
    environment:
      - cluster.name=opensearch-cluster
      - node.name=opensearch-d2
      - 'NODE.ROLES=["data", "ingest"]'
      - node.attr.zone=zoneB
      - node.attr.temp=hot
      - discovery.seed_hosts=opensearch-m,opensearch-c,opensearch-d1,opensearch-d3
      - cluster.initial_cluster_manager_nodes=opensearch-m
      - bootstrap.memory_lock=true
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"
      - "DISABLE_SECURITY_PLUGIN=false"
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - opensearch-d2:/usr/share/opensearch/data
    networks:
      - opensearch-net
  opensearch-d3:
    image: opensearchproject/opensearch:2.7.0
    container_name: opensearch-d3
    mem_limit: "4g"
    cpus: "1"
    depends_on:
      - opensearch-m
      - opensearch-c
    environment:
      - cluster.name=opensearch-cluster
      - node.name=opensearch-d3
      - 'NODE.ROLES=["data", "ingest"]'
      - node.attr.zone=zoneA
      - node.attr.temp=warm
      - discovery.seed_hosts=opensearch-m,opensearch-c,opensearch-d1,opensearch-d2
      - cluster.initial_cluster_manager_nodes=opensearch-m
      - bootstrap.memory_lock=true
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"
      - "DISABLE_SECURITY_PLUGIN=false"
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - opensearch-d3:/usr/share/opensearch/data
    networks:
      - opensearch-net        
  opensearch-dashboards:
    image: opensearchproject/opensearch-dashboards:2.7.0
    container_name: opensearch-dashboards
    depends_on:
      - opensearch-m
      - opensearch-c
      - opensearch-d1
      - opensearch-d2
      - opensearch-d3
    ports:
      - 5601:5601 
    expose:
      - "5601"
    environment:
      - 'OPENSEARCH_HOSTS=["https://opensearch-c:9200"]'
      - "DISABLE_SECURITY_DASHBOARDS_PLUGIN=false"
    networks:
      - opensearch-net

volumes:
  opensearch-m:
  opensearch-c:
  opensearch-d1:
  opensearch-d2:
  opensearch-d3:

networks:
  opensearch-net:
```

```
docker-compose up -d
```

Si tout se passe bien, nous pouvons accéder à notre interface dashboard via l'url : 

```
http://192.168.56.77:5601/
```
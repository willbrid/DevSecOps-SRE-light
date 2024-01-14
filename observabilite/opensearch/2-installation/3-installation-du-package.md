# Installation du package opensearch (version 2.7.0)

#### Architecture avec conteneur

Pour notre architecture avec conteneur, nous pouvons faire un pull de l'image de opensearch de sa version 2.7.0 et celle de son dasboard pour la même version 2.7.0.

```
docker pull opensearchproject/opensearch:2.7.0
```

```
docker pull opensearchproject/opensearch-dashboards:2.7.0
```

#### Architecture avec machine virtuelle

###### Installation d'opensearch

Ici nous allons nous connecter sur chaque VM afin d'appliquer les commandes d'installation ci-après.

- Créons un fichier de référentiel local pour OpenSearch

```
sudo curl -SL https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/opensearch-2.x.repo -o /etc/yum.repos.d/opensearch-2.x.repo
```

- Nettoyons notre cache YUM pour assurer une installation fluide

```
sudo yum clean all
```

- Vérifions que le référentiel a été créé avec succès.

```
sudo yum repolist
```

- Une fois le fichier de référentiel téléchargé, répertorions toutes les versions disponibles d'openSearch

```
sudo yum list opensearch --showduplicates
```

- Installons opensearch

```
sudo yum install 'opensearch-2.7.0'
```

- Activons opensearch au demarrage du système

```
sudo systemctl enable opensearch
```

###### Installation du dashboard d'opensearch

Ici nous allons nous connecter sur notre noeud de coordination afin d'appliquer les commandes d'installation d'opensearch-dashboards ci-après.

- Créons un fichier de référentiel local pour Opensearch-dashboards

```
sudo curl -SL https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.x/opensearch-dashboards-2.x.repo -o /etc/yum.repos.d/opensearch-dashboards-2.x.repo
```

- Nettoyons notre cache YUM pour assurer une installation fluide

```
sudo yum clean all
```

- Vérifions que le référentiel a été créé avec succès.

```
sudo yum repolist
```

- Une fois le fichier de référentiel téléchargé, répertorions toutes les versions disponibles d'opensearch-dashboards

```
sudo yum list opensearch-dashboards --showduplicates
```

- Installons opensearch-dashboards

```
sudo yum install 'opensearch-dashboards-2.7.0'
```

- Activons opensearch-dashboards au demarrage du système

```
sudo systemctl enable opensearch-dashboards
```
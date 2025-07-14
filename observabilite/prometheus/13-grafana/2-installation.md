# Installation de grafana oss 12.0.2

Dans ce tutoriel, nous allons installer grafana et ajouter la source de données de **prometheus**.

### Installation de grafana oss sur le serveur monitoring de la sandbox

- Nous téléchargeons et installons le binaire de grafana

```
sudo yum install -y https://dl.grafana.com/oss/release/grafana-12.0.2-1.x86_64.rpm
```

- Nous activons et démarrons grafana

```
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

- Nous autorisons le port 3000 au niveau du parefeu

```
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload
```

- Nous accédons à l'interface ui via **http://192.168.56.230:3000**.

Paramètre d'authentification par défaut :

```
username : admin
password : admin
```

Mot de passe configuration pour ce homelab

```
password : admin2025
```

### Ajout de la source Prometheus à Grafana

- Nous cliquons sur l'option "ajouter une source" sur la page d'accueil de Grafana.
- Nous ajoutons le nom de la source, les détails du endpoint prometheus et nous l'enregistrons.

### Importation de modèles de tableau de bord Grafana prédéfinis

Nous pouvons trouver tous les tableaux de bord communautaires partagés à partir des [modèles partagés Grafana](https://grafana.com/dashboards?dataSource=prometheus)

- Nous sélectionnons l'option d'importation.
- Voici les options d'importation prises en charge. Nous pouvons ajouter l'ID de tableau de bord que nous obtenons sur le site Web de grafana, télécharger le json ou coller le json dans la zone de texte.
- Nous ajoutons un nom de modèle, une source Prometheus, un dossier de tableau de bord de destination et cliquez sur *importer*.

**Référence** : https://grafana.com/grafana/download?edition=oss
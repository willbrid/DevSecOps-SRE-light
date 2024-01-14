# Gestion des alertes dans alertmanager
- **Routage** : alertmanager implémente une arborescence de routage, qui est représentée dans le bloc **route** de notre fichier de configuration alertmanager ('alertmanager.yml'). L'arborescence de routage contrôle la logique de comment et quand les alertes seront envoyées.

- **Regroupement** : il nous permet de combiner plusieurs alertes en une seule notification.<br>

Exemple : Plusieurs serveurs sont tombés en panne au lieu de recevoir un e-mail pour chaque serveur, nous recevons un e-mail d'alerte nous indiquant le nombre de serveurs en panne. <br> Utilisons le bloc **group_by** dans nos routes pour définir les étiquettes qui seront utilisées pour regrouper les alertes.

- **Inhibition** : permet de supprimer une alerte si une autre alerte est déjà déclenchée.<br>

Exemple : Notre centre de données vient de perdre la connectivité réseau. Au lieu de recevoir des alertes pour chaque application inaccessible, l'alerte de connectivité réseau supprime toutes ces autres alertes. <br> Utilisons le bloc **inhibit_rule** dans notre configuration alertmanager pour définir les correspondances pour lesquelles les alertes inhiberont les autres alertes.

- **silences** : c'est un moyen simple de désactiver temporairement certaines notifications. <br>

Exemple : Notre infrastructure rencontre des problèmes généralisés dont nous sommes déjà conscient. Nous utilisons des **silences** pour arrêter temporairement les alertes pendant que nous corrigeons le problème. <br> Les silences sont configurés via l'interface utilisateur Web alertmanager.

## Configuration des alertes de test
Créeons un fichier de règles d'alerte avec quelques alertes test :
```
sudo vi /etc/prometheus/rules/test-alerts.yml
```

```
groups:
- name: test-alerts
  rules:
  - alert: Server1Down
    expr: 1
    labels:
      severity: critical
      service: linuxserver
    annotations:
      summary: Server 1 Down
  - alert: Server2Down
    expr: 1
    labels:
      severity: critical
      service: linuxserver
    annotations:
      summary: Server 2 Down
  - alert: DownstreamServiceDown
    expr: 1
    labels:
      severity: critical
    annotations:
      summary: A downstream service is broken.
```

```
sudo systemctl restart prometheus
```

Accédons à Prometheus dans un navigateur à l'adresse :
```
http://<IP_SERVEUR_PROMETHEUS>:9093
```

Cliquons sur **Alerts**. Nous devrions voir ces trois alertes actives.

## Configuration du routage pour regrouper les alertes similaires
Modifions notre configuration Alertmanager en ajoutant un nouveau nœud de routage pour regrouper les alertes **Server.\*Down** :
```
sudo vi /etc/alertmanager/alertmanager.yml
```

```
route:
  ...
  routes:
  - receiver: 'web.hook'
    group_by: ['service']
    match_re:
      alertname: 'Server.*Down'
```

```
sudo killall -HUP alertmanager
```

Actualisons Alertmanager dans notre navigateur. Les deux Server.*Down doivent être combinés en un seul groupe.

## Configuration d'une inhibition pour supprimer l'alerte DownstreamServiceDown
Modifions notre configuration Alertmanager en ajoutant une règle d'inhibition pour supprimer l'alerte **DownstreamServiceDown** lorsque l'une des alertes **Server.\*Down** est active :
```
sudo vi /etc/alertmanager/alertmanager.yml
```

```
inhibit_rules:
 ...
 - source_match_re:
     alertname: 'Server.*Down'
   target_match:
     alertname: 'DownstreamServiceDown'
```

```
sudo killall -HUP alertmanager
```

Actualisons Alertmanager dans notre navigateur. L'alerte **DownstreamServiceDown** ne devrait plus apparaître. Nous pouvons cliquer sur la case inhibée pour le rendre à nouveau visible.

## Désactivation temporaire d'une alerte
Accédons à Alertmanager dans un navigateur Web à l'adresse : 

```
http://<PROMETHEUS_SERVER_PUBLIC_IP>:9093
```

Etendons le groupe **service="linuxserver"**. Localisons l'alerte avec **alertname="Server1Down"**, et cliquons sur le bouton **Silence** pour cette alerte. Remplissons les champs **Creator** et **Comment**, puis cliquons sur **Create**. Si nous revenons à la page principale d'Alertmanager, l'alerte **Server1Down** ne devrait plus apparaître.
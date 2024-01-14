# Pousser les données vers Pushgateway
Pour pousser les métriques vers pushgateway, nous envoyons simplement les données de métriques via http avec l'API pushgateway.

```
/metrics/job/some_job/instance/some_instance
```

Le corps de la requête doit contenir des données formatées comme n'importe quelle autre métrique d'exportateur prometheus.
<br>
Les bibliothèques clientes prometheus incluent également une fonctionnalité pour pousser les données via pushgateway.
<br>
- **Exemple 1** : Effectuer une requête curl pour envoyer la métrique *value_of_pi* à l'API Pushgateway

```
echo "value_of_pi 3.14" | curl --data-binary @- http://localhost:9091/metrics/job/my_job
```

Nous interrogeons le endpoint des métriques Pushgateway pour voir la métrique que nous avons envoyée :
```
curl localhost:9091/metrics
```

- **Exemple 2** : Effectuer une requête curl avec un ensemble de métriques plus complexe, en spécifiant cette fois une instance

```
cat << EOF | curl --data-binary @- http://localhost:9091/metrics/job/my_job/instance/my_instance
# TYPE temperature gauge
temperature{location="room1"} 31
temperature{location="room2"} 33
# TYPE my_metric gauge
# HELP my_metric An example.
my_metric 5
EOF
```

Nous interrogeons le endpoint des métriques Pushgateway pour voir les métriques que nous avons envoyées :
```
curl localhost:9091/metrics
```

Nous pouvons aussi utiliser le navigateur d'expressions pour voir les métriques envoyées en accédant au lien
```
http://<IP_SERVEUR_PROMETHEUS>:9090.
```

et en saisissant ces requêtes :
```
value_of_pi
```

```
temperature
```

```
my_metric
```
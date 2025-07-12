# Navigateur d'expressions

Navigateur d'expressions : il s'agit d'une interface utilisateur Web intégrée pour exécuter des requêtes et afficher des graphes simples.
Il est principalement utilisé pour les requêtes ad hoc et le débogage de base. <br>
Des outils de visualisation plus avancés seront probablement nécessaires pour la surveillance quotidienne. <br>
Nous pouvons accéder au navigateur d'expressions via le endpoint /graph sur notre serveur prometheus.

- Accédons au navigateur d'expressions dans un navigateur Web à l'adresse en saisissant sur le navigateur : **http://192.168.56.230:9090/query** .


- Exécutons une requête simple pour récupérer des données de séries temporelles

```
node_cpu_seconds_total[5m]
```

Nous devrions voir plusieurs métriques, chacune avec plusieurs entrées de séries temporelles. <br>
Expérimentons avec les entrées **Moment** pour définir une plage de date de notre requête et afficher les résultats correspondant à cette plage.

- Passons à la vue graphe

Écrivons une requête qui affiche l'utilisation actuelle du processeur dans différents modes

```
rate(node_cpu_seconds_total[5m])
```
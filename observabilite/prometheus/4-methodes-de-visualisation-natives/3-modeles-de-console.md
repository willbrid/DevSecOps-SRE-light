# Modèles de console

Les modèles de console nous permettent de créer des consoles de visualisation à l'aide du langage de modélisation go. Le serveur Prometheus sert des consoles basées sur ces modèles.

- Bases du modèle

Les fichiers modèles sont stockés à l'emplacement défini par l'argument **--web.console.templates** (**/etc/prometheus/consoles**)
Nous pouvons afficher les modèles en accédant au endpoint **/consoles/<nom du fichier modèle>** sur notre serveur prometheus.

- Exemples de modèles

Nous pouvons trouver des exemples de fichiers modèles situés dans **/etc/prometheus/consoles** . La documentation prometheus contient également des exemples.

- Création des modèles de console

Les modèles de console contiennent du code HTML avec des expressions de modèle Go qui seront remplacées dynamiquement par des données prometheus lors du rendu de la console.

Connectons-nous à notre serveur Prometheus et créeons un fichier de modèle de console :

```
sudo su

mkdir /etc/prometheus/consoles && vi /etc/prometheus/consoles/disk-io.html
```

Implémentons un modèle de console de base qui affiche certaines données :

```
{{template "head" .}}
{{template "prom_content_head" .}}
<h1>Disk IO Rate</h1>
<br />
Current Disk IO: {{ template "prom_query_drilldown" (args
"rate(node_disk_io_time_seconds_total{job='Linux Server'}[5m])") }}
{{template "prom_content_tail" .}}
{{template "tail"}}
```

Affichons notre modèle de console dans un navigateur Web : **http://192.168.56.230:9090/consoles/disk-io.html** .
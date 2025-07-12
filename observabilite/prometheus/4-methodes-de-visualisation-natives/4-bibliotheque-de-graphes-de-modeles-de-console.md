# Bibliothèque de graphes de modèles de console

La bibliothèque de graphiques nous permet de rendre des graphes dans les modèles de notre console.

Connectons-nous à notre serveur Prometheus et modifions le fichier de modèle de notre console :

```
sudo vi /etc/prometheus/consoles/disk-io.html
```

Ajoutons un graphique à votre modèle de console :

```
{{template "head" .}}
{{template "prom_content_head" .}}
<h1>Disk IO Rate</h1>
<br />
Current Disk IO: {{ template "prom_query_drilldown" (args "rate(node
_disk_io_time_seconds_total{job='Linux Server'}[5m])") }}
<br />
<br />
<div id="diskIoGraph"></div>
<script>
new PromConsole.Graph({
 node: document.querySelector("#diskIoGraph"),
 expr: "rate(node_disk_io_time_seconds_total{job='Linux Server'}
[5m])"
})
</script>
{{template "prom_content_tail" .}}
{{template "tail"}}
```

Affichons notre modèle de console dans un navigateur Web : **http://192.168.56.230:9090/consoles/disk-io.html** .
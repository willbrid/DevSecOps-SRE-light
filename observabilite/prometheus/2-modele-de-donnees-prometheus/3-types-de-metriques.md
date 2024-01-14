# Types de métriques

Les exportateurs Prometheus utilisent une poignée de types de métriques pour représenter différents types de données.<br>
Accédons au navigateur d'expressions Prometheus pour notre serveur Prometheus dans un navigateur Web. Assurons-nous d'utiliser l'adresse IP publique de votre serveur Prometheus :
```
http://<PROMETHEUS_SERVER_PUBLIC_IP>:9090
```

- Interroger une plage de données sur un compteur. Notons que les valeurs ne diminuent jamais :
```
node_cpu_seconds_total[5m]
```

- Interrogeons une plage de données sur une jauge. Notons que les valeurs peuvent à la fois augmenter et diminuer :
```
node_memory_MemAvailable_bytes[5m]
```

- Interrogeons les buckets d'un histogramme :
```
prometheus_http_request_duration_seconds_bucket{handler="/metrics"}
```

- Interrogeons la métrique de comptage de l'histogramme :
```
prometheus_http_request_duration_seconds_count{handler="/metrics"}
```

- Interrogeons une métrique quantile
```
go_gc_duration_seconds{job="Linux Server"}
```

- Interrogeons la somme d'une métrique quantile :
```
go_gc_duration_seconds_sum{job="Linux Server"}
```

Interrogeons le décompte d'une métrique quantile.
```
go_gc_duration_seconds_count{job="Linux Server"}
```
# DNS pour les services et les pods

Le serveur de noms de domaine (DNS) du cluster permet aux conteneurs de découvrir les services par nom d'hôte.
<br>
Kubernetes crée des enregistrements DNS pour les services et les pods. Nous pouvons contacter les services avec des noms DNS cohérents au lieu d'adresses IP.
<br>
Kubernetes publie des informations sur les pods et les services qui sont utilisées pour programmer le DNS. Kubelet configure le DNS des pods afin que les conteneurs en cours d'exécution puissent rechercher les services par nom plutôt que par adresse IP.
<br>
Les services définis dans le cluster se voient attribuer des noms DNS. Par défaut, la liste de recherche DNS d'un pod client inclut le propre espace de noms du pod et le domaine par défaut du cluster.

#### Espaces de noms de services

Une requête DNS peut renvoyer des résultats différents en fonction de l'espace de noms du pod qui la crée. Les requêtes DNS qui ne spécifient pas d'espace de noms sont limitées à l'espace de noms du pod. Accédez aux services dans d'autres espaces de noms en le spécifiant dans la requête DNS.
<br>
Par exemple, considérez un pod dans un espace de noms **test**. Un service **data** se trouve dans l'espace de noms **prod**.
<br>
Une requête pour **data** ne renvoie aucun résultat, car elle utilise l'espace de noms **test** du pod.
<br>
Une requête pour **data.prod** renvoie le résultat attendu, car elle spécifie l'espace de noms.
<br>
Les requêtes DNS peuvent être étendues à l'aide du fichier **/etc/resolv.conf** du pod. Kubelet configure ce fichier pour chaque Pod. Par exemple, une requête portant uniquement sur le service **data** peut être étendue à **data.test.svc.cluster.local**.

#### Service

- Enregistrements A/AAAA

Les services "normaux" (pas **headless**) se voient attribuer des enregistrements DNS A et/ou AAAA, selon la famille ou les familles d'adresses IP du service, avec un nom de la forme **my-svc.my-namespace.svc.cluster-domain.example**. Cela résout l'adresse IP du cluster du service.
<br>
Les services headless (sans adresse IP de cluster) se voient également attribuer des enregistrements DNS A et/ou AAAA, avec un nom de la forme **my-svc.my-namespace.svc.cluster-domain.example**. Contrairement aux services normaux, cela se résout à l'ensemble des adresses IP de tous les pods sélectionnés par le service. On s'attend à ce que les clients consomment l'ensemble ou utilisent une sélection circulaire standard à partir de l'ensemble.

- Enregistrements SRV

Les enregistrements SRV sont créés pour les ports nommés qui font partie de services normaux ou headless. Pour chaque port nommé, l'enregistrement SRV a la forme **_port-name._port-protocol.my-svc.my-namespace.svc.cluster-domain.example**. Pour un service standard, cela se résout au numéro de port et au nom de domaine : **my-svc.my-namespace.svc.cluster-domain.example**. Pour un service headless, cela se résout en plusieurs réponses, une pour chaque pod qui sauvegarde le service, et contient le numéro de port et le nom de domaine du pod sous la forme **hostname.my-svc.my-namespace.svc.cluster-domaine.exemple**.

#### Pods

- Enregistrements A/AAAA

En général, un pod a la résolution DNS suivante :

```
pod-ip-address.my-namespace.pod.cluster-domain.example
```

Par exemple, si un pod dans l'espace de noms **default** a l'adresse IP 172.17.0.3 et que le nom de domaine de notre cluster est **cluster.local**, alors le pod a un nom DNS :

```
172-17-0-3.default.pod.cluster.local
```

Tous les pods exposés par un service disposent de la résolution DNS suivante :

```
pod-ip-address.service-name.my-namespace.svc.cluster-domain.example
```

- Champs hostname et du subdomain du pod

Actuellement, lorsqu'un pod est créé, son nom d'hôte (tel qu'observé depuis le pod) est la valeur **metadata.name** du pod.
<br>
La spécification de pod a un champ **hostname** facultatif, qui peut être utilisé pour spécifier un nom d'hôte différent. Lorsqu'il est spécifié, il a priorité sur le nom du pod pour être le nom d'hôte du pod (encore une fois, comme observé depuis l'intérieur du pod). Par exemple, étant donné un pod avec **spec.hostname** défini sur "my-host", le pod aura son nom d'hôte défini sur "my-host".
<br>
La spécification de pod comporte également un champ **subdomain** facultatif qui peut être utilisé pour indiquer que le pod fait partie d'un sous-groupe de l'espace de noms. Par exemple, un pod avec **spec.hostname** défini sur "foo" et **spec.subdomain** défini sur "bar", dans l'espace de noms "my-namespace", aura son nom d'hôte défini sur "foo" et son nom de domaine complet (FQDN ) défini sur "foo.bar.my-namespace.svc.cluster.local".
<br>
S'il existe un service headless dans le même espace de noms que le pod, avec le même nom que le sous-domaine, le serveur DNS du cluster renvoie également des enregistrements A et/ou AAAA pour le nom d'hôte complet du pod.

[https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
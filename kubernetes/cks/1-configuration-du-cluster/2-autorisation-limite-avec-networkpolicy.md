# Autoriser un accès limité avec NetworkPolicies
Les politiques de réseau ne sont pas en conflit ; ils sont additifs. Si une ou plusieurs stratégies sélectionnent un pod, le pod est limité à ce qui est autorisé par l'union des règles d'entrée/de sortie de ces stratégies.<br>
Avec une politique de refus par défaut en place, nous pouvons autoriser le trafic nécessaire avec une politique ciblée supplémentaire.<br>

Si une politique autorise un type particulier de trafic, il sera autorisé. Cela signifie que nous pouvons ajouter des politiques ciblées à côté d'une politique de refus par défaut pour autoriser le trafic nécessaire.<br>
On utilise le *podSelector* d'une stratégie pour cibler la stratégie sur des pods spécifiques en fonction de leurs libellés.<br>
On utilise les règles Ingress/Egress pour spécifier les pods, les espaces de noms ou les adresses IP pour autoriser le trafic vers et/ou depuis.<br>
Faire attention à la différence entre une règle avec plusieurs sélecteurs et plusieurs règles.<br><br>

L'exemple ci-dessous est la suite de l'exemple basé sur la restriction (1-restriction-access-avec-networkpolicy.md)<br>

- Nous créons une stratégie qui permettra aux pods avec une étiquette spécifique dans l'espace de noms *nptest* de communiquer avec le serveur Nginx.

```
vi nginx-ingress-np.yml
```

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: nginx-ingress
  namespace: nptest
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          project: test
      podSelector:
        matchLabels:
          app: client
    ports:
    - protocol: TCP
      port: 80
```

```
kubectl create -f nginx-ingress-np.yml
```

Nous attachons une étiquette à l'espace de noms pour autoriser le trafic via la règle entrante.
```
kubectl label namespace nptest project=test
```

Nous vérifions le journal du pod client.
```
kubectl logs -n nptest client
```

Nous notons que le pod client ne peut toujours pas atteindre le serveur Nginx. En effet, le trafic de sortie est toujours bloqué pour le pod client.
<br>

- Nous créons une NetworkPolicy pour autoriser le trafic de sortie pour le pod client.
```
vi client-egress-np.yml
```

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: client-egress
  namespace: nptest
spec:
  podSelector:
    matchLabels:
      app: client
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          project: test
      podSelector:
        matchLabels:
          app: nginx
    ports:
    - protocol: TCP
      port: 80
```

```
kubectl create -f client-egress-np.yml
```

Nous vérifions le journal du pod client. Il devrait pouvoir accéder au serveur Nginx maintenant.

```
kubectl logs -n nptest client
```
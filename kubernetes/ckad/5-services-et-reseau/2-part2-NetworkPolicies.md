# Partie 2 : contrôler l'accès au réseau avec NetworkPolicies
Même si une stratégie réseau (*NetworkPolicy*) autorise le trafic sortant du pod source, les stratégies réseau (*NetworkPolicy*) peuvent toujours bloquer le même trafic lorsqu'il entre dans le pod de destination.<br>

- Créons maintenant une stratégie réseau (*NetworkPolicy*) pour autoriser le trafic provenant du pod client.
```
vi np-test-client-allow.yml
```

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-test-client-allow
  namespace: np-test-a
spec:
  podSelector:
    matchLabels:
      app: np-test-server
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          team: bteam
      podSelector:
        matchLabels:
          app: np-test-client
    ports:
    - protocol: TCP
      port: 80
```

```
kubectl apply -f np-test-client-allow.yml
```

Vérifions à nouveau le journal du pod client. Le trafic devrait être autorisé maintenant.
```
kubectl logs client-pod -n np-test-b
```

- Créons une configuration pour restreindre le trafic sortant pour le pod client<br>
créons une stratégie de refus de sortie par défaut pour l'espace de noms np-test-b.
```
vi np-test-b-default-deny-egress.yml
```

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-test-b-default-deny-egress
  namespace: np-test-b
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

```
kubectl apply -f np-test-b-default-deny-egress.yml
```

Vérifions le journal du pod client. Le trafic devrait maintenant être refusé.
```
kubectl logs client-pod -n np-test-b
```

- créons une stratégie pour autoriser le trafic sortant du pod client. Cette fois, nous autoriserons le trafic vers n'importe quel pod dans l'espace de noms np-test-a.
```
vi np-test-client-allow-egress.yml
```

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-test-client-allow-egress
  namespace: np-test-b
spec:
  podSelector:
    matchLabels:
      app: np-test-client
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          team: ateam
    ports:
    - protocol: TCP
      port: 80
```

```
kubectl apply -f np-test-client-allow-egress.yml
```

Vérifions le journal du pod client. Le trafic devrait être à nouveau autorisé.
```
kubectl logs client-pod -n np-test-b
```
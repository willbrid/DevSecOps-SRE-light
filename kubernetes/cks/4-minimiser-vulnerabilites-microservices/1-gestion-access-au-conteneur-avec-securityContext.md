# Gestion de l'accès au conteneur avec des contextes de sécurité

Un contexte de sécurité est une partie de la spécification du pod ou du conteneur qui nous permet de fournir des paramètres de sécurité et de contrôle d'accès spéciaux au niveau du pod ou du conteneur. **securityContext** offre une variété de paramètres liés à la sécurité et au contrôle d'accès.<br>

- **spec.securityContext** : configure le contexte de sécurité au niveau du pod. Ces paramètres s'appliquent à tous les conteneurs du pod.
- **spec.containers[].securityContext** : Définit les paramètres du contexte de sécurité au niveau du conteneur. Ces paramètres s'appliquent aux conteneurs individuels du pod

créons un pod qui inclut la configuration de **securityContext**

```
vi security-context-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: security-context-pod
spec:
  securityContext:
    runAsUser: 1000
  containers:
  - name: busybox
    image: busybox
    command: [ "sh", "-c", "sleep 3600" ]
    securityContext:
      allowPrivilegeEscalation: false
```

```
kubectl create -f security-context-pod.yml
```

Vérifions l'état du pod :
```
kubectl get pods
```
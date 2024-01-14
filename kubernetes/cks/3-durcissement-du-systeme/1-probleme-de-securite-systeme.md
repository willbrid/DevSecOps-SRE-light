# Comprendre les problèmes de sécurité du système d'exploitation hôte
Protégeons notre hôte k8s des conteneurs qui y sont exécutés !<br>

Les conteneurs utilisent des espaces de noms de système d'exploitation (différents d'un espace de noms k8s) pour s'isoler des autres conteneurs et de l'hôte.<br>

Nous pouvons configurer les pods pour utiliser un espace de noms d'hôte à la place, mais cela comporte des risques de sécurité.<br>

Exemple :
```
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  hostIPC: true
  hostNetwork: true
  hostPID: true
  containers:
  - name: nginx
    image: nginx
```

- hostIPC - Si défini sur true, les conteneurs utiliseront l'espace de noms de communication inter-processus (IPC) de l'hôte.
- hostNetwork - Si défini sur true, les conteneurs utiliseront l'espace de noms réseau de l'hôte.
- hostPID - Si défini sur true, les conteneurs utiliseront l'espace de noms de l'ID de processus (PID) de l'hôte.
- Toutes ces valeurs par défaut sont false<br>

Utilisons des paramètres tels que hostIPC, hostNetwork et hostPID uniquement lorsque cela est absolument nécessaire !<br>

Le mode privilégié permet aux conteneurs d'accéder aux ressources et fonctionnalités au niveau de l'hôte, un peu comme un processus non conteneur s'exécutant directement sur l'hôte.

Exemple :
```
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      privileged: true
```

- *containers[].securityContext.privileged* - Si défini sur true, le conteneur s'exécutera en mode privilégié.<br>
- Le mode privilégié est défini par défaut sur false.<br>

N'utilisons le mode privilégié qu'en cas d'absolue nécessité !
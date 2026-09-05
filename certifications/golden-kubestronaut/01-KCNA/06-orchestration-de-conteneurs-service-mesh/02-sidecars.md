# Les Sidecars

### Le concept de sidecar dans Kubernetes

- Dans Kubernetes, les conteneurs sont **encapsulés dans des Pods**, et chaque Pod peut contenir **un ou plusieurs conteneurs**.
- Les **conteneurs additionnels** qui **supportent le conteneur principal** sont appelés **sidecars** (ou conteneurs sidecar).
- Ils **partagent le même volume et le même network** que le conteneur principal, **mais** ont des **responsabilités différentes**.

### Le rôle des sidecars

Les sidecars sont responsables de fonctionnalités **annexes**, de **taille relativement réduite**, telles que :
- le **log shipping** (envoi des logs) ;
- le **monitoring** ;
- le **file loading** (chargement de fichiers) ;
- le **proxying** (dans le cas des service meshes).

Pendant ce temps, le **conteneur principal** gère la **business logic** — c'est-à-dire le **code principal de l'application**, la fonctionnalité qui apporte la **valeur** à l'application.

> **Principe clé** : les sidecars aident à **isoler** ces fonctionnalités annexes de la **business logic**. Le conteneur principal reste dédié à la logique métier, tandis que les tâches secondaires sont déléguées aux sidecars.

### Exemple concret : un sidecar de log shipping

Voici un fichier de définition de Pod simple avec un sidecar :
- Dans la section `containers`, on a **d'abord** le conteneur principal **NGINX** (image NGINX) ;
- **Ensuite**, un **deuxième conteneur** créé avec l'image **fluentbit**, qui est le **sidecar** chargé d'**envoyer les logs** de l'application principale vers un **serveur central**.

#### Manifest d'exemple

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-logging-sidecar
  labels:
    app: my-app
spec:
  containers:
    # conteneur principal : la business logic
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx

    # Sidecar : envoi (shipping) des logs vers un serveur central
    - name: fluentbit
      image: fluent/fluent-bit
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx

  # Volume partagé entre le conteneur principal et le sidecar
  volumes:
    - name: shared-logs
      emptyDir: {}
```

**Décomposition** :
- Le conteneur **nginx** (principal) écrit ses logs dans `/var/log/nginx` ;
- Le conteneur **fluentbit** (sidecar) lit ces mêmes logs via le **volume partagé** (`shared-logs`) et les expédie vers un serveur central ;
- Les deux conteneurs **partagent le même volume et le même network** (ils peuvent communiquer via `localhost`), mais ont des **responsabilités distinctes**.

### À retenir

- Un **sidecar** = conteneur **secondaire** dans un Pod, qui **supporte** le conteneur principal.
- Les conteneurs d'un Pod **partagent volume et network**, mais ont des **rôles différents**.
- Le **conteneur principal** = la **business logic** (le code qui apporte la valeur) ; les **sidecars** = tâches annexes (**log shipping, monitoring, file loading, proxying**).
- Objectif : **isoler** les fonctionnalités annexes de la logique métier.
- **Exemple typique** : conteneur principal **NGINX** + sidecar **Fluentbit** pour l'envoi des logs (via un volume partagé).
- Les sidecars sont un **prérequis** pour comprendre les **service meshes** comme **Istio**, où le sidecar joue le rôle de **proxy**.

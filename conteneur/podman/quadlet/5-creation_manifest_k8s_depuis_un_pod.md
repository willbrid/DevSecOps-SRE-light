# Création d'un fichier manifest pour kubernetes depuis un pod

Nous allons créer un fichier manifeste déployable sur Kubernetes à partir de notre pod **nextcloudapp** précédemment créé. Pour cela, nous utilisons la commande **podman generate kube** comme suit :

```
podman generate kube nextcloudapp -f nextcloudapp.yaml
```

Cela générera un fichier **nextcloudapp.yaml** dont le contenu contiendra la définition d'un pod sur kubernetes.

```
# Save the output of this file and use kubectl create -f to import
# it into Kubernetes.
#
# Created with podman-5.2.2
apiVersion: v1
kind: Pod
metadata:
  annotations:
    bind-mount-options: /var/lib/nextcloud/apps:z
    io.kubernetes.cri-o.SandboxID/mariadb: f9a71035deda21dc6b96fbf878c8948d05a20bbfdc98e6a32b8b3ab9402c6598
    io.kubernetes.cri-o.SandboxID/nextcloud: f9a71035deda21dc6b96fbf878c8948d05a20bbfdc98e6a32b8b3ab9402c6598
  creationTimestamp: "2025-03-17T19:58:37Z"
  labels:
    app: nextcloudapp
  name: nextcloudapp
spec:
  containers:
  - args:
    - mariadbd
    env:
    - name: MARIADB_USER
      value: nextcloud
    image: docker.io/library/mariadb:11.7.2
    name: mariadb
    ports:
    - containerPort: 80
      hostPort: 8080
    volumeMounts:
    - mountPath: /var/lib/mysql
      name: var-lib-mariadb-host-0
  - args:
    - apache2-foreground
    env:
    - name: NEXTCLOUD_ADMIN_USER
      value: admin
    - name: MYSQL_USER
      value: nextcloud
    - name: MYSQL_HOST
      value: mariadb
    - name: MYSQL_DATABASE
      value: nextcloud
    image: docker.io/library/nextcloud:31.0.1-apache
    name: nextcloud
    volumeMounts:
    - mountPath: /var/www/html/config
      name: var-lib-nextcloud-config-host-0
    - mountPath: /var/www/html/data
      name: var-lib-nextcloud-data-host-1
    - mountPath: /var/www/html
      name: var-lib-nextcloud-host-2
    - mountPath: /var/www/html/custom_apps
      name: var-lib-nextcloud-apps-host-3
  volumes:
  - hostPath:
      path: /var/lib/nextcloud/config
      type: Directory
    name: var-lib-nextcloud-config-host-0
  - hostPath:
      path: /var/lib/nextcloud/data
      type: Directory
    name: var-lib-nextcloud-data-host-1
  - hostPath:
      path: /var/lib/nextcloud
      type: Directory
    name: var-lib-nextcloud-host-2
  - hostPath:
      path: /var/lib/nextcloud/apps
      type: Directory
    name: var-lib-nextcloud-apps-host-3
  - hostPath:
      path: /var/lib/mariadb
      type: Directory
    name: var-lib-mariadb-host-0
```
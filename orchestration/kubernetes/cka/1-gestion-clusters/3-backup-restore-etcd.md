# Sauvegarde et restauration des données du cluster Etcd

## Sauvegarde des données du cluster etcd
Si ce n'est pas encore fait alors vous devez installer le package etcd-client.
```
sudo apt install etcd-client
```

**- créer un dossier etcd-certs et copier les certificats de l'etcd**<br>
Pour savoir comment s'authentifier à l'etcd afin de procéder à la sauvegarde, nous pouvons vérifier comment le composant *kube-apiserver* s'authentifie à l'etcd. Sur le noeud master, nous faisons :
```
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep etcd
```

Nous préparons ainsi les paramètres d'authentification à l'etcd :
```
cd $HOME

mkdir etcd-certs

sudo cp /etc/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/server.crt /etc/kubernetes/pki/etcd/server.key etcd-certs/

sudo chown -R $(id -u):$(id -g) etcd-certs/
```

**- sauvegarder les données de l'etcd**
```
ETCDCTL_API=3 etcdctl snapshot save $HOME/etcd_backup.db \
--endpoints=https://192.168.43.251:2379 \
--cacert=$HOME/etcd-certs/ca.crt \
--cert=$HOME/etcd-certs/server.crt \
--key=$HOME/etcd-certs/server.key
```

NB: L'option *--endpoints* est facultative si nous nous situons déjà sur le noeud master.

## Restauration des données du cluster etcd
Nous stoppons tous les composants du noeud master :
```
cd /etc/kubernetes/manifests/
mv * ..
```

Ensuite nous restaurons la sauvegarde dans un répertoire spécifique :
```
sudo ETCDCTL_API=3 etcdctl snapshot restore $HOME/etcd_backup.db \
--endpoints=https://192.168.43.251:2379 \
--cacert=$HOME/etcd-certs/ca.crt \
--cert=$HOME/etcd-certs/server.crt \
--key=$HOME/etcd-certs/server.key \
--data-dir /var/lib/etcd-backup
```

L'option *--data-dir* permet de préciser le répertoire de restauration.<br> Les fichiers restaurés sont situés dans le nouveau dossier */var/lib/etcd-backup*, maintenant nous devons dire à l'etcd d'utiliser ce répertoire en modifiant l'attribut *path* du volume *hostPath* des données de l'etcd :
```
vi /etc/kubernetes/etcd.yaml
```

```
...
spec:
...
  volumes:
  ...
  - hostPath:
      path: /var/lib/etcd-backup  # mettre à jour le path
      type: DirectoryOrCreate
    name: etcd-data
...
```

Maintenant, nous déplaçons à nouveau tous les fichiers yaml des composants du noeud master dans le répertoire manifest. Nous lui donnons un peu de temps (jusqu'à plusieurs minutes) pour qu'etcd redémarre et que le serveur API soit à nouveau accessible :

```
mv ../*.yaml .
```

NB: Toutes ces étapes de restauration sont faites depuis le répertoire */etc/kubernetes/manifests/*. <br>
L'adresse **192.168.43.251** est celle du noeud master.
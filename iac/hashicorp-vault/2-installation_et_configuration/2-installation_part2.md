# Configuration de Consul [PART2]

1. **Configuration d'un service agent Consul**

Nous créeons d'abord le repertoire de configuration de **consul** :

```
sudo mkdir -p /etc/consul.d/
```

S'il existe déjà, alors nous pouvons ignorer cette étape.

Nous configurons les adresses d'accessibilité l'interface ui

```
sudo vim /etc/consul.d/ui.json
```

```
{
  "addresses": {
    "http": "0.0.0.0"
  }
} 
```

Nous créeons le service **consul.service**

```
sudo vim /etc/systemd/system/consul.service
```

```
[Unit]
Description=Consul
Documentation=https://www.consul.io/

[Service]
ExecStart=/usr/bin/consul agent -server -ui -data-dir=/tmp/consul -bootstrap-expect=1 -node=vault -bind=<ADDRESS_IP_SERVER> -config-dir=/etc/consul.d/
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

L'argument **agent** permet de configurer un agent consul avec ses options :
- l'option **-server** permet de basculer l'**agent** en mode serveur.
- l'option **-ui** permet d'activer le serveur Web statique intégré.
- l'option **-data-dir** permet de préciser le chemin d'accès à un répertoire de données pour stocker l'état de l'**agent**.
- l'option **--bootstrap-expect=1** permet de définir le serveur pour qu'il s'attende au mode d'amorçage.
- l'option **-node** permet de donner le nom d'un nœud. Il doit être unique dans le cluster.
- l'option **-bind** permet de définir l'adresse de liaison pour la communication dans le cluster.
- l'option **-config-dir** permet de préciser le chemin d'accès à un répertoire à partir duquel lire les fichiers de configuration. Cela lira tous les fichiers se terminant par **.json** comme configuration dans ce répertoire par ordre alphabétique.

```
sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul
```

Nous pouvons vérifier le statut de ce service :

```
sudo systemctl status consul
```

Nous pouvons aussi consulter les logs de **consul** via **journalctl**

```
sudo journalctl -f -u consul
```
# Configuration de Consul [PART2]

1. **Elements préconfigurés lors de l'installation de consul**

L'installation de **consul** sur le serveur **vault-server** créera :

- son repertoire de configuration **/etc/consul.d**
- son fichier de configuration **/etc/consul.d/consul.hcl**
- son fichier de configuration d'accès ui **/etc/consul.d/ui.json**
- son fichier service systemd  **/usr/lib/systemd/system/consul.service**
- son répertoire de données **/opt/consul**

2. **Configuration d'un serveur agent Consul**

Effectuons le backup du fichier de configuration par défaut

```
sudo mv /etc/consul.d/consul.hcl /etc/consul.d/consul.hcl.backup
```

Editons un nouveau fichier de configuration

```
sudo vi /etc/consul.d/consul.hcl
```

```
node_name = "vault-server"
server = true
bind_addr = "192.168.56.70"
advertise_addr = "192.168.56.70"
client_addr = "0.0.0.0"
bootstrap_expect = 1
bootstrap = false
ui_config {
  enabled = true
}
datacenter = "willbrid"
data_dir = "/opt/consul"
log_level = "INFO"
retry_join = ["192.168.56.70"]
```

Les directives du fichier de configuration :
- la directive **node_name** permet de donner le nom d'un nœud consul.
- la directive **server** permet d'activer consul en mode serveur.
- la directive **bind_addr** permet de configurer l'adresse IP d'interface réseau d'écoute du service consul.
- la directive **advertise_addr** permet de configurer l'adresse IP d'interface réseau du service consul pour les requêtes client.
- la directive **client_addr** permet de définir les IP clients à autoriser.
- la directive **bootstrap_expect** permet de configurer le nombre de noeuds du cluster consul. Dans notre cas nous avons un seul noeud.
- la directive **bootstrap** permet de désativer le mode **bootstrap** du noeud.
- la directive **ui_config** permet d'activer le serveur Web statique intégré.
- la directive **datacenter** permet de préciser le nom du datacenter dans lequel l'agent s'exécute.
- la directive **data-dir** permet de préciser le chemin d'accès à un répertoire de données pour stocker l'état de l'**agent**.
- la directive **log_level** permet de définir le niveau de logs de consul.
- la directive **retry_join** permet d'indiquer les noeuds du cluster dont le service consul peut joindre. Dans notre cas, il s'agit du même noeud.

Démarrons et activons **consul**

```
sudo systemctl enable --now consul
```

Nous pouvons vérifier le statut de ce service :

```
sudo systemctl status consul
```

Nous pouvons aussi consulter les logs de **consul** via **journalctl**

```
sudo journalctl -f -u consul
```
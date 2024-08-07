# Création de son propre service : exemple service emacs.service

## Installer le package emacs
```
yum install emacs -y
```

## Créer le fichier emacs.service 
**- Accéder au répertoire /usr/lib/systemd/system**
```
cd /usr/lib/systemd/system
vi emacs.service
```

**- Mettre le contenu**
```
[Unit]
Description=Emacs

[Service]
Type=forking
ExecStart=/usr/bin/emacs --daemon
ExecStop=/usr/bin/emacsclient --eval "(kill-emacs)"
Restart=always

[Install]
WantedBy=default.target
```

--- La directive **WantedBy** représente la cible qui va gérer le service : la cible default.target .<br>
--- Le type forking signifie que le processus démarré avec ExecStart génère un processus enfant qui devient le processus principal du service. Le processus parent se termine lorsque le démarrage est terminé.

**- Recharger la configuration du gestionnaire systemd**
```
systemctl daemon-reload
```

**- Consulter le statut du service emacs.service**
```
systemctl status emacs
```
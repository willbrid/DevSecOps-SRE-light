# Configurer les services réseau pour qu'ils démarrent automatiquement au démarrage

Les systèmes Linux peuvent remplir de nombreux rôles, des serveurs Web aux serveurs de temps réseau. En tant qu'administrateur système, nous devons être capable de contrôler les services réseau sur nos systèmes. 

Nous utiliserons la commande **systemctl** pour arrêter/démarrer, vérifier l'état ou activer/désactiver un service réseau.

Par exemple avec le service **telnet**

- Vérification du statut du service **telnet**

```
systemctl status telnet
```

- Activation du démarrage automatique du service **telnet** au démarrage du système

```
systemctl enable telnet
```

- Arrêt du service **telnet**

```
systemctl stop telnet
```

- Démarrage du service **telnet**

```
systemctl start telnet
```

- Redémarrage du service **telnet**

```
systemctl restart telnet
```
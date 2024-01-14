# Présentation et utilisation du moteur de secrets HashiCorp Vault

Lorsqu'un serveur Vault est démarré, il démarre dans un état scellé. Dans cet état, Vault est configuré pour savoir où et comment accéder au stockage physique, mais ne sait pas comment le déchiffrer.
<br>
Le descellement est le processus d'obtention de la clé racine en clair nécessaire pour lire la clé de déchiffrement afin de déchiffrer les données, permettant l'accès au Vault.
<br>
Avant le descellement, presque aucune opération n'est possible avec Vault. Par exemple, l'authentification, la gestion des tables de montage, etc. ne sont pas possibles. Les seules opérations possibles sont de desceller le Vault et de vérifier l'état du scellé.
<br>
Les données stockées par Vault sont cryptées. Vault a besoin de la clé de chiffrement pour déchiffrer les données. La clé de chiffrement est également stockée avec les données (dans le trousseau de clés), mais chiffrée avec une autre clé de chiffrement appelée clé racine.
<br>
Par conséquent, pour déchiffrer les données, Vault doit déchiffrer la clé de chiffrement qui nécessite la clé racine. Le descellement est le processus d'accès à cette clé racine. La clé racine est stockée avec toutes les autres données de Vault, mais elle est chiffrée par un autre mécanisme : la clé de descellement.
<br>
Pour récapituler : la plupart des données de Vault sont chiffrées à l'aide de la clé de chiffrement du trousseau de clés ; le trousseau de clés est chiffré par la clé racine ; et la clé racine est chiffrée par la clé de descellement.

- Créeons un script bash qui descelle les clés et se logue via la clé racine.

```
vi unsealKeys.sh
```

```
#!/bin/bash

vault operator unseal BJeEhkVMjR39RGo4C2X6gQyMew5ufDcalp8F3UWLq9jA
vault operator unseal Kz6UT4caGE5IexpwuZWuf9MSsQRdEuAEpIADEFlWMuZl
vault operator unseal 6c6cY920kRvpVlAJ9iQxoL7yAD8CmFyg+F/K5y8I8lBj
vault login hvs.oYcFoZDwF595Zi5hUHGdemO9
```

```
chmod +x unsealKeys.sh
./unsealKeys.sh
```

- Vérifions le statut du service vault

```
systemctl status vault
```

- Vérifions l'état du sceau et HA

```
vault status
```

Nous vérifions si la clé **Sealed** est à **false**.

- Listons les moteurs de secrets activés

```
vault secrets list
```

- Activons un autre moteur de secret **kv**

```
vault secrets enable -path=my_secrets-kv kv
```

Le template de la valeur du path est **nom-moteur**. <br>
La valeur **kv** à la fin représente le type de moteur de secret. <br>
Si nous listons à nouveau nos moteurs de secrets activés, nous verrons le nouveau moteur activé.

```
vault secrets list
```

- Désactivons notre nouveau moteur de secret activé

```
vault secrets disable my_secrets-kv
```

Si nous listons à nouveau nos moteurs de secrets activés, le moteur kv **my_secrets-kv** ne sera plus présent.
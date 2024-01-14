# Écrire, obtenir et supprimer un secret

- Listons l'ensemble de nos moteurs de secrets

```
vault secrets list
```

- Activons un nouveau moteur de secret **kv** nommé **datacenter1**

```
vault secrets enable -path=datacenter1 kv
```

Pour vérifier que notre nouveau moteur kv est bien activé, nous pouvons lister à nouveau nos moteurs de secrets

```
vault secrets list
```

- Créeons un secret de **datacenter1** au niveau du path **serveur1** avec pour clé-valeur : **user1-password1**

```
vault kv put datacenter1/serveur1 user1=password1
```

- Affichons les détails du secret nouvellement créé

```
vault kv get datacenter1/serveur1
```

- Mettons à jour notre secret de **datacenter1** au niveau du path **serveur1** 

```
vault kv put datacenter1/serveur1 user2=password2
```

```
vault kv get datacenter1/serveur1
```

- Supprimons notre secret de **datacenter1** au niveau du path **serveur1**

```
vault kv delete datacenter1/serveur1
```

- Désactivons le moteur de secret **datacenter1**

```
vault secrets disable datacenter1
```
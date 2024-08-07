# Rechercher des fichiers [Part2]

### Commande which

Renvoie l'emplacement d'une commande en fonction des paramètres PATH.

```
which python
```

```
which nano
```

### Commande whereis

- Renvoie l'emplacement du fichier binaire, du ou des fichiers source et des pages de manuel.
- Retourne plusieurs versions d'un fichier si elles existent.

```
whereis python
```

```
whereis python | tr " " '\n'
```

### Commande type

- Renvoie des informations sur le type de commande.
- Les détails sont basés sur la relation entre la commande et la configuration du shell.

```
type python
```

```
type nano
```

```
type ls
```

```
type -a ls
```

Avec l'option **-a**, elle permet d'afficher tous les emplacements contenant un exécutable nommé **ls**; y compris les alias, les commandes intégrées et les fonctions si et seulement si l'option **-p** n'est pas utilisée.
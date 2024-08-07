# Utiliser la documentation Linux

## Les page de manuel

Ce sont la principale source de documentation Linux (**man pages** en abrégé). Elles fournissent des informations sur les programmes, les utilitaires, les fichiers de configuration,... Les pages de manuel sont divisées en 9 chapitres/sections, classés de 1 à 9.

```
man [options] topic
```

**Exemple avec les commandes ls et printf** 

- afficher le contenu des pages de manuel de la commande **ls**

```
man ls
```

- lister toutes les pages de manuel de la commande **ls**

```
man -f ls
```

ou

```
whatis ls
```

- lister toutes les pages de manuel qui ont un mot clés **list** dans leur description

```
man -k list
```

ou

```
apropos list
```

- afficher la page de manuel numéro 3 de la commande **printf**

```
man 3 printf
```

## Système d'information GNU

C'est le format de documentation standard pour le projet GNU. Il ressemble aux pages de manuel mais utilise des liens pour se connecter aux rubriques. Les rubriques d'une page d'informations sont appelées **nœuds**. Les nœuds peuvent contenir des menus et des sous-rubriques/éléments liés.

```
info [options] topic
```

```
info
```

La commande **info** sans les options permet de nous amèner dans un index des sujets disponibles : il s'agit du menu principal d'informations, également connu sous le nom de nœud de répertoire. Elle va également nous donner quelques commandes utiles pour naviguer dans ces nœuds et dans l'arborescence d'informations.

```
info ls
```

Cela nous a amené directement à la page d'information de la commande **ls** et nous pouvons faire défiler la page.

## La command help et l'option --help

La commande **help** affiche un synopsis des commandes intégrées les plus courantes. Ces commandes sont fournies avec le shell que les utilisateurs utilisent pour interagir avec le système. La plupart des commandes ont une courte description accessible avec l'option **--help** ou **-h**.
<br>

```
help
```

si nous exécutons simplement la commande **help** par elle-même, elle nous montrera une liste de commandes shell intégrées (en interne) que nous pouvons utiliser.
Donc, si nous faisons défiler vers le haut, nous allons voir que cela est basé sur la version 5.0.17 (sur ubuntu 20.04) de GNU bash. Cela va nous donner des informations sur ces différents utilitaires, et nous pouvons voir que nous obtenons un raccourci sur la façon d'utiliser ces commandes dans la ligne de commande.

```
help cd
```

```
help ls
```

En appliquant la commande **help** sur **cd**, cela nous donnera plus d'informations sur cette commande.
<br>
En appliquant la commande **help** sur **ls**, nous allons voir qu'il n'y a pas de rubriques d'aide correspondant à **ls**, et c'est parce que ce n'est pas l'une de ces commandes shell intégrées.

```
ls --help
cd --help
```

Une commande spécifique (**ls**, **cd**) avec l'option **--help** permet d'obtenir un résumé rapide des options disponibles.
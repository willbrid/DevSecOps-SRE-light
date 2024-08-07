# Part1 : Afficher le texte et rediriger l'entrée/la sortie

## Définition

- **more** : filtre de lecture de fichiers pour la visualisation crt. Fournit un filtre pour parcourir le texte un écran à la fois.

- **less** : un utilitaire de visualisation de texte similaire à **more** mais offrant plus de fonctionnalités (i.e : permet un mouvement vers l'arrière)

- **head** : afficher la première partie des fichiers. L'option **-n** spécifie le nombre de lignes à afficher plutôt que la valeur par défaut de 10.

- **tail** : afficher la dernière partie des fichiers. L'option **-n** spécifie le nombre de lignes à afficher plutôt que la valeur par défaut de 10. L'option **-f** est utilisée pour ajouter des données au fur et à mesure que le fichier grandit.

- **grep** : afficher des lignes correspondant à un motif. Les options notables sont **-i** qui ignore la casse et **-R** qui lit les fichiers sous chaque répertoire de manière récursive.

- **sort** : trier les lignes des fichiers texte

- **descripteurs de fichiers standard** : les descripteurs de fichiers par défaut ouverts au démarrage d'un programme <br>
--- 0 : le flux d'entrée standard (**stdin**) <br>
--- 1 : le flux de sortie standard (**stdout**) <br>
--- 2 : le flux d'erreur standard (**stderr**) <br>

- **redirection entrée/sortie** : 

--- redirection de sortie : **>** et **>>** <br>
--- redirection d'entrée : **<** et **<<** <br>
--- redirection d'erreur : **2>** <br>
--- redirection de sortie et d'erreur : **2>&1** et **&>** <br>

- **redirection de pipeline** : pipeline ou pipe (**|**) permet à la sortie d'une commande de servir d'entrée à une autre.

## Pratiques

- avec la commande **more**, ouvrons le fichier de log **/var/log/messages**

```
more /var/log/messages
```

Une fois le fichier ouvert, nous pouvons naviguer **ligne par ligne** avec la touche **entrée** du clavier et **page par page** avec la touche **espace** du clavier.

- avec la commande **less**, ouvrons le fichier de log **/var/log/messages**

```
less /var/log/messages
```

Une fois le fichier ouvert, nous pouvons naviguer **ligne par ligne** vers le haut avec la touche **flèche pointant vers le haut** du clavier et vers le bas avec la touche **flèche pointant vers le bas** du clavier. Nous pouvons aussi naviguer **page par page** avec la touche **espace** du clavier. **less** offre aussi la possibilité de faire les recherches en saisissant, avec le fichier ouvert, le motif **/mot_à_rechercher** .

- avec la commande **head**, affichons les 10 et 20 premières lignes du fichier **/var/log/messages**.

```
head /var/log/messages
head -n 20 /var/log/messages
```

- avec la commande **tail**, affichons les 10 et 2 dernières lignes du fichier **/var/log/messages**.

```
tail /var/log/messages
tail -n 2 /var/log/messages
```

- avec la commande **tail**, suivons l'évolution du fichier **/var/log/messages**

```
tail -f /var/log/messages
```

- avec la commande **grep**, recherchons l'utilisateur **cloud_user** dans le fichier **/var/log/messages**

```
grep cloud_user /var/log/messages
```

- avec la commande **grep**, recherchons de manière récursive l'utilisateur **cloud_user** dans le repertoire **/var/log/**

```
grep -R cloud_user /var/log
```
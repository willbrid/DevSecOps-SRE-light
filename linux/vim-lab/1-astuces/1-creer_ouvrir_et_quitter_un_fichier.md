# Créer, ouvrir et quitter un fichier

Avant de commencer nous créons notre répertoire de travail **vim-lab** et nous y accédons

```
mkdir ~/vim-tp
cd ~/vim-tp
```

#### Créer et enregistrer un nouveau fichier avec Vim

Nous créons un fichier **greating.txt** avec **vim**, puis y mettre le contenu :

```
Bonjour tout le monde ! comment allez-vous ?
```

1. Ouvrons l'éditeur **vim** avec la commande

```
vim
```

Cela ouvrira vim en **mode commande**

2. Appuyons sur la touche **i** et notons que le **coin inférieur gauche** indique que nous sommes en mode ***Insertion**, puis saisissons notre texte :

```
Bonjour tout le monde ! comment allez-vous ?
```

3. Lorsque nous avons terminé d'entrer le texte, utilisons la touche **ESC** pour revenir au **mode commande**

4. Ecrivons le nom du nouveau fichier à créer précédé des touches **:w**, puis appuyons sur la touche **Entrée**

```
:w greating.txt
```

5. Quittons **vim** avec les touches **:q**

**NB** : Nous pouvons aussi spécifier un nom de fichier dès le départ, comme à la prémière étape  

```
vim greating.txt
```

puis enregistrer et quitter en sautant les étapes 4 et 5 avec les touches **:wq** .


#### Ouverture d'un fichier existant, sortie sans modifications

1. Ouvrons le fichier **/etc/hosts** en utilisateur non root

```
vim /etc/hosts
```

2. Appuyons sur la touche **i** pour passer en mode **Insertion**, ce qui entraînera le message d'erreur suivant

```
W10 : Alerte : Modification d'un fichier en lecture seule
```

3. Utilisons la touche **ESC** pour revenir au mode de commande et la touche **u** pour nous assurer qu'aucune modification n'a été apportée, indiquée par le message suivant sur la ligne d'état

```
Déjà à la modification la plus ancienne
```

4. Quittons **vim** en annulant toute modification avec les touches

```
:q!
```

La touche **!** a été ajoutée pour annuler les modifications effectuées sur le fichier.
# Apporter une modification simple à un fichier

1. Créeons un fichier **vimdoc1.txt** 

```
vim vimdoc1.txt
```

```
*help.txt* For Vim version 8.1. Last change: 2019 Jul 21
                   VIM - main help file
```

Enregistrons et quittons avec les touches **:wq**

2. Ouvrons le fichier **vimdoc1.txt**

3. Naviguons dans le fichier **vimdoc1.txt** jusqu'au texte

```
VIM - main help file
```

4. Changeons le mot **VIM** en **Vim** en plaçant le curseur sur la lettre **I** et en appuyant sur les touches **cw** (cette combinaison de touches supprimera toutes les lettres depuis la position curseur jusqu'à la fin du mot et nous positionnons en mode **Insertion**) pour changer le reste du mot en **im**

5. Appuyons ensuite sur la touche **ESC** pour quitter le mode **Insertion**

6. Accédons à la lettre **m** dans **main** et utilisons le caractère **~** pour le changer en **M**. Ce caractère **~** en mode commande permet de switcher une lettre en mode majuscule et minuscule.

7. Ensuite, faisons de même pour la lettre **h** dans le mot **help** et la lettre **f** dans le mot **file**

8. Appuyons ensuite sur la touche **ESC** pour quitter le mode **Insertion**

9. Enregistrons et quittons avec les touches **:wq**
# Modification d'un fichier système

Nous allons éditer le fichier système **/etc/hosts** avec **vim**.

1. Ouvrons le fichier **/etc/hosts** en mode superutilisateur

```
sudo -i vim /etc/hosts
```

2. Accédons en utilisant le curseur au début de la ligne ci-dessous

```
127.0.0.1	localhost
```

3. Appuyons la touche **A** qui nous passe en mode **Insertion** et nous amène à la fin de la ligne

4. Ajoutons un espace puis écrivons le mot **welldone**

```
127.0.0.1	localhost welldone
```

5. Enregistrons et quittons le fichier en appuyant d'abord sur la touche **ESC** puis sur les touches **ZZ**

6. Vérifions que le changement a été effectué

```
grep welldone /etc/hosts
```

7. Confirmons le changement avec la commande **ping**

```
ping -c 4 welldone
```
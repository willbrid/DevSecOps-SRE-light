# Gérer les profils d'environnement à l'échelle du système

Les utilisateurs s'appuient sur les administrateurs système Linux pour garantir que les applications sont correctement configurées. Nous pouvons utiliser des variables d'environnement pour faciliter la gestion. La configuration des applications sous Linux se fait généralement avec des variables d'environnement.

### Types de variables

- **Locale (Local)**

Variables disponibles pour la session en cours uniquement

- **Utilisateur (User)**

Variables définies uniquement pour un utilisateur spécifique

- **Système (System)**

Variables disponibles pour tous les utilisateurs du système

### Affichage des variables

- Afficher toutes les variables définies

```
env
```

- Afficher toutes les variables spécifiques

```
printenv
```

```
printenv VAR
```

Exemple

```
printenv SHELL
```

- Afficher des variables spécifiques

```
echo $VAR
```

Exemple

```
echo $SHELL
```

### Définition des variables

- **Locale (Local)**

```
export VAR='information'
```

```
export VAR="$VAR:newinformation"
```

Exemple

```
export MY_VAR="cool"
echo $MY_VAR
```

```
export MY_VAR="$MY_VAR super"
echo $MY_VAR
```

supprimer une variable

```
unset MY_VAR
echo $MY_VAR
```

- **Utilisateur (User)**

Ajouter **export VAR='information'** à l'un des fichiers suivants : <br>
--- **~/.bashrc** <br>
--- **~/.bash_profile** <br>
--- **~/.bash_login** <br>
--- **~/.profile**

Exemple

```
vi ~/.bashrc
```

```
# A la fin du fichier
export NEW_VAR="super cool"
```

Pour appliquer le changement : <br>
--- soit on se déconnecte et se reconnecte du serveur <br>
--- soit on exécute la commande

```
source ~/.bashrc
```

```
echo $NEW_VAR
printenv NEW_VAR
```

Pour supprimer cette variable, **NEW_VAR**, on édite le fichier **~/.bashrc** en supprimant la ligne de définition de cette variable, puis on applique les commandes :

```
source ~/.bashrc
unset NEW_VAR
```

- **Système (System)**

Ajouter **VAR='information'** à l'un des fichiers suivants : <br>
--- **/etc/profile.d/custom.sh** <br>
--- **/etc/bash.bashrc (Bash uniquement)** <br>
--- **/etc/environment**

Exemple

```
sudo vi /etc/environment
```

```
...
NEWVAR="super cool genial"
```

Pour appliquer le changement : <br>
--- soit on se déconnecte et se reconnecte du serveur <br>
--- soit on exécute la commande

```
source /etc/environment
```

```
echo $NEWVAR
```

Pour supprimer cette variable, **NEWVAR**, on édite le fichier **/etc/environment** en supprimant la ligne de définition de cette variable, puis on applique les commandes :

```
source /etc/environment
unset NEWVAR
```

Le répertoire **/etc/profile.d/** est un emplacement central contenant les scripts exécutés lors de la connexion au serveur. L'un des avantages de l'utilisation de scripts à cet emplacement est qu'ils peuvent être liés à une application spécifique et gérés séparément à partir d'un emplacement unique, tel que le fichier d'environnement **/etc/environment** ou le fichier **/etc/bash.bashrc**.
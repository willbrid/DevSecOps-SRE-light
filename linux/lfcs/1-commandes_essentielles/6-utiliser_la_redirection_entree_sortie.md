# Utiliser la redirection entrée-sortie

### Descripteurs de fichiers

- **stdin (0)** - standard input -> entrée standard
--- Comment les données sont saisies ou présentées pour le traitement <br>
--- Généralement le clavier ou la souris, mais il peut également s'agir d'un fichier

- **stdout (1)** - standard output -> sortie standard
--- Les données renvoyées par une commande

- **stderr (2)** - standard error -> erreur standard
--- Messages d'erreur renvoyés, séparés de la sortie standard

### Opérateurs de redirection

- **| (pipe)**

La commande **pipe** est utilisée pour envoyer la sortie d'une commande à une autre commande pour traitement.

```
cat /var/log/syslog | less
```

- **> (créer / écraser)**

Utilisé pour écrire la sortie d'une commande dans un fichier. Créera un fichier s'il n'existe pas, ou écrasera un fichier existant.

```
ls - l /etc > etc.txt
```

```
cat filenoexist > error.txt
cat filenoexist 1> error.txt
```

Les deux commandes ci-dessus sont identiques car par défaut le descripteur associé à la redirection **>** est la sortie standard. Comme le fichier n'existe pas, un message d'erreur sera affiché sur le terminal provenant de l'erreur standard et le fichier **error.txt** sera créé mais avec un contenu vide. 

```
cat filenoexist 2> error.txt
```

Comme le fichier n'existe pas, aucun message d'erreur ne sera affiché et le fichier **error.txt** sera créé avec le contenu du message d'erreur provenant de l'erreur standard.


```
cat filenoexist 2> /dev/null
```

Comme le fichier n'existe pas, aucun message d'erreur ne sera affiché et le message d'erreur sera envoyé vers le périphérique nul (**/dev/null**) qui supprime toutes les données qui y sont écrites.

- **>> (créer / ajouter)**

Utilisé pour ajouter la sortie d'une commande à un fichier. Créera un fichier s'il n'existe pas, ou ajoutera une sortie à un fichier existant.

```
ls - l /var >> etc.txt
```

- **< (entrée)**

Utilisé pour diriger le contenu d'un fichier vers une commande. Souvent utilisé pour envoyer des données à un script pour traitement, mais également avec des commandes.

```
less < etc.txt
```
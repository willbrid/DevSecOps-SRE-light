# Gérer les privilèges des utilisateurs

En tant qu'administrateur système Linux, la gestion de la sécurité à distance est essentielle. Nous devons nous assurer que seuls les utilisateurs autorisés peuvent accéder à nos systèmes et nous devons contrôler ce qu'ils exécutent.

Qui peut accéder à nos serveurs, et que peuvent-ils exécuter une fois sur le système ? En tant qu'administrateur système Linux, que devons-nous faire ?

### Fichier /etc/security/access.conf

Pour accéder à la page manuelle, on exécute :

```
man access.conf
```

Le fichier **/etc/security/access.conf** contient aussi toutes les informations liées à sa configuration :

```
cat /etc/security/access.conf
```

- Le format d'une entrée du fichier de configuration d'accès à distance

```
permission:user:origin
```

- **permission** : ce premier champ doit contenir un caractère "+" (accès accordé) ou "-" (accès refusé).
- **user** : ce deuxième champ doit être une liste d'un ou plusieurs noms de connexion, noms de groupe ou ALL (correspond toujours). Un modèle du formulaire **user@host** correspond lorsque le nom de connexion correspond à la partie « utilisateur » et lorsque la partie « hôte » correspond au nom de la machine locale.
- **origin** : ce troisième champ doit être une liste d'un ou plusieurs noms de **tty** (pour connexions hors réseau), **noms d'hôtes**, **noms de domaine** (commençant par "."), **adresses d'hôtes**, **numéros de réseau Internet** (terminés par "."), **ALL** (toujours correspond), **NONE** (ne correspond à aucun tty sur les connexions hors réseau) ou LOCAL (correspond à toute chaîne qui ne contient pas de caractère ".").

```
# Interdire les connexions non root sur tty1
-:ALL EXCEPT root:tty1

# L'utilisateur "john" devrait avoir accès depuis le réseau/masque ipv4
+:john:127.0.0.0/24
```
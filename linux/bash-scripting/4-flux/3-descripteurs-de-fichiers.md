# Descripteurs de fichiers

En ligne de commande, les nombres `1` et `2` désignent stdout et stderr : ce sont des **descripteurs de fichiers**.

**Définition** : un descripteur de fichier est un **entier positif ou nul** qui sert d'**index vers une ressource d'E/S ouverte** dans le système : fichier sur disque, socket réseau, pipe, périphérique… Le nom vient des débuts d'Unix (gestion des fichiers), mais les OS modernes traitent sockets, pipes et périphériques **de la même façon** (« tout est fichier »).

### 1. Les flux standards réservés

Par convention sous Linux et Unix, trois descripteurs sont **pré-alloués** pour les flux principaux :

| Descripteur | Flux | Description |
||||
| **0** | stdin | Entrée standard |
| **1** | stdout | Sortie standard |
| **2** | stderr | Sortie d'erreur |

Tout descripteur **≥ 3** peut référencer d'autres ressources : fichiers ouverts, sockets, pipes, terminaux.

Les descripteurs sont **propres à chaque processus**. Quand un programme ouvre une nouvelle ressource, l'OS lui attribue **le plus petit numéro libre** (en général à partir de 3).

> Exemples pratiques pour voir les descripteurs du shell courant :
> ```bash
> ls -l /proc/$$/fd
> # lrwx 1 user user 64 ... 0 -> /dev/pts/0
> # lrwx 1 user user 64 ... 1 -> /dev/pts/0
> # lrwx 1 user user 64 ... 2 -> /dev/pts/0
> ```
> Les trois flux standards pointent vers le terminal (`/dev/pts/0`).
>
> Nombre maximal de descripteurs ouverts par processus :
> ```bash
> ulimit -n
> # 1024
> ```

### 2. Analogie : le bibliothécaire et les cotes

Dans une bibliothèque :
- le **bibliothécaire** = le système d'exploitation ;
- les **livres** = fichiers, sockets, pipes ;
- les **cotes** des livres = les descripteurs de fichiers.

On donne une cote au bibliothécaire, il va chercher le livre correspondant. De la même façon, le shell utilise les descripteurs pour **acheminer les entrées/sorties** vers la bonne ressource.

### 3. Les flux standards appliqués à l'analogie

- **stdin (0)** : dire au bibliothécaire quel livre on veut.
- **stdout (1)** : recevoir le livre.
- **stderr (2)** : recevoir un message d'erreur si le livre est indisponible.

Comme une bibliothèque contient de nombreux livres, un processus peut avoir **des dizaines, voire des milliers** de descripteurs ouverts (3, 4, 5…).

> Exemples pratiques : ouvrir et utiliser ses propres descripteurs avec `exec`.
> ```bash
> # Ouvrir le fd 3 en écriture vers un fichier
> exec 3> journal.log
> echo "première ligne" >&3
> echo "deuxième ligne" >&3
> exec 3>&-            # fermer le fd 3
>
> # Ouvrir le fd 4 en lecture
> exec 4< journal.log
> read -r ligne <&4
> echo "$ligne"        # première ligne
> exec 4<&-            # fermer le fd 4
> ```
> Utile pour écrire plusieurs fois dans un fichier sans le rouvrir à chaque commande.
>
> Voir les descripteurs ouverts d'un processus : `lsof -p <PID>`.

### À retenir

- Un **descripteur de fichier** = un entier ≥ 0 qui référence une ressource d'E/S ouverte (fichier, pipe, socket, périphérique).
- **0 = stdin, 1 = stdout, 2 = stderr** sont réservés ; les nouveaux descripteurs commencent à **3**.
- L'OS attribue toujours **le plus petit numéro libre**.
- Les descripteurs sont **propres à chaque processus** (un enfant hérite de ceux de son parent).
- « Tout est fichier » sous Unix : pipes et sockets utilisent le même mécanisme que les fichiers.
- `ls -l /proc/$$/fd` ou `lsof -p PID` pour les inspecter ; `ulimit -n` pour la limite.
- `exec 3> fichier` ouvre un fd, `>&3` écrit dedans, `exec 3>&-` le ferme.

### Liens utiles

- [Advanced Bash-Scripting Guide – I/O Redirection](https://tldp.org/LDP/abs/html/io-redirection.html)
- [GeeksforGeeks – File Descriptors in Unix/Linux](https://www.geeksforgeeks.org/file-descriptors-unix-linux/)
- [GNU Bash – Redirections](https://www.gnu.org/software/bash/manual/html_node/Redirections.html)

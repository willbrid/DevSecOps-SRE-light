# Part2 : Afficher le texte et rediriger l'entrée/la sortie

- Créons un fichier **names.txt** contenant les prenoms

```
cd ~
vi names.txt
```

```
Joe
Ashley
Jacob
Violet
Graham
Bethany
William
```

- Créons un fichier **numbers.txt** contenant les nombres

```
vi numbers.txt
```

```
457
22
3009
9000
697
82
14
457
```

- avec la commande **grep** recherchons avec la casse et sans casse le prenom **william** dans le fichier **names.txt**

```
grep william names.txt
```

Cette recherche n'affiche aucun résultat car elle respecte la casse.

```
grep -i william names.txt
```

Cette recherche affiche un résultat car elle ne considère pas la casse.

- avec la commande **grep** recherchons toutes les lignes du fichier **numbers.txt** contenant le chiffre **9**

```
grep 9 numbers.txt
```

- avec la commande **sort**, faisons un tri alphanumérique dans le fichier **numbers.txt**

```
sort numbers.txt
```

```
14
22
3009
457
457
697
82
9000
```

- avec la commande **sort**, faisons un tri numérique (par ordre croissant par défaut) dans le fichier **numbers.txt**

```
sort -n numbers.txt
```

```
14
22
82
457
457
697
3009
9000
```

- avec la commande **sort**, faisons un tri numérique inversé (par ordre décroissant) dans le fichier **numbers.txt**

```
sort -nr numbers.txt
```

```
9000
3009
697
457
457
82
22
14
```

- avec la commande **sort**, faisons un tri alphanumérique dans le fichier **names.txt**

```
sort names.txt
```

```
Ashley
Bethany
Graham
Jacob
Joe
Violet
William
```

- avec la commande **sort**, redirigeons le résultat du tri alphanumérique dans le fichier **names.txt** vers le fichier **sorted.txt**

```
sort names.txt > sorted.txt
```

- avec la commande **sort**, redirigeons le résultat du tri alphanumérique dans le fichier **numbers.txt**, en ajout vers le fichier **sorted.txt**

```
sort numbers.txt >> sorted.txt
```

- envoyons le contenu du fichier numbers.txt vers l'entrée (**<**) de la commande **sort**, puis redirigeons le résultat en ajout vers le fichier **sorted.txt**

```
sort < numbers.txt >> sorted.txt
```

- de manière interactive, envoyons un ensemble de nombre à trier vers l'entrée (**<<**) de la commande **sort**

```
sort << eof
> 50
> 22 
> 3
> 17
> 40
> eof
```

- ratons l'orthographe de la commande **sort** en écrivant **Sort**, puis faisons un tri alphanumérique dans le fichier **numbers.txt** et enfin redirigeons l'erreur standard vers le fichier **error.log**

```
Sort numbers.txt 2> error.log
```

L'erreur **command not found** est enregistrée dans le fichier **error.log**

- avec la commande **ls**, listons le contenu des repertoires **/home/**, **/root/** et **/baddir/** (repertoire inexistant) et redirigeons la sortie standard vers le fichier **output.log**

```
ls /home/ /root/ /baddir/ > output.log
```

```
ls: cannot access '/baddir/': No such file or directory
```

Nous contatons la sortie standard est bien redirigée vers le fichier **output.log** mais l'erreur standard est affiché à l'écran.

- avec la commande **ls**, listons le contenu des repertoires **/home/**, **/root/** et **/baddir/** (repertoire inexistant) et redirigeons la sortie standard et l'erreur standard vers le fichier **output.log**

```
ls /home/ /root/ /baddir/ > output.log 2>&1
```

Autre méthode :

```
ls /home/ /root/ /baddir/ &> output.log
```

Nous constatons qu'aucun message n'est affiché à l'écran et que la sortie standard et l'erreur standard sont présentes dans le fichier **output.log**

- avec la redirection de pipeline, recherchons les processus **ssh**

```
ps -ef | grep ssh
```

- avec la redirection de pipeline, comptons le nombre de processus **ssh**

```
ps -ef | grep ssh | wc -l
```
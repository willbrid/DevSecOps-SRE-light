# Analyser du texte à l'aide d'expressions régulières de base

### Qu'est-ce qu'une expression régulière ?

Une expression régulière, souvent appelée **regex** ou **regexp**, est une série spécifique de caractères utilisée pour définir un modèle de recherche.

### Pourquoi devrais-je utiliser une expression régulière ?

Une expression régulière est le plus souvent utilisée pour l'activité « **find all** » ou « **find and replace** ». Il est également utilisé lorsque nous ne connaissons qu'une partie d'une chaîne de recherche ou si nous utilisons une recherche par caractère générique.

### Les opérateurs de recherche

- **^**   : la caret représente le début d'une chaîne ou d'une ligne
- **$**   : le signe dollar représente la fin d'une chaîne ou d'une ligne
- **.**   : le point fait correspondre une seule fois n'importe quel caractère
- **\***  : l'astérisque fait correspondre l'élément précédent 0 fois ou plusieurs fois
- **+**   : le signe plus fait correspondre l'élément précédent 1 ou plusieurs fois
- **{}**  : les accolades font correspondre l'élément précédent "autant" de fois {x,y} -> x est le nombre minimal de répétition de l'élément précédent et y le nombre maximal de répétition de l'élément précédent
- **?**   : le point d'interrogation fait rendre l'élément précédent facultatif
- **|**   : le pipe vertical fait correspondre une chose ou une autre (par exemple, **a|b** correspond à **a ou b**)
- **[]**  : les crochets font correspondre les éléments qui se trouvent dans une plage ou ensemble
- **()**  : les parenthèses font correspondre les sous-expressions
- **[^]** : les crochets carrés avec caret [^] font correspondre les éléments qui ne se trouvent pas dans une plage ou ensemble
- **\\**  : le back slash est utilisé pour échapper à un caractère spécial

### Exemples d'expressions régulières de base

- Rechercher chaque ligne commençant par "The"

```
grep '^The ' /etc/login.defs
```

- Rechercher chaque ligne commençant par la lettre "T" et ne se terminant pas par "E".

```
grep '^T[a-z][^e]' /etc/login.defs
```

- Rechercher chaque instance de "the" (avec t majuscule ou minuscule)

```
grep '\<[tT]he\>' /etc/login.defs
```

- Rechercher toutes les lignes commençant par #

```
grep '^#' /etc/login.defs
```

- Rechercher toutes les lignes ne commençant pas par #

```
grep -v '^#' /etc/login.defs
```

- Rechercher toutes les lignes commençant par PASS

```
grep '^PASS' /etc/login.defs
```

- Rechercher toutes les lignes contenant exactement 7

```
grep -w '7$' /etc/login.defs
```

L'option **-w** de la commande **grep** permet de faire correspondre le mot exacte.

- Rechercher toutes les lignes terminant par mail

```
grep 'mail$' /etc/login.defs
```

- Rechercher toutes les lignes contenant n'importe quel caractère entre **c** et **t** dans le repertoire **/etc**

```
grep -r 'c.t' /etc/
```

- Rechercher toutes les lignes contenant un mot de 3 lettres avec n'importe quel caractère entre c et t dans le repertoire **/etc**

```
grep -wr 'c.t' /etc/
```

- Rechercher toutes les lignes contenant n'importe quel caractère qui se repète 0 ou plusieurs fois dans le repertoire **/etc**

```
grep -r '/.*/' /etc/
```

- Rechercher les adresses emails dans un fichier

```
grep -E -o "\b[A-Za-b0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" filename
```

Dans les expressions régulières de base, les méta-caractères **?**, **+**, **|**, **{**, **(** et **)** perdent leur signification particulière, à la place, il faut utiliser la version avec barre oblique inversée.

```
grep -r '0\+' /etc/
```

### Exemples d'expression régulière étendue

En ajoutant l'option **-E** à grep cela nous permet d'utiliser les expressions régulères étendues. Aussi la commande **egrep** est équivalente à **grep -E**.

```
egrep -r '0+' /etc/
```

```
egrep -r '0{3,}' /etc/
```

```
egrep -r '10{,3}' /etc/
```

```
egrep -r '0{3}' /etc/
```

```
egrep -r 'disabled?' /etc/
```

```
egrep -r 'enabled|disabled' /etc/
```

```
egrep -r 'c[au]t' /etc/
```

```
egrep -r '/dev/[a-z]*[0-9]?' /etc/
```

```
egrep -r '/dev/([a-z]*[0-9]?)*' /etc/
```

```
egrep -r '/dev/(([a-z]|[A-Z])*[0-9]?)*' /etc/
```

```
egrep -r 'https[^:]' /etc/
```

```
egrep -r 'http[^s:]' /etc/
```

```
egrep -o '\b[A-Z][a-z]{2}\b' /etc/nsswitch.conf
```

Site web permettant de tester ses regex : **[https://regexr.com](https://regexr.com)**
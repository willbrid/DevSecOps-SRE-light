# Analyser du texte à l'aide d'expressions régulières de base

### Qu'est-ce qu'une expression régulière ?

Une expression régulière, souvent appelée **regex** ou **regexp**, est une série spécifique de caractères utilisée pour définir un modèle de recherche.

### Pourquoi devrais-je utiliser une expression régulière ?

Une expression régulière est le plus souvent utilisée pour l'activité « **find all** » ou « **find and replace** ». Il est également utilisé lorsque nous ne connaissons qu'une partie d'une chaîne de recherche ou si nous utilisons une recherche par caractère générique.

### Bases des expressions régulières

- **^** : le début d'une chaîne ou d'une ligne
- **$** : la fin d'une chaîne ou d'une ligne
- **.** : caractère générique pouvant correspondre à n'importe quel caractère, à l'exception du saut de ligne (**\n**)
- **|** : correspond à un caractère ou un groupe de caractères spécifique de chaque côté (par exemple, **a|b** correspond à **a ou b**)
- **\\** : utilisé pour échapper à un caractère spécial
- **t** : le caractère **"t"**
- **az** : la chaîne **"az"**

### Exemples d'expressions régulières

- Rechercher chaque ligne commençant par "The"

```
grep '^The ' filename
```

- Rechercher chaque ligne commençant par la lettre "T" et ne se terminant pas par "E".

```
grep '^T[a-z][^e]' filename
```

- Rechercher chaque instance de "the" (avec t majuscule ou minuscule)

```
grep '\<[tT]he\>' filename
```

- Rechercher les adresses emails dans un fichier

```
grep -E -o "\b[A-Za-b0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" filename
```
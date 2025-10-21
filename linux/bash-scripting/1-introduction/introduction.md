# Qu'est ce que BASH ?

**Bash (Bourne-Again SHell)** est l’interpréteur de commandes du système GNU, successeur du shell **sh** créé par **Stephen Bourne**. Compatible avec **sh**, il intègre aussi des fonctionnalités de **ksh** et **csh**, tout en respectant la norme **POSIX Shell and Tools** de la spécification IEEE POSIX (norme IEEE 1003.1). **Bash** apporte des améliorations pour l’usage interactif et la programmation. <br>
Bien qu’il existe d’autres shells dans GNU, **Bash** est le shell par défaut. Il est portable et fonctionne sur la plupart des systèmes Unix, ainsi que sur Windows et d’autres plateformes.

Les scripts Bash favorisent un apprentissage actif grâce à une boucle d’essai immédiate : écrire, exécuter, corriger. Cette approche rend la résolution de problèmes plus intuitive.

### Shell interactif vs non interactif

Les **shells interactifs** sont conçus pour la saisie de commandes à la volée, tandis que les **shells non interactifs** exécutent des scripts pré-écrits sans intervention de l'utilisateur.

- **Mode interactif** : taper des commandes à l'invite et voir un retour immédiat.

Les **shells interactifs**, comme ceux ouverts dans un terminal, lisent des fichiers d’initialisation tels que **~/.bashrc** ou **/etc/bash.bashrc**. Ces fichiers permettent de configurer l’**environnement utilisateur** en activant des fonctionnalités comme l’**historique des commandes**, l’**autocomplétion**, les **alias**, les **variables d’environnement** ou encore la **personnalisation** de l’invite de commande.

**Exemple :**

```
ls -l

echo "Hello world"

echo "$PS1"
```

- **Mode non interactif** : placer des commandes dans un fichier (un script) et les exécuter toutes en même temps.

les **shells non interactifs**, souvent utilisés pour exécuter des scripts, ignorent la plupart de ces fichiers d’initialisation. Toutefois, ils peuvent charger manuellement certains paramètres si cela est explicitement demandé via des directives comme **source ~/.bashrc** ou l’option **--login**.

**Exemple :**

```
vim script.sh
```

```
#!/bin/bash

ls -l
echo "Hello World"
```

```
chmod +x script.sh

./script.sh
```

Un **script ne doit pas dépendre des variables propres à un shell interactif** (comme **PS1**). Il est recommandé de définir explicitement toutes les variables d’environnement nécessaires pour garantir un comportement prévisible.

**Exemple :**

```
vim show_ps1.sh
```

```
#!/bin/bash

echo "$PS1"
```

```
chmod +x show_ps1.sh
./show_ps1.sh
```

Aucun résultat n'est affiché.

### Bonnes pratiques pour les scripts Shell

- Commencer par un simple "**#!/usr/bin/env bash**" pour la portabilité.

- Utiliser "**set -euo pipefail**" pour détecter les erreurs au plus tôt.

- Développer les variables entre guillemets double pour éviter le découpage des mots : `"$VAR"`.

- Sourcer explicitement les fichiers si nécessaire : `source ~/.bashrc`

- Tester les scripts dans les deux modes s'ils doivent s'exécuter de manière interactive et non interactive.

**Références** : 

- [https://www.gnu.org/software/bash/manual/bash.html](https://www.gnu.org/software/bash/manual/bash.html)
- [https://tldp.org/LDP/abs/html/](https://tldp.org/LDP/abs/html/)
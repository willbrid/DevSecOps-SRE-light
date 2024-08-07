# Configurer PAM

L'authentification des applications sous Linux est parfois difficile. **PAM** peut être un outil précieux pour configurer et mettre à jour les processus d'authentification.

Les modules d'authentification enfichables sous Linux nous permettent de configurer et de reconfigurer la manière dont l'authentification s'effectue dans les applications compatibles **PAM**, sans avoir besoin de réécrire l'application.

### PAM (Pluggable Authentication Modules)

- **PAM** contrôle l'authentification des utilisateurs
- Possède les composants suivants <br>
--- Les applications doivent être compatibles **PAM** <br>
--- Les fichiers de configuration se trouvent dans le répertoire **/etc/pam.d/** <br>
--- Les modules **PAM** se trouvent généralement dans **/lib64/security** (**Rocky**) ou **/lib/x86_64-linux-gnu/security/** (**Ubuntu**) mais l'emplacement peut varier en fonction de la distribution

### Workflow PAM

- Un utilisateur lance une application compatible PAM
- L'application appelle **libpam**
- La bibliothèque recherche les fichiers dans le répertoire **/etc/pam.d** pour voir quels modules **PAM** charger, y compris **system-auth**
- Chaque module est exécuté en suivant les règles définies pour cette application

### PAM Config - module-type control-flag pam-module

Fichier de configuration de **PAM** sous Ubuntu

```
cat /etc/pam.conf
```

Il y a 3 colonnes obligatoires pour une entrée dans le fichier **/etc/pam.conf**, la quatrième colonne étant facultative.

- **module-type** : les valeurs possibles sont : **Authentication**, **account**, **password**, **session**
- **control-flag** :  Cette colonne nous indiquera si le module est
--- **required**, ce qui signifie que s'il échoue, l'API échouera une fois tous les autres modules chargés <br>
--- **requisite**, ce qui est comme **required**, sauf qu'en cas d'échec, le contrôle est renvoyé directement à l'application. <br> 
--- s'il est **optional**, ce qui signifie qu'il est important qu'il s'agisse du seul module d'une pile (**stack**) associé au service. <br>
--- s'il est **sufficient**, ce qui signifie que si ce module réussit, il sera appliqué à l'ensemble de la pile (**stack**) et immédiatement envoyé à l'application
- **pam-module** : N'importe quel module, référence par son nom

Voyons quels modules sont actuellement sur nos systèmes

- Sous ubuntu 20.04

```
cd /lib/x86_64-linux-gnu/security
ls -ahl
```

- Sous Rocky linux 8

```
cd /lib64/security
ls -ahl
```
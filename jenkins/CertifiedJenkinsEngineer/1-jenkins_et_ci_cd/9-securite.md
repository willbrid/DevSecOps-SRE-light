# Sécurité

## Authentification vs Autorisation

L'authentification est le processus permettant de vérifier qui vous êtes. <br> 
L'autorisation est le processus de détermination de ce que vous êtes autorisé à faire.

## sécurité matricielle

Cela offre la possibilité de configurer la sécurité en fonction de différentes sections ou contextes. Il peut être global ou basé sur un projet. 

## Stratégie d'héritage

Elle est sélectionnable dans le menu déroulant du projet. Elle a 3 options :
- la première option, **inherit from parent**, concerne les projets qui se trouvent dans un dossier ou qui sont l'enfant d'un autre objet.
- l'option suivante, **inherit globally defined permissions**, concerne les projets qui se trouvent dans un dossier ou qui sont l'enfant d'un autre objet, mais qui ne veulent pas les autorisations du dossier ou du parent, uniquement les autorisations globales
- la dernière option, **do not inherit permission grants from other acls**, empêche cette tâche d'hériter des autorisations des paramètres globaux ou des éléments parents.

## Audit 

C'est le processus de vérification que les autorisations d'accès fonctionnent comme prévu. Cela garantit que la meilleure pratique des autorisations minimales requises est maintenue. <br>
N'oublions pas que jenkins est un modèle d'autorisation explicite et qu'il n'y a pas de refus; si quelque chose n'est pas explicitement autorisé, il est refusé. <br>
De plus, les autorisations jenkins sont additives et **global -> parent -> job** est la façon dont ces autorisations sont empilées. si quelque chose est autorisé à un niveau supérieur et que l'héritage est activé, il est autorisé dans les niveaux inférieurs.

## Identifiants

Il s'agit de toute valeur qui donne accès à une ressource restreinte, également appelée **secret**. Ceux-ci sont utilisés par jenkins pour accéder à des ressources restreintes. <br>

**Exemples de types d'informations d'identification** : 
- nom d'utilisateur et mot de passe
- nom d'utilisateur ssh et fichiers secrets de clé privée
- jetons secrets et certificats.
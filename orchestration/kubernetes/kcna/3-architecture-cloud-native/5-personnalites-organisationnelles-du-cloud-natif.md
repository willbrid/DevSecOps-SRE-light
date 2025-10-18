# Personnalités organisationnelles du cloud natif

Les personnalités organisationnelles (Organizational personas) ne sont pas nécessairement des individus ou des postes singuliers. Ce sont des rôles qui décrivent le travail de gestion des applications cloud natives.

Site Reliability Engineers (SRE) : ce sont des ingénieurs responsables de la création et de la maintenance des SLO, SLA et SLI.

Lors de la conception d'un système ou d'applications, il est important que les équipes se fixent des cibles/objectifs mesurables spécifiques pour aider les organisations à trouver le bon équilibre entre le développement de produits et le travail d'exploitation.
Ces objectifs aident les clients et les utilisateurs finaux à quantifier le niveau de fiabilité qu'ils doivent attendre d'un service

- **Service-Level Indicator (SLI)**

Indicateur de niveau de service (SLI) : mesure quantitative de certains aspects du niveau de service fourni. <br>
SLI courants : <br>
--- Latence des requêtes <br>
--- Taux d'erreur <br>
--- Saturation <br>
--- Débit <br>
--- Disponibilité <br>

Toutes les métriques ne font pas de bons SLI. Nous devons trouver des métriques qui mesurent avec précision l'expérience d'un utilisateur.
Des choses comme un processeur élevé/une mémoire élevée font un mauvais SLI car un utilisateur peut ne pas voir d'impact sur sa fin pendant ces événements

- **Service-Level Objective (SLO)**

Objectif de niveau de service (SLO) : valeur ou plage cible pour un SLI. <br>
Par exemple : <br>

| SLI | SLO |
|----------|----------|
| Latence | Latence < 100 ms |
| disponibilité | 99,9 % de disponibilité |

Les SLO doivent être directement liés à l'expérience client. L'objectif principal du SLO est de quantifier la fiabilité d'un produit pour un client.
<br>
Pour les SLO, il peut être tentant de les définir sur des valeurs agressives telles que 100 % de disponibilité, mais cela aura un coût plus élevé. <br>
L'objectif n'est pas d'atteindre la perfection mais plutôt de satisfaire les clients avec le bon niveau de fiabilité.
Si un client est satisfait d'une fiabilité de 99%, l'augmenter davantage n'ajoute aucune autre valeur

- **Service-Level Agreement (SLA)**

Accord de niveau de service (SLA) : contrat entre un fournisseur et un utilisateur qui garantit un certain SLO. <br>
Les conséquences du non-respect d'un SLO peuvent être financières, mais peuvent également être diverses autres choses.

[https://cloud.google.com/blog/products/devops-sre/sre-fundamentals-slis-slas-and-slos?hl=en](https://cloud.google.com/blog/products/devops-sre/sre-fundamentals-slis-slas-and-slos?hl=en)
# Configuration de logs [part1]

#### Les avantages de la journalisation sur HAProxy :

- Déjà en place

HAProxy se trouve déjà à l'endroit idéal pour recueillir des renseignements et inspecte déjà le trafic qui le traverse.
Tout ce que nous avons à faire est de dire à HAProxy ce que nous voulons enregistrer, comment et où.

- Hautement configurable

La journalisation HAProxy est hautement configurable, à la fois dans l'endroit où nous envoyons les données du journal et dans le format dans lequel nous stockons les données. Nous pouvons envoyer des journaux à plusieurs destinations et configurer la journalisation globalement, ce qui facilite le déploiement et sur une seule interface, ce qui permet une journalisation plus personnalisée.

- Journalisation détaillée

Les journaux HAProxy sont très détaillés avec une précision à la milliseconde.
Encore une fois, ils peuvent être configurés pour être aussi concis ou verbeux que nous le souhaitons.

- Parfait pour le troubleshooting

Les journaux HAProxy nous aident à dépanner, maintenir et améliorer les applications et les sites qu'ils protègent en nous aidant à comprendre les événements qui se sont produits, se produisent et à prévenir les problèmes qui ne se sont pas encore produits.

#### Que nous disent les logs ?

- **Metrics** : timing, nombre de connexions, taille du trafic, ...
- **Requêtes/Réponses** : en-têtes de requête, codes de statut, payloads, ...
- **Décisions HAProxy** : changement de contenu, filtrage de contenu, persistance, ...
- **Statut de fin de session** : peut être utilisé pour déterminer où les échecs se produisent. Utile pour configurer de nouveaux déploiements et réparer ceux existants

#### Les 8 niveaux de logs de HAProxy

- **emerg** : erreurs critiques, telles que le manque de descripteurs de fichiers du système d'exploitation
- **alert** : quelque chose d'inattendu, comme l'impossibilité de mettre en cache une réponse
- **crit** : non utilisé
- **err** : erreurs importantes et critiques, comme l'échec de l'analyse d'un fichier
- **warning** : erreurs importantes mais non critiques, comme l'impossibilité d'atteindre un serveur DNS
- **notice** : changements d'état et messages de démarrage, journalisation de la vérification de l'état
- **info** : détails et erreurs de connexion tcp et de requête http
- **debug** : peut être utilisé avec un code lua personnalisé pour les messages de débogage
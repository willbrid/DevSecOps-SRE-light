# Imperative vs Declarative

Ce contenu compare les **deux approches** de gestion des objets Kubernetes : l'**approche impérative** (exécuter des commandes directes) et l'**approche déclarative** (utiliser des fichiers de configuration).

### L'analogie du trajet

- **Impératif** : comme donner à un taxi des instructions détaillées, étape par étape (« tourner à droite sur la rue B, puis à gauche sur la rue C… »). On décrit **comment** atteindre le but — chaque action précise. Le résultat dépend de la bonne exécution de chaque étape, et en cas d'échec partiel, il faut vérifier soi-même l'état atteint et corriger manuellement. On garde le contrôle sur le déroulement, mais on porte aussi la responsabilité des erreurs. En Kubernetes : `kubectl run`, `kubectl create`, `kubectl replace`, `kubectl edit`, `kubectl scale`, `kubectl set image` — on ordonne une action précise.

- **Déclaratif** : comme commander un Uber en indiquant seulement la **destination** (« chez Tom ») ; le système détermine lui-même le meilleur chemin, s'adapte au trafic et gère les imprévus. On décrit **l'état désiré** (le « quoi »), pas les étapes (le « comment »), et le système compare la situation actuelle à l'objectif pour appliquer uniquement les changements nécessaires. **Approche plus robuste**, **reproductible** et **moins sujette aux erreurs**. En Kubernetes : `kubectl apply -f` — on déclare l'état voulu, Kubernetes crée l'objet s'il n'existe pas ou le met à jour s'il existe déjà.

### L'approche impérative

On émet des commandes explicites incluant à la fois la configuration désirée **et** les étapes pour l'atteindre. Exemple de provisioning : créer une VM, installer/configurer NGINX, télécharger le code, démarrer le serveur. Si l'exécution est partielle, des vérifications supplémentaires sont nécessaires → **plus sujet aux erreurs**.

Commandes impératives typiques :

```bash
kubectl run --image=nginx nginx
kubectl create deployment --image=nginx nginx
kubectl expose deployment nginx --port=80
kubectl edit deployment nginx
kubectl scale deployment nginx --replicas=5
kubectl set image deployment nginx nginx=nginx:1.18
```

#### Deux méthodes impératives

1. **Commandes directes** (`kubectl run`, `create`, `expose`) : création/modification rapide sans éditer de YAML. **Utile en examen** (rapidité), mais limité pour les configs complexes (pods multi-conteneurs) et **sans trace claire** (uniquement l'historique du shell).
2. **Changements transitoires** (`kubectl edit`) : modifient l'objet **live** dans le cluster, mais **pas le fichier YAML local** → risque d'incohérences.

### L'approche déclarative avec les fichiers de configuration

Avantages des fichiers YAML (manifestes) :
- Configuration **entièrement documentée** ;
- **Versionnable** dans Git ;
- Changements **suivis et reproductibles**.

Créer puis mettre à jour :

```bash
kubectl create -f nginx.yaml     # créer
kubectl replace -f nginx.yaml    # remplacer après modification du fichier
kubectl replace --force -f nginx.yaml  # supprimer et recréer si nécessaire
```

> `kubectl create -f` sur un objet qui **existe déjà** génère une **erreur** → toujours vérifier son existence avant.

> `kubectl edit` ouvre une représentation YAML **temporaire** de l'objet live (avec des champs runtime comme `status`), mais **ne met pas à jour** le fichier local. Méthode plus fiable : éditer directement le fichier local puis `kubectl replace -f`.

### L'approche déclarative avec `kubectl apply`

`kubectl apply` :

- **Crée** l'objet s'il n'existe pas ;
- **Compare** l'état actuel avec l'état désiré déclaré, puis **met à jour** l'objet pour correspondre.

```bash
kubectl apply -f nginx.yaml               # un fichier
kubectl apply -f /path/to/config-files    # plusieurs fichiers d'un dossier
```
→ Approche **moins sujette aux erreurs**, le cluster reflète en continu l'état déclaré.

### Comparaison synthétique

| Aspect | Impératif | Déclaratif |
|--------|-----------|------------|
| Principe | On dit **comment faire** (commandes) | On déclare **l'état désiré** (fichiers) |
| Commandes | `kubectl run`, `create`, `edit`, `replace`, `delete`, `scale`... | `kubectl apply -f` |
| Traçabilité | Faible (historique shell) | Forte (fichiers versionnés Git) |
| Usage idéal | Tests rapides, examen | Environnements complexes, cohérence |
| Robustesse | Plus sujet aux erreurs | Moins sujet aux erreurs |

### Conseils pour l'examen

- Pour les opérations **rapides** en examen : privilégier les **commandes impératives** (`kubectl run`, `create deployment`, `expose`, `scale`, `set image`) → gain de temps.
- Pour les configs **complexes** (pods multi-conteneurs, variables d'environnement, init containers) : privilégier les **fichiers YAML + `kubectl apply`** → itération rapide et correction sûre des erreurs.
- Maintenir les fichiers de config dans un **dépôt versionné (Git)** est essentiel pour les clusters plus grands et complexes.

### À retenir

- **Impératif** = commandes directes, rapide mais peu traçable. Aussi les commandes qui nomment une action précise (**create**, **replace**, **delete**, **edit**, **scale**, **set**) sont impératives, même avec `-f`
- **Déclaratif** = fichiers YAML + `kubectl apply`, cohérent et reproductible.
- `kubectl apply` crée ou met à jour intelligemment ; `kubectl create` échoue si l'objet existe.
- `kubectl edit` modifie le live sans toucher au fichier local (source d'incohérences).

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs

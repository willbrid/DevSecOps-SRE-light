# Introduction ETCD

> Introduction à etcd — un magasin de données clé-valeur distribué, fiable, simple et rapide : son fonctionnement, son installation, et la transition de l'API v2 vers v3.

### Qu'est-ce qu'un magasin clé-valeur (key-value store) ?

**Bases de données relationnelles (SQL)** : les données sont stockées dans des **tables** (lignes + colonnes).
- Chaque **ligne** = une entité (ex. une personne).
- Chaque **colonne** = un détail (nom, âge…).
- **Limite** : pour ajouter une info (salaire, note…), il faut **ajouter une colonne** qui ne s'applique pas forcément à toutes les lignes → rigidité.

**Magasin clé-valeur** : les données sont organisées en **documents/fichiers indépendants**, chacun contenant toutes les infos d'une entité → structures **flexibles et dynamiques**.
- Un employé peut avoir un document avec un salaire.
- Un étudiant peut avoir un document avec une note.

Pour les transactions complexes, on utilise des formats structurés comme **JSON ou YAML** :
```json
{
  "name": "John Doe",
  "age": 45,
  "location": "New York",
  "salary": 5000
}
```

### Installation et démarrage d'etcd

Étapes : télécharger le **binaire** adapté à l'OS depuis la page *GitHub releases*, extraire l'archive, puis exécuter etcd. Par défaut, **etcd écoute sur le port `2379`**, et l'on utilise le client **`etcdctl`** pour stocker et récupérer des paires clé-valeur.

Téléchargement :
```bash
ETCD_VER=v3.7.2

curl -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o etcd-${ETCD_VER}-linux-amd64.tar.gz


tar xzvf etcd-${ETCD_VER}-linux-amd64.tar.gz --strip-components=1 --no-same-owner

./etcd
```

> A partir de la version v3.6 l'etcd n'expose plus l'api v2.

Opérations de base avec l'**API v3** :
```bash
./etcdctl put key1 value1   # stocker
./etcdctl get key1          # récupérer
```

Lancé sans argument, `./etcdctl` affiche la liste des commandes disponibles (`get`, `put`, `del`, `snapshot`, `compaction`,…).

> **Historique des versions** (utile pour comprendre les différences de commandes) :
> - **v0.1** — août 2013
> - **v2.0** — février 2015 → introduction de l'algorithme de consensus **Raft**
> - **v3.0** — janvier 2017 → optimisations
> - **Incubation à la CNCF** — novembre 2018

### Transition de l'API v2 vers v3 pour les versions etcd < v3.6

Un changement **critique** entre les versions est l'**API utilisée par etcdctl**. Les anciennes installations peuvent utiliser l'**API v2** par défaut, les récentes l'**API v3**.

Vérifier la version :
```bash
./etcdctl --version
# etcdctl version: 3.3.11
# API version: 2
```

Deux façons de basculer en **API v3** :
```bash
# 1) Variable préfixée à la commande
ETCDCTL_API=3 ./etcdctl version

# 2) Variable exportée pour la session
export ETCDCTL_API=3
./etcdctl version
```

> **Différences clés en API v3 :**
> - La commande pour définir une clé passe de **`set`** (v2) à **`put`** (v3).
> - La récupération reste **`get`** dans les deux.
> - `version` devient une **sous-commande** (et non plus une option).

Opérations en **API v3** :
```bash
export ETCDCTL_API=3
./etcdctl put key1 value1   # → OK
./etcdctl get key1          # → key1 / value1
```

> A partir de la version v3.6 l'etcd n'expose plus l'api v2.

### À retenir

- **etcd** = magasin clé-valeur **distribué, fiable, simple et rapide** ; cœur du stockage d'état dans Kubernetes.
- **Clé-valeur vs relationnel** : documents indépendants et flexibles vs tables rigides à colonnes fixes.
- Port par défaut : **`2379`** ; client en ligne de commande : **`etcdctl`**.
- **Raft** = algorithme de consensus introduit en v2.0 (essentiel pour la haute disponibilité, détaillé plus loin dans le cours).
- **Piège d'examen** — commande selon l'API :
  - API **v2** → `set` pour écrire
  - API **v3** → `put` pour écrire (et `get` pour lire dans les deux)
- Toujours **vérifier/fixer** `ETCDCTL_API=3` avant de manipuler etcd, sinon les commandes peuvent échouer ou différer.
- etcd est un projet **CNCF** (incubé en novembre 2018).

### Liens utiles

- Page des releases etcd (GitHub) : https://github.com/etcd-io/etcd/releases

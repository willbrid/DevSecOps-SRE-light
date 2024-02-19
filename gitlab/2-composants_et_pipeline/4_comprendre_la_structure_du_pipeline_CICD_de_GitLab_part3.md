# Comprendre la structure du pipeline CI/CD de GitLab [Part3]

Nous présentons ici les différentes façons d'éxécuter des pipelines GitLab CI/CD et comment lire les statuts de ces pipelines.

### Pipelines de branche

La manière la plus courante d’exécuter un pipeline consiste à valider une modification dans une branche. Chaque fois que nous faisons cela, GitLab exécute automatiquement un pipeline sur la version des fichiers de notre projet existant dans ce commit. Dans la liste des instances de pipeline, nous verrons une entrée pour cette instance de pipeline qui affiche (entre autres informations) le nom de la branche et le SHA de la validation la plus récente dans la branche.

GitLab nous permet également d'exécuter manuellement un pipeline sur n'importe quelle branche Git de notre choix, même si ce n'est pas la dernière branche dans laquelle nous nous sommes engagés. Déclencher un pipeline sur une branche arbitraire est simple : visiter la liste des pipelines, cliquer sur le bouton **Exécuter le pipeline**, sélectionner la branche sur laquelle nous souhaitons que le pipeline s'exécute, puis cliquer sur le bouton suivant **Exécuter le pipeline**.

### Pipelines de tags Git

GitLab nous permet également d'exécuter des pipelines sur des **tags Git** arbitraires même si un tag ne pointe pas vers le dernier commit sur une branche. Nous disons simplement à GitLab d'exécuter un pipeline sur n'importe quel **tag** en utilisant le même processus de déclenchement manuel que celui que nous avons utilisé pour pointer un pipeline vers une branche spécifique.

### Autres types de pipelines

Il existe trois autres types de pipelines bien qu'ils soient moins fréquemment utilisés que les pipelines de branchement ou de tag :
- les pipelines de **requêtes de fusion** s'exécutent sur la branche source d'une **requête de fusion**, chaque fois que des validations sont effectuées sur cette branche.

- les pipelines de **résultats fusionnés** sont des types spéciaux de pipelines de **demandes de fusion**. les pipelines de **résultats fusionnés** s’exécutent sur une fusion temporaire de la branche source d’une demande de fusion dans sa branche cible, chaque fois que des validations sont effectuées dans la branche source. ce type de pipeline ne fusionne pas réellement les deux branches ; il exécute simplement un pipeline sur la collection de fichiers qui aurait résulté si nous les avions fusionnés. C'est un excellent moyen de nous assurer que notre branche s'intégrera bien dans notre base de code stable.

- les **trains de fusion** constituent un type particulier de pipeline de **résultats fusionnés**. Les **trains de fusion** mettent en file d'attente plusieurs demandes de fusion, puis exécutent des pipelines de **résultats fusionnés** distincts et simultanés sur chaque demande de fusion dans la file d'attente. Mais au lieu d'effectuer une fusion temporaire uniquement des branches source et cible d'une demande de fusion, le **train de fusion** effectue une fusion temporaire des branches source de chaque demande de fusion qui précède la demande de fusion actuelle dans la file d'attente. C'est un bon moyen de garantir que plusieurs branches s'intégreront bien dans une branche cible en évolution rapide lorsqu'elles seront fusionnées.

### Ignorer des pipelines

Il y a des moments où il est plus logique de ne pas exploiter de pipeline. Il est facile d'empêcher un commit de déclencher une exécution de pipeline. Incluons simplement l'une de ces deux phrases n'importe où dans un message de validation, et GitLab effectuera la validation sans exécuter de pipeline dessus :

```
[skip ci]
```

```
[ci skip]
```

Cette pause du pipeline s’applique uniquement à un seul commit. La prochaine fois que nous nous engagerons dans cette branche sans inclure l'un des deux messages ignorés, le pipeline reprendra avec la nouvelle validation qui, bien sûr, inclura toutes les modifications que nous avons apportées à la validation sans pipeline.

### Lecture des statuts des pipelines GitLab CI/CD

Non seulement chaque instance de pipeline a un statut de **pass/fail**, mais chaque étape de l'instance de pipeline a un statut de **pass/fail**, et chaque tâche au sein d'une étape a également un statut de **pass/fail**. Il y a plus de statuts disponibles que simplement **pass** ou **fail**. Ci-dessous quelques-unes des valeurs les plus fréquemment observées :

- **running** : le pipeline, l'étape ou la tâche est en cours.
- **pending** : attente de ressources disponibles pour démarrer une tâche.
- **skipped** : lorsqu'une étape antérieure échoue, toutes les étapes ultérieures sont ignorées par défaut.
- **canceled** : les utilisateurs peuvent annuler n'importe quelle tâche ou pipeline pendant son exécution.

Il existe plusieurs endroits dans l'interface graphique où GitLab affiche le **statut** des pipelines, des étapes et des tâches. En outre, il existe plusieurs représentations graphiques différentes de la structure du pipeline du projet et du **statut** de chaque élément au sein de la structure.
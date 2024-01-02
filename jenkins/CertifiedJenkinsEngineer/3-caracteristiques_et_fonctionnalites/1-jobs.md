# Jobs

## Création d'un dossier 

Pour créer un dossier, sur l'espace d'accueil, nous cliquons sur "nouveau Item".

![jenkins_job1.png](../../images/jenkins_job1.png)

Une fenêtre s'ouvre où nous allons saisir le nom de notre dossier **mondossier**, puis choisir l'option **Dossier** .

![jenkins_job2.png](../../images/jenkins_job2.png)

Une fenêtre s'ouvre où nous allons insérer le nom d'affichage du dossier **mondossier**, puis sa description **Mon dossier de travail** et enfin ajouter un indicateur de santé permettant de contrôler si les éléments des sous-dossiers seront considérés comme contribuant à la santé de ce dossier.

![jenkins_job3.png](../../images/jenkins_job3.png)

## Création d'un job

Nous pouvons créer simple un job depuis la racine de jenkins. Pour cela nous cliquons sur **Tableau de bord**, puis sur **nouveau item**. Une page s'ouvre où nous allons renseigner le nom du job **monjob**, puis choisir l'option **construire un projet free-style** .

![jenkins_job4.png](../../images/jenkins_job4.png)

Une fenêtre s'ouvre où nous allons saisir une description par exemple **mon job de travail** .

![jenkins_job5.png](../../images/jenkins_job5.png)

Nous déplaçons ce job vers le dossier créé précédemment. Pour cela sur la page de détails du job, nous cliquons sur le menu **Déplacer**.

![jenkins_job6.png](../../images/jenkins_job6.png)

Une fénêtre s'ouvre où nous allons choisir notre dossier **mondossier**, puis validons.

![jenkins_job7.png](../../images/jenkins_job7.png)

Ainsi en ouvrant notre dossier **mondossier**, nous verrons notre job dans la liste.

![jenkins_job8.png](../../images/jenkins_job8.png)

## Création d'un sous dossier

Nous pouvons créer un sous dossier **phpdossier** du dossier **mondossier** de la même manière que nous avons fait pour le dossier **mondossier** à condition de se situer d'abord sur l'interface détails de notre dossier **mondossier** via la navigation sur **Tableau de bord** > **mondossier** .

![jenkins_job9.png](../../images/jenkins_job9.png)

Après création du sous dossier, nous afficherons ce qui sur l'interface de notre dossier **mondossier** .

![jenkins_job10.png](../../images/jenkins_job10.png)

## Création d'un job **shell command** dans notre sous dossier **phpdossier**

Dans notre sous dossier **phpdossier**, nous pouvons créer un job **testShellJob** de la même manière que nous avons fait depuis notre dossier racine.

![jenkins_job11.png](../../images/jenkins_job11.png)

ou alors directement 

![jenkins_job12.png](../../images/jenkins_job12.png)

Une fenêtre s'ouvra où nous allons mentionner la description, puis ajouter une étape de build en choisissant l'option **Exécuter un script shell**. Commande à utiliser : **uname -a** .

![jenkins_job13.png](../../images/jenkins_job13.png)

Nous pouvons lancer le build du job en cliquant sur le menu **lancer un build**, puis quelques secondes après, un résultat s'affiche sur le volet **Historique des builds** .

![jenkins_job14.png](../../images/jenkins_job14.png)

Nous pouvons le résultat d'un buil spécifique en cliquant sur l'item choisi de l'**Historique des builds**, puis en cliquant sur **sortie de la console**.

![jenkins_job15.png](../../images/jenkins_job15.png)

![jenkins_job16.png](../../images/jenkins_job16.png)

## Edition d'un job (testShellJob)

Nous pouvons modifier notre job **testShellJob** en configurant la possibilité d'affichage les dates dans notre sortie console et de rediriger notre commande shell dans un **fichier test.txt**. <br>
Pour cela nous nous redirigeons sur la page détails de notre job, puis nous cliquons sur **Configure** .

![jenkins_job17.png](../../images/jenkins_job17.png)

![jenkins_job18.png](../../images/jenkins_job18.png)

Si nous lançons un build et que nous consultons la **sortie console**, nous verrons les dates.

![jenkins_job19.png](../../images/jenkins_job19.png)

Si nous consultons le répertoire de travail de notre job **testShellJob**, nous trouverons notre fichier **test.txt**.

![jenkins_job20.png](../../images/jenkins_job20.png)

Nous pouvons éditer notre job **testShellJob** en configurant l'option permettant de supprimer le répertoire de travail de notre job avant son build, aussi en configurant un autre script shell exécutant la command **hostname**.

**NB**: Dans cette modification, deux commandes seront éxécutées :

```
uname -a
hostname
```

![jenkins_job21.png](../../images/jenkins_job21.png)

Si nous exécutons encore le build de notre job **testShellJob**, nous ne verrons plus de fichier **test.txt** dans son répertoire de travail et nous verrons nos deux commandes exécutées.

![jenkins_job22.png](../../images/jenkins_job22.png)

Nous pouvons aussi éditer notre job **testShellJob** en configurant les paramètres à utiliser par ce job. Pour cela en mode édition, (menu **Configure** de la page détails du job), nous cochons l'option **Ce build a des paramètres**, puis nous ajoutons la sous-option **Paramètre String**. En guise d'exemple nous définissons un paramètre **version** avec pour valeur **latest** et une description.

![jenkins_job23.png](../../images/jenkins_job23.png)

Nous pouvons ainsi utiliser ce paramètre via notre script shell : **$nomParametre**

![jenkins_job24.png](../../images/jenkins_job24.png)

En lançant le build, jenkins nous demande d'éditer à nouveau le paramètre défini.

![jenkins_job25.png](../../images/jenkins_job25.png)
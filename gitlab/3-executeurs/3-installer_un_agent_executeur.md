# Installer un agent exécuteur

Ici nous installerons un agent exécuteur et l'enregistrerons au près de Gitlab.

### Installation d'un agent exécuteur sous notre serveur gitlab-runner

La documentation GitLab nous demande de télécharger et d'exécuter d'abord un script shell qui ajoute les référentiels **gitlab-runner** au gestionnaire de packages de notre système.

```
sudo curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
```

```
sudo dnf install -y gitlab-runner
```

Nous pouvons vérifier que l'agent exécuteur GitLab est démarré et en cours d'exécution.

```
sudo gitlab-runner status
```

Nous verrons une confirmation que l'agent est en cours d'exécution, et également qu'aucun agent exécuteur n'est encore enregistré auprès de GitLab.

### Inscription de notre agent exécuteur au près de GitLab

Lorsque nous enregistrons un agent exécuteur auprès de GitLab, nous lions les agents exécuteurs à une instance GitLab entière (agents exécuteurs partagés), à un groupe (agents exécuteurs de groupe) ou à un projet (agents exécuteurs spécifiques). Les instructions d'inscription et les paramètres de l'agent exécuteur après l'enregistrement apparaissent dans la partie respective de GitLab où nous avons enregistré l'agent exécuteur (**instance**, **groupe** ou **projet**).

Nous prendrons le cas de l'enregistrement de l'agent exécuteur au près de notre projet **mymbolo** sur Gitlab. Pour cela accédons à la page **Settings > CI/CD > Runners** de notre projet **mymbolo** et suivons les étapes ci-dessous :

- Etendons le menu **Runners** avec le bouton **Expand** : la box de configuration d'un nouveau runner s'ouvre.
- Cliquons sur le bouton **New project runner**
- Sélectionnons le système **Linux**
- Ajoutons un tag "**dev,linux**"
- Ajoutons une description "**linux dev server**"
- Dans le champ Délai d'expiration maximum de la tâche, entrons une valeur en secondes : **600 secondes**(**10 minutes**).
- Cliquons sur le bouton **Create runner**

Une page s'ouvre nous indiquant comment inscrire l'exécuteur au près de gitlab. Dans notre cas :

```
gitlab-runner register --url https://gitlab.willbrid.com:8443 --token glrt-YxJrGXXr_xoy8gCBCzeV
```

Le jeton d'authentification de l'exécuteur **glrt-YxJrGXXr_xoy8gCBCzeV** s'affiche ici pendant une courte période uniquement. Après avoir enregistré l'exécuteur, ce jeton est stocké dans le fichier **config.toml** et n'est plus accessible depuis l'interface utilisateur.

Nous cliquons sur le bouton **Go to runners page**.

Sur notre serveur **gitlab-runner**, copions le fichier de certificat d'autorité de certification à l'emplacement **/etc/pki/ca-trust/source/anchors/**

```
sudo scp vagrant@192.168.56.170:/home/vagrant/ca.crt /etc/pki/ca-trust/source/anchors/digitca.crt 
```

Sur notre serveur **gitlab-runner**, validons le certificat copié

```
sudo update-ca-trust
```

Sur notre serveur **gitlab-runner**, exécutons la commande d'inscription de notre agent exécuteur au près de gitlab.

```
sudo gitlab-runner register --url https://gitlab.willbrid.com:8443 --token glrt-YxJrGXXr_xoy8gCBCzeV
```

Nous validons les paramètres par défaut sauf pour l'éxécuteur où il faudrait entrer **shell**. une fois tous les paramètres renseignés, un message de succès s'affiche. Nous pouvons vérifier la réussite de l’inscription via la commande :

```
sudo gitlab-runner list
```

Il donnera les détails de l'inscription de notre exécuteur.

```
Runtime platform                                    arch=amd64 os=linux pid=8361 revision=782c6ecb version=16.9.1
Listing configured runners                          ConfigFile=/etc/gitlab-runner/config.toml
gitlab-runner                                       Executor=shell Token=glrt-YxJrGXXr_xoy8gCBCzeV URL=https://gitlab.willbrid.com:8443
```

L'interface utilisateur de GitLab présente quelques autres fonctionnalités intéressantes de notre runner spécifique. Les tags **dev,linux** sont affichées à côté de l'ID et de la description de l'exécuteur. L'interface nous montre que l'éxécuteur peut être affecté à d'autres projets. L'icône en forme de crayon nous amènera aux paramètres de l'éxécuteur que nous pouvons ajuster dans l'interface utilisateur de GitLab, et le bouton pause « mettra en pause » l'éxécuteur. Mettre l'éxécuteur en pause le gardera enregistré avec GitLab, mais empêchera l'éxécuteur d'accepter de nouvelles tâches pendant qu'il est en pause. Nous pouvons afficher les paramètres et les statistiques des éxécuteurs existants en cliquant sur l'ID de l'éxécuteur en lien hypertexte : ces informations incluent les **détails de l'architecture** et du **réseau de l'éxécuteur**, son **statut d'activité** et les **attributs** tels que les **tags de l'éxécuteur**, son **statut protégé ou non protégé**, sa **description** et sa **capacité à être attribué à d'autres projets**. <br>
Le champ de **délai d'expiration maximal** de la tâche indique à l'éxécuteur de signaler une tâche comme ayant échoué par défaut après un certain délai.

### Quelques considérations importantes pour Gitlab

- GitLab dispose d'une fonctionnalité appelée **Dependency Proxy**, dans laquelle nous pouvons configurer un registre local pour mettre en cache par exemple les images Docker, afin que l'exécuteur n'ait pas besoin d'extraire d'une source publique à chaque exécution. Au lieu de cela, le programme d'exécution extraira du registre local, et l'extraction de la source publique n'aura besoin d'être effectuée que pour mettre à jour les versions du conteneur dans le cache.

- L'exécuteur Docker peut être considéré comme un peu plus sûr car les conteneurs constituent une couche d'abstraction supplémentaire par rapport au système hôte. Le programme d'exécution clone le code du projet et exécute les commandes de tâches dans un conteneur isolé, puis détruit le conteneur après avoir renvoyé les résultats à GitLab. Il est cependant crucial de s’assurer que les conteneurs fonctionnent en mode non privilégié. Autrement dit, les tâches doivent être exécutées par des utilisateurs **non root** pour garantir que leur exécution n'implique pas l'accès au système hôte.

- Le monitoring des données autour de nos exécuteurs et pipelines est essentielle pour garantir une sécurité et une utilisation appropriées des ressources.Les trois principaux domaines à prendre en compte concernant la surveillance de nos exécuteurs sont les suivants : <br>
--- le composant analytique disponible dans l'interface utilisateur de Gitlab <br>
--- le système de journalisation des exécuteurs <br>
--- les métriques exportables produites par les exécuteurs eux-mêmes

Afin d'exposer les métriques de l'exécuteur, nous devons d'abord modifier le fichier de configuration principal de l'exécuteur **/etc/gitlab-runner/config.toml** en ajoutant le paramètre **Listen_address** pour indiquer au serveur de métriques sur quel port écouter. Un exemple de fichier **/etc/gitlab-runner/config.toml** :

```
concurrent = 1
check_interval = 0
Listen_address = "localhost:9252"
...
```

- Un moyen utile de confirmer que le programme d'exécution a une configuration valide et qu'il peut communiquer correctement avec GitLab est d'exécuter

```
sudo gitlab-runner verify
```
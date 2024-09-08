# Vérifier les fichiers journaux

Parfois, lors du débogage d'erreurs d'application ou du diagnostic de pannes ou d'autres problèmes, nous devons vérifier les fichiers journaux du serveur.

Toute opération de fichier journal courante (comme l'utilisation de tail , cat , grep , etc.) fonctionne via la commande ansible, avec quelques mises en garde :

- Les opérations qui surveillent en permanence un fichier, comme **tail -f** , ne fonctionneront pas via Ansible, car Ansible n'affiche la sortie qu'une fois l'opération terminée, et nous ne pourrons pas envoyer la commande Control-C pour arrêter de suivre le fichier.
- Ce n'est pas une bonne idée d'exécuter une commande qui renvoie une énorme quantité de données via **stdout** via Ansible. Si nous allons faire **cat** sur un fichier de plus de quelques Ko, nous devrions nous connecter probablement au(x) serveur(s) individuellement.
- Si nous redirigeons et filtrons la sortie d'une commande exécutée via Ansible, nous devons utiliser le module **shell** au lieu du module **command** par défaut d'Ansible (ajoutons **-m shell** à nos commandes).

```
ansible multi -b -a "tail /var/log/messages"
```

si nous voulons filtrer le journal des messages avec quelque chose comme **grep**, nous devons utiliser le module **shell** :

```
ansible multi -b -m shell -a "tail /var/log/messages | grep ansible-command | wc -l"
```
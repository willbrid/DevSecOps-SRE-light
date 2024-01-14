# Gérer les packages

Ansible propose une variété de modules de gestion de packages pour toutes les versions de Linux, mais il existe également un module de package générique qui peut être utilisé pour une utilisation multiplateforme plus facile d'Ansible.

Si nous souhaitons installer un paquet générique comme **git** sur n'importe quel système Debian, RHEL, Fedora, Ubuntu, CentOS, FreeBSD, etc., nous pouvons utiliser la commande.

```
ansible app -b -m package -a "name=git state=present"
```

Le module **package** fonctionne à peu près de la même manière que **yum** , **apt** et d'autres modules de gestion de packages.
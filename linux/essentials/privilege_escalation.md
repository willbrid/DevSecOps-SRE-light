# Escalade de privilège

**- Afficher les identifiants d'utilisateurs et de groupes de l'utilisateur courant**
```
id
```

**- Afficher les identifiants d'utilisateurs et de groupes d'un utilisateur quelconque**
```
id <user>
```

**- Lancer une commande en mode utilisateur root**
```
sudo <command>
```

**- Modifier le fichier /etc/sudoers**
```
sudo visudo
```

**- Se connecter en tant qu'utilisateur root**
```
sudo -i
```

NB: C'est le mot de passe de l'utilisateur qui exécute le sudo, qui doit être saisi.

Pour se déconnecter en tant qu'utilisateur root :
```
logout
```

**- Se connecter en tant qu'utilisateur particulier**
```
sudo -i -u <user>
```

**- Passer en utilisateur root avec le mot de passe root**
```
su -
```

**- Passer en utilisateur quelconque avec son mot de passe**
```
su - <user>
```
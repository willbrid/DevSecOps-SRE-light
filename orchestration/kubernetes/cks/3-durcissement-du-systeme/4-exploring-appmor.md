# Explorer AppArmor

**AppArmor** : module de sécurité du noyau Linux (Distribution Debian).<br>
**AppArmor** fournit un contrôle d'accès granulaire pour les programmes exécutés sur les systèmes Linux. Utilisons **AppArmor** pour contrôler et limiter ce qu'un programme peut faire dans le système d'exploitation hôte.<br>

Un **profil AppArmor** est un ensemble de règles qui définissent ce qu'un programme peut et ne peut pas faire.<br>
Par exemple ce profil empêchera le programme d'écrire des données sur le disque :
```
#include <tunables/global>
profile k8s-deny-write flags=(attach_disconnected) {
  #include <abstractions/base>
  file,
  # Deny all file writes.
  deny /** w,
}
```

Un **profil AppArmor** peut être chargé dans **AppArmor** au niveau du serveur et activé dans l'un des deux modes.<br>

- **Mode complain** - chargeons un profil en **mode complain** et **AppArmor** générera simplement un rapport sur ce que fait le programme. Ceci est utile pour découvrir ce qu'un programme fait normalement.
- **Mode enforce** - chargeons un profil en **mode enforce**, et **AppArmor** empêchera activement le programme de faire quoi que ce soit que le profil n'autorise pas.<br>

Les profils doivent être activés sur le serveur sur lequel le pod s'exécute, sinon le pod ne démarrera pas.
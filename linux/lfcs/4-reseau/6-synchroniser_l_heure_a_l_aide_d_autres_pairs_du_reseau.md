# Synchroniser l'heure à l'aide d'autres pairs du réseau

De nombreuses tâches de gestion des données et de planification sont extrêmement sensibles au facteur temps. En tant qu'administrateur système Linux, nous devons nous assurer que nos systèmes signalent une heure précise et cohérente. De nombreux services et applications Linux dépendent d'une heure système précise sur plusieurs nœuds.

Avec le passage à **systemd**, la vénérable commande **ntp** a été remplacée par la commande **timedatectl**.

Pour afficher la configuration de l'heure, exécutons la commande sans argument

```
timedatectl
```

Elle affiche les informations suivantes :

- **Local time** : l'heure actuelle dans le fuseau horaire local de la machine.
- **Universal time** : l'heure universelle coordonnée (UTC), également connue sous le nom de temps universel coordonné (UTC), qui est un standard de temps de référence.
- **RTC time** : l'heure stockée dans la puce de l'horloge en temps réel (RTC) de notre système.
- **Time zone** : le fuseau horaire actuellement configuré sur le système.
- **System clock synchronized** : indique si l'horloge système est synchronisée avec l'horloge matérielle (RTC) ou un serveur NTP (Network Time Protocol).
- **NTP service** : cette information indique si le service NTP (Network Time Protocol) est activé ou non sur le système. Le service NTP est utilisé pour synchroniser l'horloge système avec des serveurs de temps NTP externes afin de maintenir l'heure précise. S'il est activé, cela signifie que le système utilise NTP pour synchroniser l'heure. Sinon, il peut s'appuyer sur l'horloge matérielle (RTC) ou une autre méthode pour maintenir l'heure précise.
- **RTC in local TZ** : cette information indique si l'horloge matérielle (RTC) est maintenue dans le fuseau horaire local ou dans le fuseau horaire universel coordonné (UTC). L'horloge matérielle (RTC) est une puce sur la carte mère qui conserve l'heure même lorsque l'ordinateur est éteint. Le choix entre le fuseau horaire local et UTC dépend de la configuration du système et des préférences de l'utilisateur. Si cette option est activée, cela signifie que l'horloge matérielle est réglée sur le fuseau horaire local; sinon, elle est réglée sur UTC.

Listons les timezones depuis notre serveur

```
timedatectl list-timezones
```

Recherchons le timezone de la ville de **Douala**

```
timedatectl list-timezones | grep -i douala
```

Configurons le timezone de notre serveur sur celui de **Douala**

```
sudo timedatectl set-timezone Africa/Douala
```

Vérifions si la configuration du timezone a été effective

```
timedatectl
```

Activons/désactivons la synchronisation de l'heure ntp

```
sudo timedatectl set-ntp off
```

```
timedatectl
```

```
sudo timedatectl set-ntp on
```

Après avoir désactivé la synchronisation de l'heure ntp, l'on peut modifier manuellement l'horloge

```
sudo timedatectl set-time 22:00:00
```

Pour resynchroniser l'heure automatiquement, il faudrait réactiver la synchronisation de l'heure ntp.
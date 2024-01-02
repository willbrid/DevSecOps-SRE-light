# Namespaces et Cgroups
**Espaces de noms (Namespaces)** : une technologie liée à Linux qui isole les processus en partitionnant les ressources qui leur sont disponibles. Les espaces de noms empêchent les processus d'interférer les uns avec les autres. Docker exploite les espaces de noms pour isoler les ressources des conteneurs.<br>

Quelques espaces de noms utilisés par Docker :
- pid : isolement de processus.
- net : Interfaces réseau.
- ipc : Communication inter-processus.
- mnt : montages du système de fichiers.
- uts : identificateurs de noyau et de version.
- espaces de noms d'utilisateurs : nécessite une configuration spéciale. Permet aux processus de conteneur de s'exécuter en tant que root à l'intérieur du conteneur tout en mappant cet utilisateur à un utilisateur non privilégié sur l'hôte.
<br>

**Groupes de contrôle (cgroups)** : les groupes de contrôle limitent les processus à un ensemble spécifique de ressources. Docker utilise des cgroups pour appliquer des règles relatives à l'utilisation des ressources par les conteneurs, telles que la limitation de la mémoire ou de l'utilisation du processeur.<br>
Lien: https://docs.docker.com/engine/security/userns-remap/
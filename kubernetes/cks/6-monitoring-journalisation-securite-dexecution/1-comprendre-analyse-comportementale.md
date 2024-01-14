# Comprendre l'analyse comportementale

L'analyse comportementale est le processus d'observation de ce qui se passe dans un système et d'identification des événements anormaux et potentiellement malveillants.<br>
L'analyse comportementale peut être effectuée manuellement ou à l'aide d'outils.<br>

**Falco** est un projet open source créé par **Sysdig**. **Falco** surveille les appels système Linux au moment de l'exécution et alerte sur toute activité suspecte en fonction de règles configurables. Nous pouvons l'utiliser pour détecter et répondre rapidement aux activités suspectes.<br>

Quelques exemples de choses que **Falco** peut surveiller :

- **Élévation de privilèges** : un conteneur privilégié tentant d'élever les privilèges.
- **Binaires** : Exécution de binaires suspects, comme l'ouverture d'un shell.
- **Accès aux fichiers** : lit ou écrit dans des fichiers à des emplacements bien connus tels que **/**, **/usr/bin**, etc.
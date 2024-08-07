# Utiliser des scripts pour automatiser les tâches de maintenance du système

Les tâches répétitives font partie de la routine d'un administrateur système Linux. Les scripts peuvent aider à minimiser la nature répétitive en automatisant les tâches.

Les scripts Shell sont une compétence précieuse pour un administrateur Linux. Un bon script peut faire gagner du temps, assurer la cohérence et réduire le risque d’erreurs dans les processus répétitifs.

Exemple de script

```
cd ~/
vi script.sh
```

```
#!/bin/bash

echo
echo "This is a basic script example."
echo
# Display user
echo "User: "`whoami`
# Display working directory
echo "Current Directory: " $(pwd)
echo -n "Current shell:"
# Display OS Release Info
lsb_release -d
echo
```

```
chmod +x script.sh
```

```
./script.sh
```
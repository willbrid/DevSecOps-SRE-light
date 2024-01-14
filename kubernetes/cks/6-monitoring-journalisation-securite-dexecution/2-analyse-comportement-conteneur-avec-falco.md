# Analyse du comportement des conteneurs avec Falco

## Falco depuis la ligne de commande

Nous pouvons exécuter **Falco** à partir de la ligne de commande avec la commande **falco**.
- utilisons *-r \<fichier\>* pour fournir un fichier de règles personnalisées.
- utilisons *-M \<secondes\>* pour exécuter Falco pendant un nombre défini de secondes.

```
falco -r rules.yml -M 45
```

- Une règle **Falco** définit un ensemble de conditions qui déclencheront une alerte. Les règles peuvent être définies dans des fichiers YAML.
- **condition** : une déclaration qui définit le comportement qui déclenchera une alerte.
- **output** : Un format de sortie pour l'alerte.
- *%fields* : % fait référence à un champ de données. 
Consultons la documentation **Falco** pour obtenir une liste des champs ou utilisons la commande

```
falco --list
```

Sur les trois noeuds worker, installons **Falco** :

- Sous **Ubuntu 20.04**

```
curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | sudo apt-key add -
```

```
echo "deb https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list
```

```
sudo apt-get update
```

```
sudo apt-get install -y falco
```

- Sous **Rocky 8.x**

```
sudo rpm --import https://falco.org/repo/falcosecurity-packages.asc
```

```
sudo curl -s -o /etc/yum.repos.d/falcosecurity.repo https://falco.org/repo/falcosecurity-rpm.repo
```

```
sudo yum install epel-release
```

```
sudo yum update -y
```

```
sudo yum install -y dkms make kernel-devel-$(uname -r) clang llvm
```

```
sudo reboot
```

```
sudo yum install -y falco
```

```
sudo falco-driver-loader module
```

Sur le nœud du plan de contrôle, créons un pod de test :

```
vi falco-test-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: falco-test-pod
spec:
  nodeName: k8s-worker1
  containers:
  - name: falco-test
    image: busybox:1.33.1
    command: ['sh', '-c', 'while true; do cat /etc/shadow; sleep 5; done']
```

```
kubectl create -f falco-test-pod.yml
```

Sur le nœud **k8s-worker1**, créons un fichier de règles Falco :

```
vi falco-rules.yml
```

créons une règle qui recherchera les processus générés dans le conteneur de test :

```
- rule: spawned_process_in_test_container
  desc: A process was spawned in the test container.
  condition: container.name = "falco-test" and evt.type = execve
  output: "%evt.time,%user.uid,%proc.name,%container.id,%container.name"
  priority: WARNING
```

Exécutons **falco** pendant 45 secondes à l'aide du fichier de règles :

```
sudo falco -r falco-rules.yml -M 45
```

Consultons la liste des champs pris en charge par Falco :

```
sudo falco --list
```

**Référence** : https://falco.org/docs/install-operate/installation
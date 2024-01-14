# Création d'une sandbox d'exécution de conteneur

- Installer **gVisor** Runtime : la première étape consiste à installer l'environnement d'exécution du conteneur qui exécutera les charges de travail en sandbox.
- Configurer le conteneur : ensuite, nous devons configurer **containerd** pour pouvoir interagir avec **runsc**.
- Créer une **RuntimeClass** : nous devons configurer une **RuntimeClass**, qui nous permettra de désigner les pods qui doivent utiliser le runtime en sandbox.

## Installer et configurer gVisor

#### Installation

Sur les 4 nœuds (plan de contrôle et 3 nœuds worker), installons **gVisor**.

- Sous **Ubuntu 20.04**

```
curl -fsSL https://gvisor.dev/archive.key | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64,arm64] https://storage.googleapis.com/gvisor/releases release main"
```

```
sudo apt-get update && sudo apt-get install -y runsc
```

- Sous **Rocky 8.x**

```
cd ~
vi gVisor-installer.sh
```

```
#!/bin/bash

(
  set -e
  ARCH=$(uname -m)
  URL=https://storage.googleapis.com/gvisor/releases/release/latest/${ARCH}
  wget ${URL}/runsc ${URL}/runsc.sha512 \
    ${URL}/containerd-shim-runsc-v1 ${URL}/containerd-shim-runsc-v1.sha512
  sha512sum -c runsc.sha512 \
    -c containerd-shim-runsc-v1.sha512
  rm -f *.sha512
  chmod a+rx runsc containerd-shim-runsc-v1
  sudo mv runsc containerd-shim-runsc-v1 /usr/local/bin
)
```

```
chmod +x gVisor-installer.sh
```

```
./gVisor-installer.sh
```

#### Configuration

Modifions la configuration du **containerd** et ajoutons la configuration pour **runsc**.

```
sudo vi /etc/containerd/config.toml
```

Trouvons la section **disabled_plugins** et ajoutons le plugin de redémarrage.

```
disabled_plugins = ["io.containerd.internal.v1.restart"]
```

Trouvons le bloc **plugins."io.containerd.grpc.v1.cri".containerd.runtimes** . Après le bloc **runc** existant, ajoutons une configuration pour un environnement d'exécution **runsc**. Cela devrait ressembler à ceci une fois terminé :

```
...
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    runtime_type = "io.containerd.runc.v1"
    runtime_engine = ""
    runtime_root = ""
    privileged_without_host_devices = false
    ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc]
    runtime_type = "io.containerd.runsc.v1"
...
```

Localisons le bloc **plugins."io.containerd.runtime.v1.linux"** et définissons **shim_debug** sur *true* .

```
[plugins."io.containerd.runtime.v1.linux"]
  ...
  shim_debug = true
```

Redémarrons **containerd** et vérifions qu'il fonctionne toujours.

```
sudo systemctl restart containerd
sudo systemctl status containerd
```

## Créer une RuntimeClass

Sur le serveur du plan de contrôle uniquement, créons une nouvelle **RuntimeClass**.

```
vi runsc-sandbox.yml
```

```
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: runsc-sandbox
handler: runsc
```

```
kubectl create -f runsc-sandbox.yml
```

**name** est le nom utilisé pour appliquer la RuntimeClass aux pods.<br>
**handler** fait référence à une section du fichier de configuration **containerd** qui configure **runsc** .

## Tester la sandbox d'exécution

Créons un pod qui n'utilise pas la sandbox.

```
vi non-sandbox-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: non-sandbox-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'while true; do echo "Running..."; sleep 5; done']
```

```
kubectl create -f non-sandbox-pod.yml
```

Créons un pod qui utilise la sandbox.

```
vi sandbox-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: sandbox-pod
spec:
  runtimeClassName: runsc-sandbox
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'while true; do echo "Running..."; sleep 5; done']
```

```
kubectl create -f sandbox-pod.yml
```

Vérifions la sortie **dmesg** des pods.

```
kubectl exec non-sandbox-pod -- dmesg
kubectl exec sandbox-pod -- dmesg
```

Nous verrons une grande différence dans la sortie de ces deux conteneurs, puisque le conteneur en sandbox s'exécute dans un noyau **gVisor** simulé.
<br>
**Référence** : https://gvisor.dev/docs/user_guide/install
One master node et 2 workers nodes
```
time k3d cluster create training --servers 1
time k3d node create training-worker1 -c training
time k3d node create training-worker2 -c training
```

For using a local image you should use a local registry (ubuntu 18.04)

- Start a local registry 
```
docker run -d -p 5000:5000 --name willbrid.registry registry:2
```

- create a file registries.yaml with this content below in $HOME/.k3d/ folder
```
mirrors:
  "willbrid.registry:5000":
    endpoint:
      - http://willbrid.registry:5000
```

- create a cluster with one node
```
time k3d cluster create training --servers 1 --volume $HOME/.k3d/registries.yaml:/etc/rancher/k3s/registries.yaml
time k3d node create training-worker1 -c training
time k3d node create training-worker2 -c training
```

- Don't forget to put an entrance willbrid.registry:5000 in your /etc/hosts file

- Put the local registry and the cluster in the same network (for this example, the cluster name is : k3d-training)
```
docker network connect k3d-training willbrid.registry
```
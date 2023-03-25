#### URLs:
- [k3s-install](https://github.com/ShadowUser17/BasicInstalls/blob/master/kubernetes/k3s-cluster-install.md)
- [flux-install](https://github.com/ShadowUser17/BasicInstalls/blob/master/fluxcd/README.md)

#### Configure bootstrap repository:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/flux/k8s-bootstrap.yaml"
```

#### Configure optional repositories:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/flux/docker-templates.yaml"
```

#### Deploy flagger components:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/flux/flagger-kubernetes.yaml"
```

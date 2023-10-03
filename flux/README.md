#### Deploy flux:
```bash
kubectl apply -k .
```

#### Deploy flagger:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/flux/flagger.yaml"
```

#### Deploy namespaces:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/flux/namespaces.yaml"
```

#### Deploy repositories:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/flux/repositories.yaml"
```

#### Create prom-operator target:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/flux/prom-operator-metrics.yml"
```

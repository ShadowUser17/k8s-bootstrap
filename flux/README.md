#### Deploy components:
```bash
kubectl apply -k .
```

#### Create prom-operator target:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/flux/prom-operator-metrics.yml"
```

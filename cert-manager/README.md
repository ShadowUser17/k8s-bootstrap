#### Deploy components:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/cert-manager/fluxcd-deploy.yml"
```

#### Create prom-operator target:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/cert-manager/prom-operator-metrics.yml"
```

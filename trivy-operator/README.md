#### Deploy components:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/trivy-operator/fluxcd-deploy.yml"
```

#### Create prom-operator target:
```bash
kubectl apply -f "https://raw.githubusercontent.com/ShadowUser17/k8s-bootstrap/master/trivy-operator/prom-operator-metrics.yml"
```

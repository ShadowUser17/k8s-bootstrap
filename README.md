#### App deployments for my testing cluster.

#### Install providers:
```bash
terraform init
```

#### Check Helm updates:
```bash
nova find --helm --format=table
```

#### Show deployed versions:
```bash
terraform output
```

#### Deploy changes to cluster:
```bash
terraform plan
```
```bash
terraform apply
```

#### URLs:
- [helm-provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [kubectl-provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs)
- [kubernetes-provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)

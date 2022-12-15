#### Install K3S:
```bash
curl -sfL "https://get.k3s.io" | INSTALL_K3S_CHANNEL="v1.23.14+k3s1" sh -s - server \
--token "AoNwhviL4xukEwTFntvmVpKK" \
--node-name "k3s" \
--with-node-id \
--write-kubeconfig-mode "0644" \
--disable-helm-controller \
--disable traefik
```

#### Install FluxCD:
```bash
curl -L -O "https://github.com/fluxcd/flux2/releases/download/v0.37.0/flux_0.37.0_linux_amd64.tar.gz" && \
tar -xzf flux_0.37.0_linux_amd64.tar.gz flux && rm -f flux_0.37.0_linux_amd64.tar.gz && \
mv ./flux /usr/local/bin/ && flux install
```

#### Configure bootstrap repository:
```bash
flux create source git bootstrap \
--url="https://github.com/ShadowUser17/k8s-bootstrap.git" \
--branch="master" \
--interval="1m0s" \
--silent
```
```bash
flux create kustomization base \
--source="bootstrap" \
--path="./base" \
--prune="true" \
--interval="1m0s"
```

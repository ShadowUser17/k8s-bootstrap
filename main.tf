terraform {
    required_providers {
        helm = "2.12.1"
        kubectl = {
            source = "gavinbunney/kubectl"
            version = "1.14.0"
        }
    }
}

provider "helm" {
    kubernetes {
        config_path = "~/.kube/config"
    }
}

provider "kubectl" {
    load_config_file = true
}

resource "helm_release" "cert-manager" {
    repository = "https://charts.jetstack.io"
    chart = "cert-manager"
    values = ["${file("./values/cert-manager.yml")}"]
    name = "cert-manager"
    version = "v1.14.4"
    namespace = "cert-manager"
    create_namespace = true
}

resource "kubectl_manifest" "cluster-issuer" {
    yaml_body = "${file("./values/cluster-issuer.yml")}"
}

resource "helm_release" "nginx-ingress" {
    repository = "https://kubernetes.github.io/ingress-nginx"
    chart = "ingress-nginx"
    values = ["${file("./values/ingress-nginx.yml")}"]
    name = "ingress-nginx"
    version = "4.10.0"
    namespace = "ingress-nginx"
    create_namespace = true
}

terraform {
    required_providers {
        helm = "2.12.1"
        kubernetes = "2.27.0"

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

provider "kubernetes" {
    config_path = "~/.kube/config"
}

/*
    Deploy base components:
*/
resource "kubernetes_namespace" "testing-ns" {
    metadata {
        name = "testing"
    }
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
    depends_on = [helm_release.cert-manager]
}

resource "helm_release" "nginx-ingress" {
    repository = "https://kubernetes.github.io/ingress-nginx"
    chart = "ingress-nginx"
    values = ["${file("./values/ingress-nginx.yml")}"]
    name = "ingress-nginx"
    version = "4.10.0"
    namespace = "ingress-nginx"
    create_namespace = true
    depends_on = [helm_release.cert-manager]
}

/*
    Deploy monitoring stack:
*/
resource "kubernetes_namespace" "monitoring-stack-ns" {
    metadata {
        name = "monitoring"
    }
}

resource "helm_release" "kube-prometheus-stack" {
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"
    values = ["${file("./values/prometheus-operator.yml")}"]
    name = "prom-operator"
    version = "57.1.1"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.cert-manager, helm_release.nginx-ingress]
}

resource "helm_release" "blackbox-exporter" {
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "prometheus-blackbox-exporter"
    values = ["${file("./values/blackbox-exporter.yml")}"]
    name = "prober"
    version = "8.12.0"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.kube-prometheus-stack]
}

resource "helm_release" "snmp-exporter" {
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "prometheus-snmp-exporter"
    values = ["${file("./values/snmp-exporter.yml")}"]
    name = "snmp"
    version = "5.1.0"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.kube-prometheus-stack]
}

resource "helm_release" "loki" {
    repository = "https://grafana.github.io/helm-charts"
    chart = "loki"
    values = ["${file("./values/loki.yml")}"]
    name = "loki"
    version = "5.47.1"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.kube-prometheus-stack]
}

resource "helm_release" "promtail" {
    repository = "https://grafana.github.io/helm-charts"
    chart = "promtail"
    values = ["${file("./values/promtail.yml")}"]
    name = "promtail"
    version = "6.15.5"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.loki]
}

resource "helm_release" "event-exporter" {
    repository = "https://charts.bitnami.com/bitnami"
    chart = "kubernetes-event-exporter"
    values = ["${file("./values/event-exporter.yml")}"]
    name = "event-exporter"
    version = "3.0.0"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.loki]
}

resource "kubectl_manifest" "cert-manager-monitor" {
    yaml_body = "${file("./monitoring/cert-manager.yml")}"
    depends_on = [helm_release.kube-prometheus-stack]
}

resource "kubectl_manifest" "ingress-nginx-monitor" {
    yaml_body = "${file("./monitoring/ingress-nginx.yml")}"
    depends_on = [helm_release.kube-prometheus-stack]
}

/*
    Deploy storage components:
*/
resource "helm_release" "minio" {
    repository = "https://charts.bitnami.com/bitnami"
    chart = "minio"
    values = ["${file("./values/minio.yml")}"]
    name = "s3"
    version = "14.1.2"
    namespace = "${kubernetes_namespace.testing-ns.id}"
    create_namespace = false
    depends_on = [helm_release.kube-prometheus-stack]
}

/*
    Deploy security components:
*/
resource "helm_release" "tetragon" {
    repository = "https://helm.cilium.io"
    chart = "tetragon"
    values = ["${file("./values/tetragon.yml")}"]
    name = "tetragon"
    version = "1.0.2"
    namespace = "kube-system"
    create_namespace = false
    depends_on = [helm_release.kube-prometheus-stack]
}

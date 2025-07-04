terraform {
    required_providers {
        helm = "2.17.0"
        kubernetes = "2.36.0"

        kubectl = {
            source = "gavinbunney/kubectl"
            version = "1.19.0"
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
    version = "v1.17.2"
    namespace = "cert-manager"
    create_namespace = true
}

output "cert-manager_version" {
    value = helm_release.cert-manager.version
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
    version = "4.12.3"
    namespace = "ingress-nginx"
    create_namespace = true
    depends_on = [helm_release.cert-manager]
}

output "nginx-ingress_version" {
    value = helm_release.nginx-ingress.version
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
    version = "74.2.1"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.cert-manager, helm_release.nginx-ingress]
}

output "kube-prometheus-stack_version" {
    value = helm_release.kube-prometheus-stack.version
}

/*resource "helm_release" "node-problem-detector" {
    repository = "https://charts.deliveryhero.io"
    chart = "node-problem-detector"
    values = ["${file("./values/node-problem-detector.yml")}"]
    name = "node-monitor"
    version = "2.3.13"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.kube-prometheus-stack]
}

output "node-problem-detector_version" {
    value = helm_release.node-problem-detector.version
}*/

/*resource "helm_release" "blackbox-exporter" {
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "prometheus-blackbox-exporter"
    values = ["${file("./values/blackbox-exporter.yml")}"]
    name = "prober"
    version = "9.0.0"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.kube-prometheus-stack]
}

output "blackbox-exporter_version" {
    value = helm_release.blackbox-exporter.version
}*/

/*resource "helm_release" "snmp-exporter" {
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "prometheus-snmp-exporter"
    values = ["${file("./values/snmp-exporter.yml")}"]
    name = "snmp"
    version = "5.5.0"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.kube-prometheus-stack]
}

output "snmp-exporter_version" {
    value = helm_release.snmp-exporter.version
}*/

resource "helm_release" "loki" {
    repository = "https://grafana.github.io/helm-charts"
    chart = "loki"
    values = ["${file("./values/loki.yml")}"]
    name = "loki"
    version = "6.30.1"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
}

output "loki_version" {
    value = helm_release.loki.version
}

resource "helm_release" "promtail" {
    repository = "https://grafana.github.io/helm-charts"
    chart = "promtail"
    values = ["${file("./values/promtail.yml")}"]
    name = "promtail"
    version = "6.17.0"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.loki]
}

output "promtail_version" {
    value = helm_release.promtail.version
}

resource "helm_release" "event-exporter" {
    repository = "https://charts.bitnami.com/bitnami"
    chart = "kubernetes-event-exporter"
    values = ["${file("./values/event-exporter.yml")}"]
    name = "event-exporter"
    version = "3.0.3"
    namespace = "${kubernetes_namespace.monitoring-stack-ns.id}"
    create_namespace = false
    depends_on = [helm_release.loki]
}

output "event-exporter_version" {
    value = helm_release.event-exporter.version
}

resource "kubectl_manifest" "cert-manager-monitor" {
    yaml_body = "${file("./monitoring/cert-manager.yml")}"
    depends_on = [helm_release.kube-prometheus-stack]
}

resource "kubectl_manifest" "ingress-nginx-monitor" {
    yaml_body = "${file("./monitoring/ingress-nginx.yml")}"
    depends_on = [helm_release.kube-prometheus-stack]
}

resource "kubectl_manifest" "loki-monitor" {
    yaml_body = "${file("./monitoring/loki-single.yml")}"
    depends_on = [helm_release.kube-prometheus-stack]
}

/*
    Deploy storage components:
*/
/*resource "helm_release" "minio" {
    repository = "https://charts.bitnami.com/bitnami"
    chart = "minio"
    values = ["${file("./values/minio.yml")}"]
    name = "s3"
    version = "14.7.0"
    namespace = "${kubernetes_namespace.testing-ns.id}"
    create_namespace = false
    depends_on = [helm_release.kube-prometheus-stack]
}

output "minio_version" {
    value = helm_release.minio.version
}*/

/*
    Deploy CI/CD components:
*/
/*resource "kubernetes_namespace" "argo-workflows-ns" {
    metadata {
        name = "argo-workflows"
    }
}

resource "kubectl_manifest" "argo-workflows-sa" {
    yaml_body = "${file("./roles/argo-workflows-sa.yml")}"
    depends_on = [kubernetes_namespace.argo-workflows-ns]
}

resource "kubectl_manifest" "argo-workflows-cluster-role" {
    yaml_body = "${file("./roles/argo-workflows-cluster-role.yml")}"
    depends_on = [kubectl_manifest.argo-workflows-sa]
}

resource "kubectl_manifest" "argo-workflows-role-binding" {
    yaml_body = "${file("./roles/argo-workflows-role-binding.yml")}"
    depends_on = [
        kubectl_manifest.argo-workflows-cluster-role,
        kubectl_manifest.argo-workflows-sa
    ]
}

resource "kubectl_manifest" "argo-workflows-sa-secret" {
    yaml_body = "${file("./roles/argo-workflows-sa-secret.yml")}"
    depends_on = [
        kubernetes_namespace.argo-workflows-ns,
        kubectl_manifest.argo-workflows-sa
    ]
}

resource "kubectl_manifest" "argo-workflows-secret" {
    yaml_body = "${file("./values/argo-workflows-secret.yml")}"
    depends_on = [kubernetes_namespace.argo-workflows-ns]
}

resource "helm_release" "argo-workflows" {
    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-workflows"
    values = ["${file("./values/argo-workflows.yml")}"]
    name = "argo-workflows"
    version = "0.42.2"
    namespace = "${kubernetes_namespace.argo-workflows-ns.id}"
    create_namespace = false
    depends_on = [
        helm_release.cert-manager,
        helm_release.nginx-ingress,
        helm_release.kube-prometheus-stack,
        helm_release.minio
    ]
}

output "argo-workflows_version" {
    value = helm_release.argo-workflows.version
}*/

/*resource "helm_release" "argo-events" {
    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-events"
    values = ["${file("./values/argo-events.yml")}"]
    name = "argo-events"
    version = "2.4.8"
    namespace = "${kubernetes_namespace.argo-workflows-ns.id}"
    create_namespace = false
    depends_on = [
        helm_release.cert-manager,
        helm_release.nginx-ingress,
        helm_release.argo-workflows,
        helm_release.kube-prometheus-stack
    ]
}

output "argo-events_version" {
    value = helm_release.argo-events.version
}

resource "kubectl_manifest" "argo-events-bus" {
    yaml_body = "${file("./values/argo-events-event-bus.yml")}"
    depends_on = [helm_release.argo-events]
}*/

/*
    Deploy security components:
*/
resource "helm_release" "tetragon" {
    repository = "https://helm.cilium.io"
    chart = "tetragon"
    values = ["${file("./values/tetragon.yml")}"]
    name = "tetragon"
    version = "1.4.0"
    namespace = "kube-system"
    create_namespace = false
    depends_on = [helm_release.kube-prometheus-stack]
}

output "tetragon_version" {
    value = helm_release.tetragon.version
}

/*resource "helm_release" "trivy-operator" {
    repository = "https://aquasecurity.github.io/helm-charts"
    chart = "trivy-operator"
    values = ["${file("./values/trivy-operator.yml")}"]
    name = "trivy-operator"
    version = "0.24.1"
    namespace = "trivy-system"
    create_namespace = true
    depends_on = [helm_release.kube-prometheus-stack]
}

output "trivy-operator_version" {
    value = helm_release.trivy-operator.version
}*/

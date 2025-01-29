resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.10.0"
  namespace  = kubernetes_namespace.logging.metadata[0].name

  set {
    name  = "clusterName"
    value = "elasticsearch"
  }
}

resource "helm_release" "fluentd" {
  name       = "fluentd"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluentd"
  version    = "0.3.1"
  namespace  = kubernetes_namespace.logging.metadata[0].name

  set {
    name  = "elasticsearch.host"
    value = "${helm_release.elasticsearch.name}-master.${kubernetes_namespace.logging.metadata[0].name}.svc.cluster.local"
  }
}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "7.10.0"
  namespace  = kubernetes_namespace.logging.metadata[0].name

  set {
    name  = "elasticsearchHosts"
    value = "http://${helm_release.elasticsearch.name}-master.${kubernetes_namespace.logging.metadata[0].name}.svc.cluster.local:9200"
  }
}
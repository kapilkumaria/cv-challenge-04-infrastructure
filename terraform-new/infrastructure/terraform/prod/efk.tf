resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  namespace  = "logging"

#   depends_on = [module.eks, null_resource.kubectl]
}

resource "helm_release" "fluent-bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = "logging"

#   depends_on = [module.eks, null_resource.kubectl]
}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  namespace  = "logging"

#   depends_on = [module.eks, null_resource.kubectl]
}
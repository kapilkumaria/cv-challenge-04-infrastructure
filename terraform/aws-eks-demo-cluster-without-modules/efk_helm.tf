resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }

  depends_on = [aws_eks_cluster.eks-cluster]
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  namespace  = "logging"

  set {
    name  = "replicas"
    value = "2"
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.storageClass"
    value = "gp2"
  }

  set {
    name  = "persistence.size"
    value = "10Gi"
  }

  depends_on = [kubernetes_namespace.logging]
}

resource "helm_release" "fluent-bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = "logging"

  # depends_on = [kubernetes_namespace.logging]
  depends_on = [kubernetes_namespace.logging, helm_release.elasticsearch]
}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  namespace  = "logging"

  # depends_on = [kubernetes_namespace.logging]
  depends_on = [kubernetes_namespace.logging, helm_release.elasticsearch]
}
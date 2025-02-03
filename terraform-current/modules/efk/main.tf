################################################################################
# TERRAFORM EFK MODULE MAIN CONFIGURATION FILE
################################################################################

resource "kubernetes_namespace" "logging" {
  metadata {
    name = var.namespace
  }
}

# EBS-backed Storage Class for Persistent Volumes
resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "gp3-ebs-sc"
  }

  storage_provisioner = "ebs.csi.aws.com"
  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
}

# Deploy Elasticsearch with EBS-backed PVC
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = var.elasticsearch_version
  namespace  = kubernetes_namespace.logging.metadata[0].name

  set {
    name  = "volumeClaimTemplate.storageClassName"
    value = kubernetes_storage_class.ebs_sc.metadata[0].name
  }

  set {
    name  = "volumeClaimTemplate.resources.requests.storage"
    value = "30Gi"
  }
}

# Deploy Fluentd with EBS-backed PVC
resource "helm_release" "fluentd" {
  name       = "fluentd"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluentd"
  version    = var.fluentd_version
  namespace  = kubernetes_namespace.logging.metadata[0].name

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.storageClass"
    value = kubernetes_storage_class.ebs_sc.metadata[0].name
  }

  set {
    name  = "persistence.size"
    value = "10Gi"
  }
}

# Deploy Kibana
resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = var.kibana_version
  namespace  = kubernetes_namespace.logging.metadata[0].name
}

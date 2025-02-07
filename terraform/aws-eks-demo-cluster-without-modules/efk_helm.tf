resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }

  depends_on = [
    aws_eks_node_group.ng-private, 
    aws_eks_cluster.eks-cluster, 
    terraform_data.kubectl, 
  ]
}

resource "kubernetes_storage_class" "gp2_csi" {
  metadata {
    name = "gp2-csi"
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    type = "gp2"
  }

  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  namespace  = "logging"

  timeout = 600  # Increase this as needed (time in seconds)

  set {
    name  = "replicas"
    value = "2"
  }

   # Example override (if supported by the chart)
  set {
    name  = "hooks.configmapHelmScripts.enabled"
    value = "false"
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.storageClass"
    value = "gp2-csi"
  }

  set {
    name  = "persistence.size"
    value = "10Gi"
  }

  depends_on = [
    aws_eks_node_group.ng-private, 
    aws_eks_cluster.eks-cluster, 
    terraform_data.kubectl, 
    kubernetes_storage_class.gp2_csi  // Ensure StorageClass is created first
  ]
}

resource "helm_release" "fluent-bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = "logging"

  depends_on = [
    aws_eks_node_group.ng-private, 
    aws_eks_cluster.eks-cluster, 
    terraform_data.kubectl, 
  ]
}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  namespace  = "logging"

   set {
    name  = "hooks.preInstallServiceAccount.enabled"
    value = "false"
  }

  depends_on = [
    aws_eks_node_group.ng-private, 
    aws_eks_cluster.eks-cluster, 
    terraform_data.kubectl, 
  ]
}
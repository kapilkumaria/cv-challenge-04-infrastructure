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
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    type = "gp2"
  }

  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "time_sleep" "wait_for_storage_class" {
  depends_on = [kubernetes_storage_class.gp2_csi]
  create_duration = "120s" # Adjust as needed
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
  value = kubernetes_storage_class.gp2_csi.metadata[0].name # Explicitly reference the name 
  }

  set {
    name  = "persistence.size"
    value = "10Gi"
  }

  depends_on = [
    aws_eks_node_group.ng-private, 
    aws_eks_cluster.eks-cluster, 
    terraform_data.kubectl, 
    kubernetes_storage_class.gp2_csi,  // Ensure StorageClass is created first
    time_sleep.wait_for_storage_class,
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

# Clean up the pre-install rolebinding left by previous Helm operations
resource "null_resource" "cleanup_kibana_preinstall_rolebinding" {
  provisioner "local-exec" {
    command = "kubectl delete rolebinding pre-install-kibana-kibana -n logging --ignore-not-found"
  }
}

# Clean up the post-delete service account left by previous Helm operations
resource "null_resource" "cleanup_kibana_postdelete_serviceaccount" {
  provisioner "local-exec" {
    command = "kubectl delete serviceaccount post-delete-kibana-kibana -n logging --ignore-not-found"
  }
}

# Clean up the post-delete role left by previous Helm operations
resource "null_resource" "cleanup_kibana_postdelete_role" {
  provisioner "local-exec" {
    command = "kubectl delete role post-delete-kibana-kibana -n logging --ignore-not-found"
  }
}

# Clean up the configmap left over from previous Helm operations
resource "null_resource" "cleanup_kibana_configmap_helm_scripts" {
  provisioner "local-exec" {
    command = "kubectl delete configmap kibana-kibana-helm-scripts -n logging --ignore-not-found"
  }
}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  namespace  = "logging"

  # Disable the pre-install hook for the service account, if the chart supports it
  set {
    name  = "hooks.preInstallServiceAccount.enabled"
    value = "false"
  }

  # Disable the hook that manages the helm scripts configmap, if the chart supports it
  set {
    name  = "hooks.configmapHelmScripts.enabled"
    value = "false"
  }

  depends_on = [
    aws_eks_node_group.ng-private,
    aws_eks_cluster.eks-cluster,
    terraform_data.kubectl,
    null_resource.cleanup_kibana_preinstall_rolebinding,
    null_resource.cleanup_kibana_postdelete_serviceaccount,
    null_resource.cleanup_kibana_postdelete_role,
    null_resource.cleanup_kibana_configmap_helm_scripts,
  ]
}


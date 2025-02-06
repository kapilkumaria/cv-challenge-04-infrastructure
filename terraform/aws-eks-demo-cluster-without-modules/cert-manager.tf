# # Create cert-manager namespace
# resource "kubectl_manifest" "cert_manager_namespace" {
#   yaml_body = <<YAML
# apiVersion: v1
# kind: Namespace
# metadata:
#   name: cert-manager
# YAML
# }

# Ensure Terraform waits for EKS to be fully available
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }

  depends_on = [aws_eks_cluster.eks-cluster]
}

# Install cert-manager via Helm
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "v1.13.1"  # Use the latest version if needed

  set {
    name  = "installCRDs"
    value = "true"
  }
  
  depends_on = [aws_eks_cluster.eks-cluster, helm_release.nginx_ingress]
}

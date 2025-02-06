# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.eks.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
#     token                  = data.aws_eks_cluster_auth.eks.token
#   }
# }

# Create cert-manager namespace
resource "kubectl_manifest" "cert_manager_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
YAML
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

  depends_on = [kubectl_manifest.cert_manager_namespace]
}

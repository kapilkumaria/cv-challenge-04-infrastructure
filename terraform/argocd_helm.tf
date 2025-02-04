resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  depends_on = [module.eks]  # ✅ Ensure EKS is ready before installing Helm chart
}

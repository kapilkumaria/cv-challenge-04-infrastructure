resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  # depends_on = [null_resource.wait_for_eks]
  depends_on = [null_resource.wait_for_kubeconfig]
  
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  depends_on = [kubernetes_namespace.argocd]
  
}
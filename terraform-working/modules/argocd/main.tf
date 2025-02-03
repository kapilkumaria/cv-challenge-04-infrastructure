################################################################################
# ArgoCD Module Main Configuration 
################################################################################

### Create the Namespace First
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

### Install ArgoCD Helm Chart After CRDs Are Ready
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  wait = true

  depends_on = [kubernetes_namespace.argocd]
}

### Fetch the ArgoCD Service After Deployment
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"

    namespace = kubernetes_namespace.argocd.metadata[0].name


  }

  depends_on = [helm_release.argocd]
}

### Create the ArgoCD Application
resource "kubernetes_manifest" "argocd_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.app_name
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.repo_url
        targetRevision = "HEAD"
        path           = var.app_path
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
  depends_on = [helm_release.argocd]
}
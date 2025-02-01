################################################################################
# TERRAFORM ALB INGRESS CONTROLLER CONFIGURATION FILE
################################################################################

resource "kubernetes_namespace" "alb_ingress" {
  metadata {
    name = "alb-ingress"
  }
}

# Deploy AWS ALB Ingress Controller using Helm
resource "helm_release" "alb_ingress" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.5.3"
  namespace  = kubernetes_namespace.alb_ingress.metadata[0].name

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}

# ALB Ingress Resource for ArgoCD
resource "kubernetes_ingress_v1" "alb_ingress" {
  metadata {
    name      = "alb-ingress-argocd"
    namespace = "argocd"
    annotations = {
      "kubernetes.io/ingress.class"                      = "alb"
      "alb.ingress.kubernetes.io/scheme"                = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"           = "ip"
      "alb.ingress.kubernetes.io/listen-ports"          = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/certificate-arn"       = var.ssl_certificate_arn
      "alb.ingress.kubernetes.io/healthcheck-path"      = "/"
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      host = var.domain_name
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    tls {
      hosts       = [var.domain_name]
      secret_name = "alb-ingress-tls"
    }
  }
}

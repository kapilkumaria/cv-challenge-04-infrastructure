################################################################################
# TERRAFORM INGRESS CONTROLLER CONFIGURATION FILE
################################################################################

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
  }
}

# Deploy NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.4.2"
  namespace  = kubernetes_namespace.ingress.metadata[0].name

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}

# Create Ingress Resource for ArgoCD
resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "cert-manager.io/cluster-issuer"            = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect"  = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"
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
      secret_name = "argocd-tls"
    }
  }
}

resource "aws_route53_record" "argocd_dns" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.ingress_nginx_hostname  # ✅ Use variable instead
    zone_id                = var.ingress_nginx_zone_id  # ✅ Use variable instead
    evaluate_target_health = true
  }
}

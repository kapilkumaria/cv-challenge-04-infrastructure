# resource "helm_release" "kube-prometheus" {
#   name       = "kube-prometheus-stack"
#   namespace  = "monitoring"
#   create_namespace = true
#   version    = "68.4.3"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"

#   set {
#     name  = "prometheus.service.type"
#     value = "LoadBalancer"
#   }

#   set {
#     name  = "alertmanager.service.type"
#     value = "LoadBalancer"
#   }

#   set {
#     name  = "grafana.service.type"
#     value = "LoadBalancer"
#   }

#   depends_on = [
#     module.eks,
#     module.vpc
#   ]
# }

# # resource "kubernetes_namespace" "monitoring" {
# #   metadata {
# #     name = "monitoring"
# #   }
# # }

# data "kubernetes_service" "prometheus" {
#   metadata {
#     name      = "kube-prometheus-stack-prometheus"
#     namespace = helm_release.kube-prometheus.namespace
#   }

#   depends_on = [helm_release.kube-prometheus]
# }

# data "kubernetes_service" "alertmanager" {
#   metadata {
#     name      = "kube-prometheus-stack-alertmanager"
#     namespace = helm_release.kube-prometheus.namespace
#   }

#   depends_on = [helm_release.kube-prometheus] 
# }

# data "kubernetes_service" "grafana" {
#   metadata {
#     name      = "kube-prometheus-stack-grafana"
#     namespace = helm_release.kube-prometheus.namespace
#   }

#   depends_on = [helm_release.kube-prometheus] 
# }
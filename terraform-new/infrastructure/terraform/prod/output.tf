output "argocd_server_external_ip" {
  value = "http://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}"
  description = "The external IP or DNS name of the ArgoCD server LoadBalancer"
}

# output "prometheus_external_url" {
#   value       = "http://${data.kubernetes_service.prometheus.status[0].load_balancer[0].ingress[0].hostname}:9090"
#   description = "The external URL of the Prometheus LoadBalancer"
# }

# output "alertmanager_external_url" {
#   value       = "http://${data.kubernetes_service.alertmanager.status[0].load_balancer[0].ingress[0].hostname}:9093"
#   description = "The external URL of the Alertmanager LoadBalancer"
# }

# output "grafana_external_url" {
#   value       = "http://${data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname}"
#   description = "The external URL of the Grafana LoadBalancer"
# }

################################################################################
# TERRAFORM ARGOCD MODULE OUTPUTS FILE
################################################################################

output "argocd_server_url" {
  description = "External URL for ArgoCD Server"
  value       = data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname
}

output "argocd_application_name" {
  description = "The name of the deployed ArgoCD application"
  value       = var.app_name
}
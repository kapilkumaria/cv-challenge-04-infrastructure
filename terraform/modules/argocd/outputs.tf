################################################################################
# TERRAFORM ARGOCD MODULE OUTPUTS FILE
################################################################################

output "argocd_server_url" {
  description = "External URL for ArgoCD Server"
  value       = "http://${helm_release.argocd.name}.${var.namespace}.svc.cluster.local:80"
}

output "argocd_application_name" {
  description = "The name of the deployed ArgoCD application"
  value       = var.app_name
}

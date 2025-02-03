################################################################################
# ROOT OUTPUTS.TF
################################################################################

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "argocd_server_url" {
  description = "External URL for ArgoCD Server"
  value       = module.argocd.argocd_server_url
}

output "argocd_application_name" {
  description = "Name of the deployed ArgoCD application"
  value       = module.argocd.argocd_application_name
}
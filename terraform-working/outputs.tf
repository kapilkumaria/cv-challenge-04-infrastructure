################################################################################
# ROOT OUTPUTS.TF
################################################################################

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = module.eks.eks_cluster_endpoint
}
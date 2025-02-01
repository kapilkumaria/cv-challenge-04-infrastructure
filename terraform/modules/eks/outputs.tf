################################################################################
# TERRAFORM EKS MODULE OUTPUTS FILE
################################################################################

output "eks_cluster_id" {
  description = "EKS Cluster ID."
  value       = aws_eks_cluster.main.id
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API Endpoint."
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_ca" {
  description = "EKS Cluster Certificate Authority Data."
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "eks_node_group_id" {
  description = "EKS Node Group ID."
  value       = aws_eks_node_group.main.id
}

output "kubeconfig_file" {
  value = local_file.kubeconfig.filename
}
output "eks_cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.eks.eks_cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = module.eks.eks_cluster_arn
}

output "node_group_id" {
  description = "The ID of the EKS node group."
  value       = module.eks.node_group_id
}

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.eks.vpc_id
}

output "subnet_ids" {
  description = "The IDs of the public subnets."
  value       = module.eks.subnet_ids
}

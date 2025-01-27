output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "The IDs of the public subnets."
  value       = aws_subnet.public.*.id
}

output "eks_cluster_id" {
  description = "The ID of the EKS cluster."
  value       = aws_eks_cluster.main.id
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = aws_eks_cluster.main.arn
}

output "node_group_id" {
  description = "The ID of the EKS node group."
  value       = aws_eks_node_group.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_ready" {
  value = aws_eks_cluster.main.id # Ensures the cluster is fully created
  description = "Signal that the EKS cluster is ready"
}

output "kubeconfig_file" {
  value = "${path.module}/kubeconfig-${aws_eks_cluster.main.name}"
}

output "oidc_provider_url" {
  value = data.aws_iam_openid_connect_provider.eks.url
}

output "kubeconfig_file_path" {
  value = local_file.kubeconfig.filename
}

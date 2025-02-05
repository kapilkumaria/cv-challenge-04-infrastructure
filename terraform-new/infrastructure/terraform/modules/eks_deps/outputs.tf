output "eks_node_role_arn" {
  description = "The ARN of the EKS node IAM role"
  value       = aws_iam_role.eks_node.arn
}

output "eks_node_role_name" {
  description = "The name of the EKS node IAM role"
  value       = aws_iam_role.eks_node.name
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.eks.id
}
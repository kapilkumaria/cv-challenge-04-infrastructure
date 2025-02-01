################################################################################
# TERRAFORM OUTPUTS FILE
################################################################################

output "eks_cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.eks.eks_cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_ca" {
  description = "The certificate authority data for the cluster."
  value       = module.eks.eks_cluster_ca
}

# output "alb_ingress_hostname" {
#   description = "The ALB hostname for accessing services."
#   value       = module.alb_ingress.alb_hostname
# }

# output "route53_record" {
#   description = "The Route53 DNS record for the custom domain."
#   value       = module.route53.domain_name
# }

################################################################################
# TERRAFORM ALB INGRESS CONTROLLER VARIABLES FILE
################################################################################

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "domain_name" {
  description = "The custom domain name for ALB routing"
  type        = string
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate for HTTPS"
  type        = string
}

variable "hosted_zone_id" {
  description = "The Route53 Hosted Zone ID"
  type        = string
}

################################################################################
# TERRAFORM VARIABLES FILE
################################################################################

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "eks-cluster"
}

variable "subnet_count" {
  description = "The number of subnets to create."
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "The desired size of the node group."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "The maximum size of the node group."
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "The minimum size of the node group."
  type        = number
  default     = 1
}

variable "instance_types" {
  description = "The EC2 instance types for the node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "domain_name" {
  description = "The domain name for the ingress."
  type        = string
  default     = "kapilkumaria.com"
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate for HTTPS."
  type        = string
}

variable "hosted_zone_id" {
  description = "The Route53 hosted zone ID."
  type        = string
}


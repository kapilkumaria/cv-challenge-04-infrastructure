################################################################################
# ROOT VARIABLES.TF
################################################################################

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
  default     = 2
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "instance_types" {
  description = "Instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "argocd_namespace" {
  description = "Namespace to deploy ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
  default     = "5.46.8"
}

variable "argocd_app_name" {
  description = "Name of the ArgoCD application"
  type        = string
  default     = "my-app"
}

variable "argocd_repo_url" {
  description = "Git repository URL for the ArgoCD application"
  type        = string
  default     = "https://github.com/myorg/myrepo.git"
}

variable "argocd_app_path" {
  description = "Path to the application in the Git repository"
  type        = string
  default     = "path/to/app"
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate for the load balancer"
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "The ID of the Route 53 hosted zone"
  type        = string
  default     = ""
}
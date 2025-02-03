################################################################################
# TERRAFORM EKS MODULE VARIABLES FILE
################################################################################

variable "aws_region" {
  description = "AWS region to deploy EKS."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets to create."
  default     = 2
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster."
  default     = "eks-cluster"
}

variable "node_min_size" {
  description = "The minimum number of nodes in the autoscaling group."
  default     = 1
}

variable "node_max_size" {
  description = "The maximum number of nodes in the autoscaling group."
  default     = 3
}

variable "node_desired_size" {
  description = "The desired number of nodes in the autoscaling group."
  default     = 2
}

variable "instance_types" {
  description = "The instance types for EKS nodes."
  default     = ["t3.medium"]
}
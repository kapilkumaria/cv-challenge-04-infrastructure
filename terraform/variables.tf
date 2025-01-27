# variables.tf

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

# variable "instance_types" {
#   description = "The EC2 instance types for the node group."
#   type        = list(string)
#   default     = ["t3.xlarge"]
# }

# variable "instance_type" {
#   description = "The EC2 instance type for the bastion host."
#   type        = string
#   default    = "t3.micro"
# }
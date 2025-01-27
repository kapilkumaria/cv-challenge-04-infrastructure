variable "aws_region" {
  description = "The AWS region to deploy resources in."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "The name of the VPC."
  default     = "eks-vpc"
}

variable "subnet_count" {
  description = "The number of subnets to create."
  default     = 2
}

variable "internet_gateway_name" {
  description = "The name of the Internet Gateway."
  default     = "eks-internet-gateway"
}

variable "route_table_name" {
  description = "The name of the Route Table."
  default     = "eks-public-route-table"
}

variable "eks_cluster_role_name" {
  description = "The name of the EKS Cluster IAM role."
  default     = "eks-cluster-role"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
  default     = "eks-cluster"
}

variable "eks_node_role_name" {
  description = "The name of the EKS Node IAM role."
  default     = "eks-node-role"
}

variable "eks_node_group_name" {
  description = "The name of the EKS Node Group."
  default     = "eks-node-group"
}

variable "node_desired_size" {
  description = "The desired size of the node group."
  default     = 2
}

variable "node_max_size" {
  description = "The maximum size of the node group."
  default     = 3
}

variable "node_min_size" {
  description = "The minimum size of the node group."
  default     = 1
}

variable "instance_types" {
  description = "The EC2 instance types for the node group."
  default     = ["t2.large"]
}

variable "eks_role_arn" {
  description = "IAM Role ARN for the EKS cluster"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default    = "931058976119"
}

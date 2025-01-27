provider "aws" {
  region  = var.aws_region
  profile = "MyAWS"
}

module "eks" {
  source            = "./modules/eks"
  aws_region        = var.aws_region
  eks_role_arn      = "arn:aws:iam::931058976119:role/terraform-execution-role" # Pass the role
  vpc_cidr          = var.vpc_cidr
  eks_cluster_name  = var.eks_cluster_name
  node_desired_size = var.node_desired_size
  node_max_size     = var.node_max_size
  node_min_size     = var.node_min_size  
}
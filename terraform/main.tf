module "eks" {
  source           = "./modules/eks"
  aws_region       = var.aws_region
  vpc_cidr         = var.vpc_cidr
  eks_cluster_name = var.eks_cluster_name
  node_desired_size = var.node_desired_size
  node_max_size    = var.node_max_size
  node_min_size    = var.node_min_size
  instance_types   = var.instance_types
}

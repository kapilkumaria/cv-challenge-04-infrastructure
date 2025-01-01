provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "eks" {
  source           = "./modules/eks"
  aws_region       = var.aws_region
  aws_profile      = var.aws_profile # Pass aws_profile here
  vpc_cidr         = var.vpc_cidr
  eks_cluster_name = var.eks_cluster_name
  node_desired_size = var.node_desired_size
  node_max_size    = var.node_max_size
  node_min_size    = var.node_min_size
  instance_types   = var.instance_types
}

module "bastion" {
  source        = "./modules/bastion"
  vpc_id        = module.eks.vpc_id          # Reference EKS module output
  subnet_id     = module.eks.subnet_ids[0]   # Use the first public subnet
  # vpc_cidr      = module.eks.vpc_cidr        # Reference the VPC CIDR from the EKS module
  key_pair      = module.bastion.bastion_key_name # Reference output here
  # key_pair      = aws_key_pair.bastion_key.key_name
  # key_pair      = module.bastion.bastion_private_key   # SSH key pair for bastion
  instance_type = var.instance_type          # Bastion instance type
  allowed_cidr  = [module.eks.vpc_cidr] # Ensure this is a list
  # allowed_cidr  = module.eks.vpc_cidr        # Reference the VPC CIDR from the EKS module
  private_key_path  = "~/.ssh/bastion_key.pem"
}

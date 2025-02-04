module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.33.1" # Ensure you use a stable version
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  enable_irsa     = true
}

module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  cluster_name = module.eks.cluster_name
  cluster_service_cidr = module.eks.cluster_service_cidr # ✅ Add this line

  name = "eks-workers"
  subnet_ids = module.vpc.private_subnets
  min_size   = 1
  max_size   = 5
  desired_size = 2
  instance_types = ["t3.medium"]
}

# ✅ Add this missing data resource for authentication
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
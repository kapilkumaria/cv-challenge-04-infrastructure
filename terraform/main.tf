provider "aws" {
  region  = var.aws_region
  profile = "MyAWS"
}

provider "kubernetes" {
  config_path = "~/.kube/config" # Ensure this points to your kubeconfig file
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" # Ensure this points to your kubeconfig file
  }
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

# EFK Stack Module
module "efk" {
  source = "./modules/efk"

  # Variables for the EFK stack
  namespace = "logging" # Namespace for EFK stack
}

# ArgoCD Module
module "argocd" {
  source = "./modules/argocd"

  # Variables for ArgoCD
  namespace = "argocd" # Namespace for ArgoCD
  app_name  = "my-app" # Name of the ArgoCD application
  repo_url  = "https://github.com/myorg/myrepo.git" # Git repo URL
  app_path  = "path/to/app" # Path to the application in the Git repo
}

# Outputs
output "elasticsearch_endpoint" {
  value = module.efk.elasticsearch_endpoint
}

output "kibana_endpoint" {
  value = module.efk.kibana_endpoint
}

output "argocd_server_url" {
  value = module.argocd.argocd_server_url
}
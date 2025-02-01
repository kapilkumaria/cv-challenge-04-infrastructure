# terraform {
#   required_version = ">= 1.3.0"
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 5.0" # Update to the latest version or the version used to create the state
#     }
#     kubernetes = {
#       source  = "hashicorp/kubernetes"
#       version = "~> 2.0"
#     }
#     helm = {
#       source  = "hashicorp/helm"
#       version = "~> 2.0"
#     }
#   }
# }

# provider "aws" {
#   region = var.aws_region
# }

# provider "kubernetes" {
#   host                   = aws_eks_cluster.main.endpoint
#   cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.main.token
# }

# provider "helm" {
#   kubernetes {
#     host                   = aws_eks_cluster.main.endpoint
#     cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.main.token
#   }
# }

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0" # Update to the latest version or the version used to create the state
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# # Fetch EKS Cluster Auth Token
# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.eks_cluster_name
# }

# Kubernetes Provider Configuration
provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_ca)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Helm Provider Configuration
provider "helm" {
  kubernetes {
    host                   = module.eks.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.eks_cluster_ca)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"  # ✅ Use a stable version
    }
  }
  backend "s3" {
    bucket = "my-terraform-infra-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
    //  dynamodb_table = "my-terraform-infra-table"
    use_lockfile = "true"
  }

}

provider "aws" {
  # Configuration options
  region = var.region
}

# Wait for EKS to be ready before using Kubernetes
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.eks-cluster.name
  depends_on = [aws_eks_cluster.eks-cluster]
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks-cluster.name
}
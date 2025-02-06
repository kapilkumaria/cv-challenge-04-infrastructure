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

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}

data "aws_eks_cluster" "cluster" {
  name = "my-eks-cluster"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "my-eks-cluster"
}

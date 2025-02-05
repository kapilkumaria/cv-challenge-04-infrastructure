# resource "kubernetes_namespace" "kube_system" {
#   metadata {
#     name = "kube-system"
#   }
# }

# resource "null_resource" "update_kubeconfig" {
#   provisioner "local-exec" {
#     command = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
#     environment = {
#       KUBE_CONFIG_PATH = "~/.kube/config"
#     }
#   }
#   depends_on = [module.eks]
# }

module "vpc" {
  source          = "../modules/vpc"
  cidr_block      = "10.0.0.0/16"
  name            = "prod-vpc"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "eks_deps" {
  source       = "../modules/eks_deps"
  cluster_name = "prod-cluster"
  vpc_id       = module.vpc.vpc_id
  tags = {
    Environment = "production"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "prod-cluster"
  cluster_version = "1.31"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnet_ids
  control_plane_subnet_ids = module.vpc.public_subnet_ids # For public endpoint edit later

  # EKS Addons configuration
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }


  eks_managed_node_groups = {
    prod-nodes = {
      desired_capacity = 3 # This value is ignored after the initial creation of the node group
      max_capacity     = 5
      min_capacity     = 2
      instance_type    = "t3.medium"
      node_role_arn    = module.eks_deps.eks_node_role_arn
    }
  }

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  enable_irsa = true

  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "production"
  }
}


module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name          = module.eks.cluster_name
  enable_v1_permissions = true

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = "prod-cluster-karpenter-node-role"
  create_pod_identity_association = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Environment = "production"
  }
}

module "karpenter_disabled" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  create = false
}



################################################################################
# Karpenter Helm chart & manifests
# Not required; just to demonstrate functionality of the sub-module
################################################################################

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws
}

resource "helm_release" "karpenter" {
  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "1.1.1"
  wait                = false

  values = [
    <<-EOT
    nodeSelector:
      karpenter.sh/controller: 'true'
    dnsPolicy: Default
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    webhook:
      enabled: false
    EOT
  ]
}

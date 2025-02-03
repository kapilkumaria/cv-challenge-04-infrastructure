data "aws_availability_zones" "available" {}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = var.eks_cluster_name
    Environment = "production"
  }
}

# Public & Private Subnets
resource "aws_subnet" "public" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = { Name = "eks-public-subnet-${count.index}" }
}

resource "aws_subnet" "private" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + var.subnet_count)
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = { Name = "eks-private-subnet-${count.index}" }
}

# Internet Gateway & NAT Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "eks-igw" }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "eks-nat" }
}

resource "aws_eip" "nat" {}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "eks-public-route-table" }
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = { Name = "eks-private-route-table" }
}

resource "aws_route_table_association" "private" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "eks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
  }
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"] # AWS default thumbprint
  url             = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "ebs_csi_role" {
  name = "AmazonEBSCSIRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/oidc.eks.${var.aws_region}.amazonaws.com/id/${var.oidc_id}"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "oidc.eks.${var.aws_region}.amazonaws.com/id/${var.oidc_id}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}


resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}



resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = var.instance_types

  tags = {
    Name = "eks-node-group"
  }
}

resource "helm_release" "aws_ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.16.0"

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.ebs_csi_role.arn
  }

  depends_on = [aws_iam_role.ebs_csi_role]
}



# 🔹 Create a StorageClass with Immediate Binding Mode
resource "kubernetes_storage_class" "gp2_immediate" {
  metadata {
    name = "gp2-immediate"
  }
  
  storage_provisioner = "kubernetes.io/aws-ebs"  # ✅ Fix: Corrected the argument name
  reclaim_policy = "Delete"
  volume_binding_mode = "Immediate"
}

# 🔹 Create an EBS Volume for Persistent Storage
resource "aws_ebs_volume" "elasticsearch_volume" {
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  size             = 10
  type             = "gp2"

  tags = {
    Name = "elasticsearch-ebs-volume"
  }
}

# IAM Role for EKS Nodes
resource "aws_iam_role" "eks_node" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach required policies to the EKS node role
resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}


# Outputs
output "eks_cluster_id" { value = aws_eks_cluster.main.id }
output "eks_cluster_endpoint" { value = aws_eks_cluster.main.endpoint }
output "storage_class" { value = kubernetes_storage_class.gp2_immediate.metadata[0].name }
output "ebs_volume_id" { value = aws_ebs_volume.elasticsearch_volume.id }

variable "aws_region" {
  description = "AWS region to deploy EKS."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets to create."
  default     = 2
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster."
  default     = "eks-cluster"
}

variable "node_min_size" {
  description = "The minimum number of nodes in the autoscaling group."
  default     = 1
}

variable "node_max_size" {
  description = "The maximum number of nodes in the autoscaling group."
  default     = 3
}

variable "node_desired_size" {
  description = "The desired number of nodes in the autoscaling group."
  default     = 2
}

variable "instance_types" {
  description = "The instance types for EKS nodes."
  default     = ["t3.medium"]
}



variable "aws_account_id" {
  default = "931058976119"
}

variable "oidc_id" {
  default = "F270F559ECFB82172C9C2BF2DDB86341" # Replace this with your actual OIDC ID
}

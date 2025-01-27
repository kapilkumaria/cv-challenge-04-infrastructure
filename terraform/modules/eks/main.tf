provider "aws" {
  region  = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::931058976119:role/terraform-execution-role" # Replace with your account ID
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.main.token  
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }

  depends_on = [aws_eks_cluster.main] # Ensure the cluster is ready before applying.
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [aws_eks_cluster.main] # Ensure the cluster is ready before applying.
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

# Data Source for Availability Zones
data "aws_availability_zones" "available" {}

# Subnets
resource "aws_subnet" "public" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "eks-public-subnet-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.internet_gateway_name
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = var.route_table_name
  }
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "public" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster" {
  name = var.eks_cluster_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
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

  version = "1.27" # Specify Kubernetes version here

  vpc_config {
    subnet_ids = aws_subnet.public.*.id
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name = var.eks_cluster_name
  }
}

# Node IAM Role
resource "aws_iam_role" "eks_node" {
  name = var.eks_node_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        groups   = ["system:bootstrappers", "system:nodes"]
        rolearn  = aws_iam_role.eks_node.arn
        username = "system:node:{{EC2PrivateDNSName}}"
      },
      {
        groups   = ["system:masters"]
        rolearn  = "arn:aws:iam::931058976119:role/AdministratorRole" # Replace with the actual admin role
        username = "admin"
      }
    ])

    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::931058976119:user/kapil" # Replace with your admin user
        username = "admin"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [aws_eks_cluster.main]
}

resource "aws_iam_role_policy_attachment" "eks_node" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.eks_node_group_name
  node_role_arn   = aws_iam_role.eks_node.arn

  subnet_ids = aws_subnet.public.*.id

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = var.instance_types
  ami_type       = "AL2_x86_64" # Amazon Linux 2 EKS Optimized AMI

  tags = {
    Name = var.eks_node_group_name
  }

  timeouts {
    delete = "30m"
  }
}

resource "null_resource" "clean_kube_folder" {
  provisioner "local-exec" {
    command = "rm -rf ~/.kube && mkdir -p ~/.kube"
  }
}

resource "local_file" "kubeconfig" {
  filename = "${path.module}/kubeconfig-${aws_eks_cluster.main.name}"

  content = <<EOF
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.main.endpoint}
    certificate-authority-data: ${aws_eks_cluster.main.certificate_authority.0.data}
  name: ${aws_eks_cluster.main.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.main.name}
    user: ${aws_eks_cluster.main.name}
  name: ${aws_eks_cluster.main.name}
current-context: ${aws_eks_cluster.main.name}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.main.name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - eks
        - get-token
        - --cluster-name
        - ${aws_eks_cluster.main.name}
        - --region
        - ${var.aws_region}
EOF

  depends_on = [null_resource.clean_kube_folder]
}

# Optional: Copy kubeconfig to ~/.kube/config
resource "null_resource" "copy_kubeconfig" {
  provisioner "local-exec" {
    command = "mkdir -p ~/.kube && cp ${local_file.kubeconfig.filename} ~/.kube/config"
  }

  depends_on = [local_file.kubeconfig]
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name              = aws_eks_cluster.main.name
  addon_name                = "aws-ebs-csi-driver"
  addon_version             = "v1.37.0-eksbuild.1"
  service_account_role_arn  = aws_iam_role.ebs_csi_driver.arn

  tags = {
    Name = "ebs-csi-driver"
  }

  depends_on = [aws_eks_cluster.main] # Ensures cluster is ready
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"

  lifecycle {
    # Ignore changes to ensure smooth recreation
    ignore_changes = [role]
  }
}

resource "kubernetes_service_account" "ebs_csi_controller_sa" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_driver.arn
    }
  }

  lifecycle {
    ignore_changes = [metadata]
  }

  depends_on = [aws_eks_cluster.main] # Ensure the cluster is ready before creating the service account
}

data "aws_eks_cluster" "main" {
  name = aws_eks_cluster.main.name
}

data "aws_iam_openid_connect_provider" "eks" {
  arn = "arn:aws:iam::${var.aws_account_id}:oidc-provider/${replace(data.aws_eks_cluster.main.identity.0.oidc.0.issuer, "https://", "")}"
}

resource "aws_iam_role" "ebs_csi_driver" {
  name = "AmazonEKS_EBS_CSI_DriverRole-${random_string.suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.eks.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.main.identity.0.oidc.0.issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa",
            "${replace(data.aws_eks_cluster.main.identity.0.oidc.0.issuer, "https://", "")}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  # Explicit dependencies to ensure OIDC provider and cluster are ready
  depends_on = [
    aws_iam_openid_connect_provider.eks
    # data.aws_eks_cluster.main
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.main.name
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]
  url            = data.aws_eks_cluster.main.identity.0.oidc.0.issuer
  thumbprint_list = ["9E99A48A9960B14926BB7F3B02E22DA1D7123F10"]

  depends_on = [aws_eks_cluster.main]
}
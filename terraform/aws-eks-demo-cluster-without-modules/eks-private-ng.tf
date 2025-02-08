
resource "aws_eks_node_group" "ng-private" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "my-eks-nodegroup"
  node_role_arn   = aws_iam_role.ng-role.arn

  version = var.cluster_version
  subnet_ids = [
    aws_subnet.private-subnet-1.id,
    aws_subnet.private-subnet-2.id,
  ]
  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 2
  }

  remote_access {
    ec2_ssh_key = aws_key_pair.tf-key-pair.key_name
  }

  instance_types = var.instance_types
  capacity_type  = "ON_DEMAND"
  ami_type       = "AL2_x86_64"
  disk_size      = 20



  update_config {
    max_unavailable = 1 # Update one node at a time
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = {
    Name                                            = "Private-Node-Group"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = "TRUE"
  }
}

resource "terraform_data" "kubectl" {

  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"
  }
  
  depends_on = [aws_eks_cluster.eks-cluster,
    aws_eks_node_group.ng-private,
  ]
}

# resource "aws_iam_role" "ng-role" {
#   name = "eks-private-node-group-role"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# # EKS Cluster
# resource "aws_eks_cluster" "eks-cluster" {
#   name = var.cluster_name

#   access_config {
#     authentication_mode = "API"
#   }

#   role_arn = aws_iam_role.cluster.arn
#   version  = var.cluster_version
#   vpc_config {
#     endpoint_private_access = false
#     endpoint_public_access  = true
#     public_access_cidrs     = ["0.0.0.0/0"]
#     subnet_ids = [
#       aws_subnet.public-subnet-1.id,
#       aws_subnet.public-subnet-2.id,
#     ]
#     security_group_ids = [
#       aws_security_group.kubernetes_master.id
#     ]
#   }

#   kubernetes_network_config {
#     service_ipv4_cidr = "172.20.0.0/16"
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
#     aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController
#   ]

#   tags = {
#     Name = var.cluster_name
#   }
# }

# Extract the OIDC provider URL from the EKS cluster
locals {
  oidc_provider_url = replace(aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://", "")
}

# Create the IAM role with updated trust relationship
resource "aws_iam_role" "ng-role" {
  name = "eks-private-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::931058976119:oidc-provider/${local.oidc_provider_url}"
        }
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ng-role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.ng-role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ng-role.name
}

resource "aws_iam_role_policy_attachment" "CA-AutoScalingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.ng-role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ng-role.name  # Ensure this references your worker node role
}

# resource "aws_iam_role_policy_attachment" "ebs_csi_iam_role_policy_attach" {
#   policy_arn = aws_iam_policy.ebs_csi_iam_policy.arn
#   role       = aws_iam_role.ng-role.name  # Ensure this references your worker node role
# }
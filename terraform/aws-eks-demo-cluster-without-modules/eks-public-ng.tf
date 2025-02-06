/*
resource "aws_eks_node_group" "ng-public" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "my-eks-nodegroup-public"
  node_role_arn   = aws_iam_role.public-ng-role.arn
  subnet_ids = [
    aws_subnet.public-subnet-1.id,
    aws_subnet.public-subnet-2.id,
  ]
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  remote_access {
    ec2_ssh_key = aws_key_pair.tf-key-pair.key_name
  }

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"
  ami_type       = "AL2_x86_64"
  disk_size      = 20



  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.public-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.public-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.public-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role.public-ng-role,
  ]
  tags = {
    Name = "Public-Node-Group"
  }

}

resource "aws_iam_role" "public-ng-role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "public-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.public-ng-role.name
}

resource "aws_iam_role_policy_attachment" "public-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.public-ng-role.name
}

resource "aws_iam_role_policy_attachment" "public-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.public-ng-role.name
}
*/
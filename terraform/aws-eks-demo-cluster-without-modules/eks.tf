# resource "null_resource" "wait_for_eks" {
#   depends_on = [aws_eks_cluster.eks-cluster]

#   provisioner "local-exec" {
#     command = <<EOT
#       echo "Waiting for EKS to be ready..."
#       for i in {1..10}; do
#         if aws eks update-kubeconfig --name my-eks-cluster --region us-east-1; then
#           echo "EKS is ready!"
#           exit 0
#         fi
#         echo "Retrying in 20 seconds..."
#         sleep 20
#       done
#       echo "EKS did not become ready in time"
#       exit 1
#     EOT
#   }
# }

resource "null_resource" "wait_for_eks" {
  depends_on = [aws_eks_cluster.eks-cluster]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for EKS to be ready..."
      MAX_ATTEMPTS=30
      INTERVAL=30

      for ((i=1; i<=MAX_ATTEMPTS; i++)); do
        echo "Attempt $i/$MAX_ATTEMPTS: Checking EKS status..."
        
        if aws eks update-kubeconfig --name my-eks-cluster --region us-east-1; then
          echo "✅ EKS is ready!"
          exit 0
        fi

        echo "❌ EKS not ready yet. Retrying in $INTERVAL seconds..."
        sleep $INTERVAL
      done

      echo "🚨 ERROR: EKS did not become ready after $((MAX_ATTEMPTS * INTERVAL / 60)) minutes."
      exit 1
    EOT
  }
}


resource "aws_eks_cluster" "eks-cluster" {
  name = var.cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version
  vpc_config {

    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids = [
      aws_subnet.public-subnet-1.id,
      aws_subnet.public-subnet-2.id,
    ]
    security_group_ids = [
      aws_security_group.kubernetes_master.id
    ]
  }


  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController
  ]

  tags = {
    #  "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    Name = var.cluster_name

  }

}

# ✅ Ensure EKS is ready and kubeconfig is updated before Terraform uses Helm
resource "null_resource" "wait_for_kubeconfig" {
  depends_on = [null_resource.wait_for_eks]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for kubeconfig to be set up..."
      sleep 60  # Delay to ensure kubeconfig is fully updated
    EOT
  }
}

# resource "null_resource" "wait_for_eks" {
#   depends_on = [aws_eks_cluster.eks-cluster]

#   provisioner "local-exec" {
#     command = <<EOT
#       echo "Waiting for EKS to be ready..."
#       for i in {1..10}; do
#         if aws eks update-kubeconfig --name my-eks-cluster --region us-east-1; then
#           echo "EKS is ready!"
#           exit 0
#         fi
#         echo "Retrying in 20 seconds..."
#         sleep 20
#       done
#       echo "EKS did not become ready in time"
#       exit 1
#     EOT
#   }
# }



resource "aws_iam_role" "cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}



data "aws_iam_user" "devops" {
  user_name = "kapil"
}

# data "aws_iam_user" "eksdeveloper" {
#   user_name = "eksdeveloper"
# }

resource "aws_eks_access_entry" "example" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  principal_arn = data.aws_iam_user.devops.arn
  #kubernetes_groups = ["system:masters"]
  type = "STANDARD"
}

# resource "aws_eks_access_entry" "eksdeveloper" {
#   cluster_name      = aws_eks_cluster.eks-cluster.name
#   principal_arn     = data.aws_iam_user.eksdeveloper.arn
#   kubernetes_groups = ["developer-group"]
#   type              = "STANDARD"
# }

resource "aws_eks_access_policy_association" "eks-cluster-admin-policy-1" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = data.aws_iam_user.devops.arn

  access_scope {
    type = "cluster"
    # namespaces = ["example-namespace"]
  }
  depends_on = [aws_eks_access_entry.example]
}


resource "aws_eks_access_policy_association" "eks-cluster-admin-policy-2" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_iam_user.devops.arn

  access_scope {
    type = "cluster"
    # namespaces = ["example-namespace"]
  }
  depends_on = [aws_eks_access_entry.example]
}

/*
resource "aws_eks_access_policy_association" "eks-admin-policy-3" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = data.aws_iam_user.eksdeveloper.arn

  access_scope {
    type = "namespace"
     namespaces = ["default"]
  }
  depends_on = [aws_eks_access_entry.example]
}
*/

output "user_arn" {
  value = data.aws_iam_user.devops.arn
}

# output "user_arn_eksdeveloper" {
#   value = data.aws_iam_user.eksdeveloper.arn
# }

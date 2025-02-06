resource "aws_eks_addon" "eks-addon" {

  for_each     = toset(["coredns", "vpc-cni", "kube-proxy", "eks-pod-identity-agent"])
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = each.key
}

# below installation from the aws documentation https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/


resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = aws_eks_cluster.eks-cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.38.1-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_iam_role.arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}
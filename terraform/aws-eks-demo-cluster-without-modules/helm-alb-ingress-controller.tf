
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}



resource "helm_release" "alb_ingress" {

  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = true
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "vpcId"
    value = aws_vpc.eks-vpc.id # Replace with your VPC ID
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_ingress_controller_iam_role.arn # Link to the created IAM role
  }

  depends_on = [
    aws_eks_node_group.ng-private,
    aws_eks_cluster.eks-cluster, # Ensure EKS cluster is created first
    aws_iam_role.alb_ingress_controller_iam_role,
    aws_iam_role_policy_attachment.alb_controller_iam_role_policy_attach,
    terraform_data.kubectl,
  ]
}

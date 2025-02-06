# Ensure kube-system namespace exists
resource "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
  }

  depends_on = [aws_eks_cluster.eks-cluster]
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"
  
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb" # Use AWS NLB for better performance
  }

  set {
    name  = "controller.ingressClass"
    value = "nginx"
  }

  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx"
  }

  set {
    name  = "controller.ingressClassResource.controller"
    value = "k8s.io/ingress-nginx"
  }
  
  depends_on = [
    aws_eks_node_group.ng-private, # Added dependency on node group to ensure the node group is created before the helm chart is deployed
    aws_eks_cluster.eks-cluster, # Added dependency on EKS cluster to ensure the EKS cluster is created before the helm chart is deployed
    terraform_data.kubectl, # Added dependency on kubectl data source to ensure kubectl is available before the helm chart is deployed
  ]
}

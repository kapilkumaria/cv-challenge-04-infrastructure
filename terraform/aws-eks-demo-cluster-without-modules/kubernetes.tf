
/*
resource "kubernetes_cluster_role_v1" "eks-cluster-role" {
  metadata {
    name = "my-eks-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list"]
  }
   depends_on = [aws_eks_access_policy_association.eks-cluster-admin-policy-1, aws_eks_access_policy_association.eks-cluster-admin-policy-2]
}

resource "kubernetes_cluster_role_binding_v1" "some_role_binding" {
  metadata {
    name = "eks-role-name-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.eks-cluster-role.metadata[0].name
  }

  subject {
    kind = "User"
    name = "devops" # or whatever the user name is
  }
    depends_on = [ aws_eks_access_policy_association.eks-cluster-admin-policy-1, 
         aws_eks_access_policy_association.eks-cluster-admin-policy-2,
         terraform_data.kubectl,
    ]
}
*/
resource "kubernetes_cluster_role_binding" "kapil_cluster_admin" {
  metadata {
    name = "kapil-admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = "arn:aws:iam::931058976119:user/kapil"
    api_group = "rbac.authorization.k8s.io"
  }
}

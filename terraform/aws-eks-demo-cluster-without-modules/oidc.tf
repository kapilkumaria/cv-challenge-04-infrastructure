
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.eks-cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity.0.oidc.0.issuer
  depends_on      = [aws_eks_cluster.eks-cluster]
}


output "tls_certificate" {
  value = data.tls_certificate.cluster
}


output "aws_iam_openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.cluster.arn
}

output "aws_iam_openid_connect_provider_url" {
  value = aws_iam_openid_connect_provider.cluster.url
}


/*
data "aws_iam_openid_connect_provider" "example" {
  arn = "arn:aws:iam::123456789012:oidc-provider/accounts.google.com"
}
*/
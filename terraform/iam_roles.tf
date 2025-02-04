resource "aws_iam_role" "fluentbit_role" {
  name = "eks-fluentbit-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:fluent-bit"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fluentbit_logs" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.fluentbit_role.name
}

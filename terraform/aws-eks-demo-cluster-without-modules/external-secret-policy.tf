resource "aws_iam_policy" "external_secret_policy" {
  name        = "External-Secret-Policy"
  path        = "/"
  description = "External-Secret-Policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowAccessToSecretsManager",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:ListSecrets",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource" : "arn:aws:secretsmanager:${var.region}:${var.accountid}:secret:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_secret_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.external_secret_policy.arn
  role       = aws_iam_role.ng-role.name
}
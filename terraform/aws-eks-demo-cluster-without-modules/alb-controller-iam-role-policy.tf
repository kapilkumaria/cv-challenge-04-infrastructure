// Reference link for aws doc to install alb ingress controller - https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html

data "http" "alb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

resource "aws_iam_policy" "alb_controller_iam_policy" {
  name        = "alb_controller_iam_policy"
  description = "ALB Ingress Controller Policy"
  policy      = data.http.alb_controller_policy.response_body
}

resource "aws_iam_role" "alb_ingress_controller_iam_role" {
  name = "alb_ingress_controller_iam_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${aws_iam_openid_connect_provider.cluster.url}:sub" : "system:serviceaccount:default:aws-load-balancer-controller"
          "${aws_iam_openid_connect_provider.cluster.url}:aud" : "sts.amazonaws.com"
        }
      }
      Effect = "Allow"
      Principal = {
        Federated = "${aws_iam_openid_connect_provider.cluster.arn}"
      }
    }]
    Version = "2012-10-17"
  })

  tags = {
    Name = "alb_ingress_controller_iam_role"
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.alb_controller_iam_policy.arn
  role       = aws_iam_role.alb_ingress_controller_iam_role.name
}

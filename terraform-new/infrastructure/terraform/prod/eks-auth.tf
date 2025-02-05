# resource "kubectl_manifest" "aws_auth_configmap" {
#   yaml_body = <<YAML
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: aws-auth
#   namespace: kube-system
# data:
#   mapRoles: |
#     - groups:
#       - system:bootstrappers
#       - system:nodes
#       rolearn: arn:aws:iam::931058976119:role/eksctl-prod-eks-cluster-nodegroup-NodeInstanceRole-1JZ2ZQ6ZQZQZ      
#       username: system:node:{{EC2PrivateDNSName}}
#   mapUsers: |
#     - userarn: arn:aws:iam::931058976119:user/kapil
#       username: kapil
#       groups:
#         - system:masters
# YAML
# }

data "aws_caller_identity" "current" {}


resource "kubectl_manifest" "aws_auth_configmap" {
  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
%{for name, group in module.eks.eks_managed_node_groups}
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: ${group.iam_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
%{endfor}
  mapUsers: |
    - userarn: ${data.aws_caller_identity.current.arn}
      username: kapil
      groups:
        - system:masters
YAML
}

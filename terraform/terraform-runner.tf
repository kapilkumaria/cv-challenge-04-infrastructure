# resource "aws_instance" "terraform_runner" {
#   ami           = "ami-0abcdef1234567890"  # Replace with latest Amazon Linux AMI
#   instance_type = "t3.medium"
#   subnet_id     = module.vpc.public_subnets[0]
#   security_groups = [aws_security_group.terraform_sg.id]
#   iam_instance_profile = aws_iam_instance_profile.terraform_profile.name

#   tags = {
#     Name = "terraform-runner"
#   }
# }

# resource "aws_iam_role" "terraform_role" {
#   name = "terraform-runner-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# resource "aws_iam_instance_profile" "terraform_profile" {
#   name = "terraform-runner-profile"
#   role = aws_iam_role.terraform_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_admin" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.terraform_role.name
# }

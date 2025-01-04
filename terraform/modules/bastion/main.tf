# Upload Public Key to AWS
resource "aws_key_pair" "bastion_key" {
  public_key = file("~/.ssh/id_rsa.pub")
}

# IAM Role for Bastion Host
resource "aws_iam_role" "bastion_role" {
  name = "bastion-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "eks_access_policy" {
  name        = "eks-access-policy"
  description = "Policy for accessing EKS cluster"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:AccessKubernetesApi"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_eks_access" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.eks_access_policy.arn
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-eks-instance-profile"
  role = aws_iam_role.bastion_role.name
}

# Provision Bastion Host
resource "aws_instance" "bastion" {
  ami           = "ami-0e2c8caa4b6378d8c"
  instance_type = var.instance_type
  key_name      = aws_key_pair.bastion_key.key_name
  subnet_id     = var.subnet_id

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  user_data = <<-EOF
    #!/bin/bash
    set -e  # Exit immediately if any command fails
    apt-get update -y
    apt-get install -y software-properties-common
    apt-add-repository --yes --update ppa:ansible/ansible
    apt-get install -y ansible docker.io git unzip curl python3-pip python3.12-venv
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    systemctl start docker
    systemctl enable docker
  EOF

  tags = {
    Name = "bastion-host"
  }

  vpc_security_group_ids = [aws_security_group.bastion.id]

  # Commented this LATEST
#   provisioner "file" {
#     source      = "/home/kapil/.kube/config"
#     destination = "/home/ubuntu/.kube/config"

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file("~/.ssh/id_rsa")
#       host        = self.public_ip
#     }
#   }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.kube",
      "mv /home/ubuntu/.kube/config ~/.kube/config",
      "chmod 600 ~/.kube/config",
      "sleep 120",  # Wait for 2 minutes
      "git clone https://github.com/kapilkumaria/cv-challenge-04-infrastructure.git /home/ubuntu/cv-challenge",
      "cd /home/ubuntu/cv-challenge/ansible",
      # "ansible-playbook -i inventory/inventory.ini playbooks/install_argocd.yaml",
      # "ansible-playbook -i inventory/inventory.ini playbooks/deploy_efk.yaml",
      # "ansible-playbook -i inventory/inventory.ini playbooks/setup_monitoring.yaml",
      # "ansible-playbook -i inventory/inventory.ini playbooks/setup_apps.yaml"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
      timeout     = "10m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.kube",
      "mv /home/ubuntu/.kube/config ~/.kube/config",
      "chmod 600 ~/.kube/config",
      "sleep 120",  # Wait for 2 minutes
      "git clone https://github.com/kapilkumaria/cv-challenge-04-infrastructure.git /home/ubuntu/cv-challenge",
      "cd /home/ubuntu/cv-challenge/ansible",
      # "ansible-playbook -i inventory/inventory.ini playbooks/install_argocd.yaml",
      # "ansible-playbook -i inventory/inventory.ini playbooks/deploy_efk.yaml",
      # "ansible-playbook -i inventory/inventory.ini playbooks/setup_monitoring.yaml",
      # "ansible-playbook -i inventory/inventory.ini playbooks/setup_apps.yaml"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
      timeout     = "10m"
    }
  }
}

# Create Security Group for Bastion Host
resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Allow SSH access to bastion host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["50.66.177.15/32"] # Replace <your-public-ip> with your actual IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

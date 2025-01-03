# Generate SSH Key Pair
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Upload Public Key to AWS
resource "aws_key_pair" "bastion_key" {
  #key_name   = var.key_pair_name
  public_key = tls_private_key.bastion_key.public_key_openssh
}

# Save Private Key Locally
resource "local_file" "bastion_private_key" {
  content  = tls_private_key.bastion_key.private_key_pem
  filename = var.private_key_path
  # filename = "~/.ssh/bastion_key.pem" # Updated secure path
  # filename = "${path.module}/bastion_key.pem"
}

# Set Permissions on Private Key
resource "null_resource" "set_key_permissions" {
  provisioner "local-exec" {
    command = "chmod 600 ${local_file.bastion_private_key.filename}"
  }

  depends_on = [local_file.bastion_private_key]
}

# resource "aws_instance" "bastion" {
#   ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
#   instance_type = var.instance_type
#   # key_name      = aws_key_pair.bastion_key.key_name # Use the generated key pair
#   key_name      = aws_key_pair.bastion_key.key_name # Use the generated key pair

#   subnet_id     = var.subnet_id

#   user_data = <<-EOF
#     #!/bin/bash
#     yum update -y
#     yum install -y docker git
#     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#     chmod +x kubectl
#     mv kubectl /usr/local/bin/
#     curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
#     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#     unzip awscliv2.zip
#     sudo ./aws/install
#     systemctl start docker
#     systemctl enable docker
#   EOF

#   tags = {
#     Name = "bastion-host"
#   }

#   # security_groups = [aws_security_group.bastion.id]
#   vpc_security_group_ids = [aws_security_group.bastion.id]
# }

# resource "aws_instance" "bastion" {
#   # ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
#   ami           = "ami-0e2c8caa4b6378d8c" # Amazon Ubuntu 24.04
#   instance_type = var.instance_type
#   key_name      = aws_key_pair.bastion_key.key_name
#   subnet_id     = var.subnet_id

#   user_data = <<-EOF
#     #!/bin/bash
#     yum update -y
#     yum install -y docker git
#     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#     chmod +x kubectl
#     mv kubectl /usr/local/bin/
#     curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
#     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#     unzip awscliv2.zip
#     sudo ./aws/install
#     systemctl start docker
#     systemctl enable docker
#   EOF

#   tags = {
#     Name = "bastion-host"
#   }

#   vpc_security_group_ids = [aws_security_group.bastion.id]

#   # Add the remote-exec provisioner
#   provisioner "remote-exec" {
#     inline = [
#       # Install Git and Ansible
#       "sudo apt-get update",
#       "sudo apt-get install -y git ansible python3-pip",
#       "sudo apt install python3.12-venv",
#       "python3 -m venv myenv",
#       "source myenv/bin/activate",
#       "pip install boto boto3",
#       # Clone the repository
#       "git clone https://github.com/kapilkumaria/cv-challenge-04-infrastructure.git",
#       "cd /home/ubuntu/cv-challenge-04-infrastructure",
#       # Install additional tools like kubectl and Helm
#       "curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"",
#       "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl", 
#       "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3",
#       "chmod 700 get_helm.sh",
#       "./get_helm.sh",     
#       # Execute Ansible playbooks
#       "cd /home/ubuntu/repo/ansible",
#       "ansible-playbook -i inventory/inventory.ini playbooks/install_argocd.yaml",
#       "ansible-playbook -i inventory/inventory.ini playbooks/deploy_efk.yaml",
#       "ansible-playbook -i inventory/inventory.ini playbooks/setup_monitoring.yaml",
#       "ansible-playbook -i inventory/inventory.ini playbooks/setup_apps.yaml"
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file(var.private_key_path)
#       host        = self.public_ip
#     }
#   }
# }

resource "aws_instance" "bastion" {
  ami           = "ami-0e2c8caa4b6378d8c" # Ubuntu 24.04
  instance_type = var.instance_type
  key_name      = aws_key_pair.bastion_key.key_name
  subnet_id     = var.subnet_id

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io git unzip curl python3-pip python3.12-venv
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

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/kapilkumaria/cv-challenge-04-infrastructure.git /home/ubuntu/cv-challenge",
      "cd /home/ubuntu/cv-challenge/ansible",
      "ansible-playbook -i inventory/inventory.ini playbooks/install_argocd.yaml",
      "ansible-playbook -i inventory/inventory.ini playbooks/deploy_efk.yaml",
      "ansible-playbook -i inventory/inventory.ini playbooks/setup_monitoring.yaml",
      "ansible-playbook -i inventory/inventory.ini playbooks/setup_apps.yaml"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

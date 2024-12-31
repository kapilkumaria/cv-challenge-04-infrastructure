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
  filename = "${path.module}/bastion_key.pem"
}

# Set Permissions on Private Key
resource "null_resource" "set_key_permissions" {
  provisioner "local-exec" {
    command = "chmod 600 ${local_file.bastion_private_key.filename}"
  }

  depends_on = [local_file.bastion_private_key]
}

resource "aws_instance" "bastion" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = var.instance_type
  # key_name      = aws_key_pair.bastion_key.key_name # Use the generated key pair
  key_name      = aws_key_pair.bastion_key # Use the generated key pair

  subnet_id     = var.subnet_id

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker git
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    systemctl start docker
    systemctl enable docker
  EOF

  tags = {
    Name = "bastion-host"
  }

  security_groups = [aws_security_group.bastion.id]
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

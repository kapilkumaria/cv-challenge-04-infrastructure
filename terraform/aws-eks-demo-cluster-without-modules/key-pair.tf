resource "random_id" "server" {
  byte_length = 4
}

resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair-${random_id.server.hex}"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair-${random_id.server.hex}"
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.rsa.private_key_pem
  filename        = format("%s/%s/%s", abspath(path.root), ".ssh", "ansible-ssh-key.pem")
  file_permission = "0600"
}



// local_sensitive_file.private_key.key_name = "ansible-ssh-key.pem"
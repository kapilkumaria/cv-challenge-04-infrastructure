# output "bastion_public_ip" {
#   description = "Public IP of the bastion host"
#   value       = aws_instance.bastion.public_ip
# }

# output "bastion_public_dns" {
#   description = "Public DNS of the bastion host"
#   value       = aws_instance.bastion.public_dns
# }

# output "bastion_private_key" {
#   description = "Private key for SSH access to the bastion host"
#   value       = tls_private_key.bastion_key.private_key_pem
#   sensitive   = true
# }

# output "bastion_public_ip" {
#   description = "Public IP of the bastion host"
#   value       = aws_instance.bastion.public_ip
# }

output "bastion_private_key_path" {
  description = "Path to the private key file for the bastion host"
  value       = local_file.bastion_private_key.filename
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_public_dns" {
  description = "Public DNS of the bastion host"
  value       = aws_instance.bastion.public_dns
}

output "bastion_private_key" {
  description = "Private key for SSH access to the bastion host"
  value       = tls_private_key.bastion_key.private_key_pem
  sensitive   = true
}

output "bastion_key_name" {
  description = "The name of the key pair for the bastion host."
  value       = aws_key_pair.bastion_key.key_name
}
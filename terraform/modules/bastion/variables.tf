variable "vpc_id" {
  description = "VPC ID for the bastion host"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the bastion host"
  type        = string
}

variable "key_pair" {
  description = "Name of the key pair for SSH access"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t3.micro"
}

variable "allowed_cidr" {
  description = "List of CIDR blocks allowed to SSH into the bastion host"
  type        = list(string)
}

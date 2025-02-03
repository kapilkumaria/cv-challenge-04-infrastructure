################################################################################
# TERRAFORM ROUTE53 MODULE VARIABLES FILE
################################################################################

variable "hosted_zone_id" {
  description = "The Route53 Hosted Zone ID for the domain"
  type        = string
}

variable "domain_name" {
  description = "The custom domain name for ALB routing"
  type        = string
}

# variable "alb_hostname" {
#   description = "The ALB hostname for Route53"
#   type        = string
# }

variable "ingress_nginx_hostname" {
  description = "The hostname of the NGINX Ingress LoadBalancer"
  type        = string
}

variable "ingress_nginx_zone_id" {
  description = "The Hosted Zone ID for the NGINX LoadBalancer"
  type        = string
}


################################################################################
# TERRAFORM INGRESS CONTROLLER VARIABLES FILE
################################################################################

variable "domain_name" {
  description = "The custom domain name for ingress routing"
  type        = string
  default     = "kapilkumaria.com"
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID for domain"
  type        = string
}

variable "alb_hostname" {
  description = "The ALB hostname for the ingress"
  type        = string
}

variable "alb_zone_id" {
  description = "The ALB Zone ID"
  type        = string
}

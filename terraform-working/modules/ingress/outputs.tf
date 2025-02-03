################################################################################
# TERRAFORM INGRESS CONTROLLER OUTPUTS FILE
################################################################################

output "route53_dns_record" {
  description = "The Route53 DNS record for the domain"
  value       = aws_route53_record.argocd_dns.name
}

output "ingress_nginx_hostname" {
  description = "The NGINX Ingress LoadBalancer hostname"
  value       = helm_release.nginx_ingress.metadata[0].name
}

output "ingress_nginx_zone_id" {
  description = "The Hosted Zone ID for NGINX LoadBalancer"
  value       = helm_release.nginx_ingress.metadata[0].namespace
}



################################################################################
# TERRAFORM ROUTE53 MODULE OUTPUTS FILE
################################################################################

output "route53_dns_record" {
  description = "The Route53 DNS record for the domain"
  value       = aws_route53_record.argocd_dns.name
}
################################################################################
# TERRAFORM ROUTE53 MODULE CONFIGURATION FILE
################################################################################

resource "aws_route53_record" "argocd_dns" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {    
    name                   = var.ingress_nginx_hostname  # ✅ Use NGINX LoadBalancer hostname
    zone_id                = var.ingress_nginx_zone_id  # ✅ Use NGINX Hosted Zone ID
    evaluate_target_health = true
  }
}


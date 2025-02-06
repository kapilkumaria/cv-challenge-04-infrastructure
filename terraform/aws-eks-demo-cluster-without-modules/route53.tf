# Fetch Hosted Zone for kapilkumaria.com
data "aws_route53_zone" "main" {
  name         = "kapilkumaria.com"
  private_zone = false
}

# Use an external script to get the Ingress Load Balancer hostname dynamically
data "external" "ingress_lb" {
  program = ["bash", "./fetch-ingress.sh"]
}

# Create Route 53 Record for Ingress Load Balancer
resource "aws_route53_record" "ingress" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "kapilkumaria.com"
  type    = "A"

  alias {
    name                   = data.external.ingress_lb.result["hostname"]
    zone_id                = "Z26RNL4JYFTOTI"  # AWS Hosted Zone ID for NLBs
    evaluate_target_health = true
  }

  depends_on = [kubectl_manifest.ingress]
}

# Redirect www.kapilkumaria.com to kapilkumaria.com
resource "aws_route53_record" "www_redirect" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.kapilkumaria.com"
  type    = "CNAME"
  ttl     = 300
  records = ["kapilkumaria.com"]

  depends_on = [aws_route53_record.ingress]  # Ensure main domain is configured before redirect
}

# Optional: Wildcard subdomain (*.kapilkumaria.com)
resource "aws_route53_record" "wildcard" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "*.kapilkumaria.com"
  type    = "A"

  alias {
    name                   = data.external.ingress_lb.result["hostname"]
    zone_id                = "Z26RNL4JYFTOTI"
    evaluate_target_health = true
  }

  depends_on = [aws_route53_record.ingress]  # Ensure main domain is configured before redirect
}

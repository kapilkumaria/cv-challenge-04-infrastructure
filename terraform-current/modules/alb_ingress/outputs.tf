################################################################################
# TERRAFORM ALB INGRESS CONTROLLER OUTPUTS FILE
################################################################################

output "alb_hostname" {
  description = "The ALB hostname"
  value       = kubernetes_ingress_v1.alb_ingress.status[0].load_balancer[0].ingress[0].hostname
}

# output "alb_zone_id" {
#   description = "The hosted zone ID of the ALB"
#   value       = aws_lb.alb.zone_id
# }
